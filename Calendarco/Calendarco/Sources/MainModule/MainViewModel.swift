import Foundation
import SwiftData

@MainActor
final class MainViewModel: ObservableObject {
    enum Tab {
        case newEvent
        case history
    }

    @Published var selectedTab: Tab = .newEvent
    @Published var eventEntity: EventEntity?

    let manager = FirebaseManager()

    func importEvent(_ eventEntity: EventEntity) {
        selectedTab = .newEvent
        self.eventEntity = eventEntity
    }

    func deleteOldFiles() {
        manager.deleteOldFiles { result in
            switch result {
            case .success:
                print("Successfully deleted old files")
            case let .failure(error):
                print("Failed to delete old files: \(error)")
            }
        }
    }
}
