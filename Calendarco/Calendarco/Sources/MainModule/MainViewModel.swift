import Foundation
import SwiftData

@MainActor
final class MainViewModel: ObservableObject {
    @Published var selectedTab: Tab = .newEvent
    @Published var events: [Event] = []
    @Published var fileName: String = ""
    @Published var tempFileURL: URL? = nil
    @Published var downloadURL: URL? = nil

    let context: ModelContext

    let manager = FirebaseManager()

    init(modelContext: ModelContext) {
        context = modelContext
    }

    func importEvent(_ eventEntity: EventEntity) {
        selectedTab = .newEvent

        events.removeAll()

        fileName = eventEntity.fileName

        for event in eventEntity.events {
            events.append(
                Event(
                    id: event.id,
                    title: event.title,
                    eventDescription: event.eventDescription,
                    url: event.url,
                    recurrenceRule: RecurrenceOption(rawValue: event.recurrenceRule),
                    startDate: event.startDate,
                    endDate: event.endDate
                )
            )
        }
    }

    func saveToTempFile(fileName: String, icsData: Data) {
        let tempDirectory = FileManager.default.temporaryDirectory
        let finalFileName = fileName.isEmpty ? "generated_events.ics" : "\(fileName).ics"
        let tempFileURL = tempDirectory.appendingPathComponent(finalFileName)

        do {
            try icsData.write(to: tempFileURL)
            self.tempFileURL = tempFileURL

            manager.uploadFileToFirebaseStorage(fileURL: tempFileURL) { [self] downloadURL in
                guard let downloadURL = downloadURL else {
                    print("Failed to upload file to Firebase Storage")
                    return
                }

                let newFile = EventEntity(
                    events: self.events,
                    fileName: fileName,
                    creationDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    downloadURL: downloadURL.absoluteString
                )
                self.context.insert(newFile)
                try? context.save()
                self.downloadURL = downloadURL
            }
        } catch {
            print("Failed to write .ics file to temporary directory: \(error)")
        }
    }

    func deleteOldFiles() {
        manager.deleteOldFiles { result in
            switch result {
            case .success():
                print("Successfully deleted old files")
            case let .failure(error):
                print("Failed to delete old files: \(error)")
            }
        }
    }

    enum Tab {
        case newEvent
        case history
    }
}
