
import Foundation

struct Event: Identifiable, Equatable {
    var id = UUID()
    var title: String = ""
    var description: String = ""
    var url: String = ""
    var recurrenceRule: RecurrenceOption = .none
    var startDate: Date = .init()
    var endDate: Date = Date().addingTimeInterval(3600)
}
