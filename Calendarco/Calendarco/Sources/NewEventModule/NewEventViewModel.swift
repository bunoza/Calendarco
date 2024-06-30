
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

        let calendarHeader = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//bunoza.Calendarco//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        """

        let calendarFooter = "END:VCALENDAR"

        var eventsContent = ""

        for event in events {
            let dtstamp = dateFormatter.string(from: Date())
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)

            var eventContent = """
            BEGIN:VEVENT
            UID:\(UUID().uuidString)
            DTSTAMP:\(dtstamp)
            SUMMARY:\(event.title)
            DTSTART:\(startDateString)
            DTEND:\(endDateString)
            DESCRIPTION:\(event.eventDescription)
            URL:\(event.url)
            """

            if event.recurrenceRule != "None" {
                eventContent += "\nRRULE:\(RecurrenceOption(rawValue: event.recurrenceRule).rule)"
            }

            eventContent += "\nEND:VEVENT"
            eventsContent += eventContent + "\n"
        }

        let icsContent = calendarHeader + "\n" + eventsContent + calendarFooter
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
