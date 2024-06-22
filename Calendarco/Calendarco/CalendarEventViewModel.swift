import SwiftUI

struct Event: Identifiable {
    var id = UUID()
    var title: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date().addingTimeInterval(3600)
}

class CalendarEventViewModel: ObservableObject {
    @Published var events: [Event] = [Event()]
    @Published var icsData: Data? = nil
    
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
        """
        
        for event in events {
            let startDateString = dateFormatter.string(from: event.startDate)
            let endDateString = dateFormatter.string(from: event.endDate)
            icsContent += """
            
            BEGIN:VEVENT
            SUMMARY:\(event.title)
            DTSTART:\(startDateString)
            DTEND:\(endDateString)
            END:VEVENT
            """
        }
        
        icsContent += "\nEND:VCALENDAR"
        
        icsData = icsContent.data(using: .utf8)
    }
}
