import FirebaseStorage
import SwiftData
import SwiftUI

class NewEventViewModel: ObservableObject {
    @Published var events: [Event] = [Event()]
    @Published var icsData: Data? = nil
    @Published var tempFileURL: URL? = nil
    @Published var downloadURL: URL? = nil

    func addEvent() {
        events.append(Event())
    }

    private func createICSData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        """

        for event in events {
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)

            icsContent += """

            BEGIN:VEVENT
            SUMMARY:\(event.title)
            DTSTART:\(startDateString)
            DTEND:\(endDateString)
            DESCRIPTION:\(event.description)
            URL:\(event.url)
            RRULE:\(event.recurrenceRule.rule)
            END:VEVENT
            """
        }

        icsContent += "\nEND:VCALENDAR"
        icsData = icsContent.data(using: .utf8)
    }

    func handleEventChange() {
        if tempFileURL != nil {
            withAnimation {
                deleteTempFile()
            }
        }
    }

    func saveToTempFile(fileName: String, context: ModelContext) {
        createICSData()
        guard let icsData = icsData else { return }

        let tempDirectory = FileManager.default.temporaryDirectory
        let finalFileName = fileName.isEmpty ? "generated_events.ics" : "\(fileName).ics"
        let tempFileURL = tempDirectory.appendingPathComponent(finalFileName)

        do {
            try icsData.write(to: tempFileURL)
            withAnimation {
                self.tempFileURL = tempFileURL
            }

            uploadFileToFirebaseStorage(fileURL: tempFileURL) { downloadURL in
                let newFile = EventEntity(
                    title: finalFileName,
                    descriptionText: "\(self.events.count) events",
                    url: "",
                    recurrenceRule: "",
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(3600),
                    creationDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    downloadURL: downloadURL?.absoluteString // Save the download URL
                )
                context.insert(newFile)
                try? context.save()
            }
        } catch {
            print("Failed to write .ics file to temporary directory: \(error)")
        }
    }

    private func uploadFileToFirebaseStorage(fileURL: URL, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("events/\(UUID().uuidString)")

        storageRef.putFile(from: fileURL, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload file to Firebase Storage: \(error)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    completion(nil)
                    return
                }

                guard let downloadURL = url else {
                    print("Download URL is nil")
                    completion(nil)
                    return
                }

                print("File successfully uploaded to Firebase Storage: \(downloadURL)")
                self.downloadURL = downloadURL
                completion(downloadURL)
            }
        }
    }

    func deleteTempFile() {
        guard let tempFileURL = tempFileURL else { return }

        do {
            try FileManager.default.removeItem(at: tempFileURL)
            print("Temporary file deleted: \(tempFileURL)")
        } catch {
            print("Failed to delete temporary file: \(error)")
        }
        self.tempFileURL = nil
    }
}
