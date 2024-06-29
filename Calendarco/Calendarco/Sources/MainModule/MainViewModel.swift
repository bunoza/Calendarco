
import Foundation

class MainViewModel: ObservableObject {
    @Published var selectedTab: Tab = .newEvent
    @Published var events: [Event] = []
    
    let manager = StorageManager()
    
    func importEvent(_ eventEntity: EventEntity) {
        selectedTab = .newEvent
        
        // Clear current events and add the imported event
        events.removeAll()
        
        let importedEvent = Event(
            title: eventEntity.title,
            description: eventEntity.descriptionText,
            url: eventEntity.url,
            recurrenceRule: RecurrenceOption(rawValue: eventEntity.recurrenceRule) ?? .none,
            startDate: eventEntity.startDate,
            endDate: eventEntity.endDate
        )
        
        events.append(importedEvent)
    }
    
    func deleteOldFiles() {
        manager.deleteOldFiles { result in
            switch result {
            case .success():
                print("Successfully deleted old files")
            case let .failure(error):
                print("Failed to delete old files: \(error)")
            }
        }
    }
    
    enum Tab {
        case newEvent
        case history
    }
}
