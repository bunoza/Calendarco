import Foundation
import SwiftData

@MainActor
final class MainViewModel: ObservableObject {
    @Published var selectedTab: Tab = .newEvent
    @Published var events: [Event] = []
    @Published var fileName: String = ""
    @Published var tempFileURL: URL? = nil
    @Published var downloadURL: URL? = nil

    let manager = FirebaseManager()

    func importEvent(_ eventEntity: EventEntity) {
        selectedTab = .newEvent

        events.removeAll()

        fileName = eventEntity.fileName

        for event in eventEntity.events {
            events.append(
                Event(
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
