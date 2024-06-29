
import Foundation

enum RecurrenceOption: String, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

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
