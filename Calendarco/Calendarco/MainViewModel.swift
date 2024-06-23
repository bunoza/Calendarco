import SwiftUI
import FirebaseStorage

struct Event: Identifiable {
    var id = UUID()
    var title: String = ""
    var description: String = ""
    var url: String = ""
    var startDate: Date = .init()
    var endDate: Date = Date().addingTimeInterval(3600)
}

class MainViewModel: ObservableObject {
    @Published var events: [Event] = [Event()]
    @Published var icsData: Data? = nil
    @Published var tempFileURL: URL? = nil
    @Published var downloadURL: URL? = nil
    
    let manager = StorageManager()
    
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
            URL: \(event.url)
            END:VEVENT
            """
        }
        
        icsContent += "\nEND:VCALENDAR"
        
        icsData = icsContent.data(using: .utf8)
    }
    
    func deleteOldFiles() {
        manager.deleteOldFiles { result in
            switch result {
            case .success():
                print("Successfully deleted old files")
            case .failure(let error):
                print("Failed to delete old files: \(error)")
            }
        }
    }

    func handleEventChange() {
        if tempFileURL != nil {
            withAnimation {
                deleteTempFile()                
            }
        }
    }

    func saveToTempFile(fileName: String) {
        createICSData()
        guard let icsData = icsData else { return }

        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(fileName.isEmpty ? "generated_events.ics" : fileName + ".ics")

        do {
            try icsData.write(to: tempFileURL)
            
            withAnimation {
                self.tempFileURL = tempFileURL
            }
            
            uploadFileToFirebaseStorage(fileURL: tempFileURL)
        } catch {
            print("Failed to write .ics file to temporary directory: \(error)")
        }
    }

    func deleteTempFile() {
        if let tempFileURL = tempFileURL {
            do {
                try FileManager.default.removeItem(at: tempFileURL)
                print("Temporary file deleted: \(tempFileURL)")
            } catch {
                print("Failed to delete temporary file: \(error)")
            }
            self.tempFileURL = nil
        }
    }

    private func uploadFileToFirebaseStorage(fileURL: URL) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("events/\(UUID().uuidString)")
        
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload file to Firebase Storage: \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }

                guard let downloadURL = url else {
                    print("Download URL is nil")
                    return
                }
                
                print("File successfully uploaded to Firebase Storage: \(downloadURL)")
                self.downloadURL = downloadURL
            }
        }
    }
}

