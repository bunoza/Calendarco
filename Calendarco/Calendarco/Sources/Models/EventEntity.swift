import Foundation
import SwiftData

@Model
final class EventEntity: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    @Relationship var events: [Event] = [Event]()
    var fileName: String
    var creationDate: Date
    var expirationDate: Date
    var downloadURL: String? = nil

    init(events: [Event] = [], fileName: String, creationDate: Date, expirationDate: Date, downloadURL: String? = nil) {
        self.events = events
        self.fileName = fileName
        self.creationDate = creationDate
        self.expirationDate = expirationDate
        self.downloadURL = downloadURL
    }
}
