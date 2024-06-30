
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
        BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//bunoza.Calendarco//EN\r\nCALSCALE:GREGORIAN\r\nMETHOD:PUBLISH\r\n
        """

        let calendarFooter = "END:VCALENDAR\r\n"

        var eventsContent = ""

        for event in events {
            let dtstamp = dateFormatter.string(from: Date())
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)

            var eventContent = """
            BEGIN:VEVENT\r\nUID:\(UUID().uuidString)\r\nDTSTAMP:\(dtstamp)\r\nSUMMARY:\(event.title)\r\nDTSTART:\(startDateString)\r\nDTEND:\(endDateString)\r\nDESCRIPTION:\(event.eventDescription)\r\nURL:\(event.url)\r\n
            """

            if event.recurrenceRule != "None" {
                eventContent += "RRULE:\(RecurrenceOption(rawValue: event.recurrenceRule).rule)\r\n"
            }

            eventContent += "END:VEVENT\r\n"
            eventsContent += eventContent
        }

        let icsContent = calendarHeader + eventsContent + calendarFooter
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
