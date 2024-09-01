import Foundation

enum IAPManagerAlertType {
    case disabled
    case restored
    case purchased
    case failed

    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device."
        case .restored: return "You've successfully restored your purchase."
        case .purchased: return "You've successfully bought this purchase."
        case .failed: return "Could not complete purchase process.\nPlease try again."
        }
    }
}
