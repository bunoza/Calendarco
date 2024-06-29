
import SwiftData
import SwiftUI

@MainActor
final class NewEventViewModel: ObservableObject {
    @Published var events: [Event] = [Event()]
    @Published var icsData: Data? = nil

    let manager: FirebaseManager = .shared

    func addEvent() {
        events.append(Event())
    }

    func createICSData() {
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
            DESCRIPTION:\(event.eventDescription)
            URL:\(event.url)
            RRULE:\(RecurrenceOption(rawValue: event.recurrenceRule).rule)
            END:VEVENT
            """
        }

        icsContent += "\nEND:VCALENDAR"
        icsData = icsContent.data(using: .utf8)
    }

    func handleEventChange(mainViewModel: MainViewModel) {
        if mainViewModel.tempFileURL != nil {
            withAnimation {
                deleteTempFile(mainViewModel: mainViewModel)
            }
        }
    }

    func deleteTempFile(mainViewModel: MainViewModel) {
        guard let tempFileURL = mainViewModel.tempFileURL else { return }

        do {
            try FileManager.default.removeItem(at: tempFileURL)
            print("Temporary file deleted: \(tempFileURL)")
        } catch {
            print("Failed to delete temporary file: \(error)")
        }
        mainViewModel.tempFileURL = nil
    }
}
