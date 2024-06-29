import Foundation
import SwiftData

@Model
final class EventEntity: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var descriptionText: String
    var url: String
    var recurrenceRule: String
    var startDate: Date
    var endDate: Date
    var creationDate: Date
    var expirationDate: Date

    init(title: String, descriptionText: String, url: String, recurrenceRule: String, startDate: Date, endDate: Date, creationDate: Date, expirationDate: Date) {
        self.title = title
        self.descriptionText = descriptionText
        self.url = url
        self.recurrenceRule = recurrenceRule
        self.startDate = startDate
        self.endDate = endDate
        self.creationDate = creationDate
        self.expirationDate = expirationDate
    }
}
