import Foundation
import SwiftData

@Model
final class Event: Identifiable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    var id: UUID
    var title: String
    var eventDescription: String
    var url: String
    var recurrenceRule: String
    var startDate: Date
    var endDate: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        eventDescription: String = "",
        url: String = "",
        recurrenceRule: RecurrenceOption = .none,
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(3600)
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.url = url
        self.recurrenceRule = recurrenceRule.rawValue
        self.startDate = startDate
        self.endDate = endDate
    }
}
