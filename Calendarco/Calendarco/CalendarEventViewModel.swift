import SwiftUI

class CalendarEventViewModel: ObservableObject {
    @Published var eventTitle1: String = ""
    @Published var startDate1: Date = Date()
    @Published var endDate1: Date = Date().addingTimeInterval(3600)
    
    @Published var eventTitle2: String = ""
    @Published var startDate2: Date = Date().addingTimeInterval(7200)
    @Published var endDate2: Date = Date().addingTimeInterval(10800)
    
    @Published var icsData: Data? = nil
    
    func createICSData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startDateString1 = dateFormatter.string(from: startDate1)
        let endDateString1 = dateFormatter.string(from: endDate1)
        
        let startDateString2 = dateFormatter.string(from: startDate2)
        let endDateString2 = dateFormatter.string(from: endDate2)
        
        let icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        CALSCALE:GREGORIAN
        BEGIN:VEVENT
        SUMMARY:\(eventTitle1)
        DTSTART:\(startDateString1)
        DTEND:\(endDateString1)
        END:VEVENT
        BEGIN:VEVENT
        SUMMARY:\(eventTitle2)
        DTSTART:\(startDateString2)
        DTEND:\(endDateString2)
        END:VEVENT
        END:VCALENDAR
        """
        
        icsData = icsContent.data(using: .utf8)
    }
}
