import Foundation
import SwiftData

enum RecurrenceOption: String, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    init(rawValue: String) {
        switch rawValue {
        case "None":
            self = .none
        case "Daily":
            self = .daily
        case "Weekly":
            self = .weekly
        case "Monthly":
            self = .monthly
        case "Yearly":
            self = .yearly
        default:
            self = .none
        }
    }

    var rule: String {
        switch self {
        case .none:
            ""
        case .daily:
            "FREQ=DAILY"
        case .weekly:
            "FREQ=WEEKLY"
        case .monthly:
            "FREQ=MONTHLY"
        case .yearly:
            "FREQ=YEARLY"
        }
    }
}
