
import Foundation

class MainViewModel: ObservableObject {
    let manager = StorageManager()

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
}
