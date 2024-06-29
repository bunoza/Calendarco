import Firebase
import FirebaseStorage
import Foundation

class StorageManager {
    let storage = Storage.storage()

    func deleteOldFiles(completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = storage.reference().child("events")
        storageRef.listAll { result, error in
            if let error = error {
                print("Error listing files: \(error)")
                completion(.failure(error))
                return
            }

            guard let result else {
                return
            }

            let now = Date()
            let cutoffDate = now.addingTimeInterval(-30 * 24 * 60 * 60) // 30 days

            let dispatchGroup = DispatchGroup()

            for item in result.items {
                dispatchGroup.enter()
                item.getMetadata { metadata, error in
                    if let error = error {
                        print("Error getting metadata: \(error)")
                        dispatchGroup.leave()
                    }

                    if let metadata = metadata, let updatedTime = metadata.updated {
                        if updatedTime < cutoffDate {
                            item.delete { error in
                                if let error = error {
                                    print("Error deleting file: \(error)")
                                } else {
                                    print("Deleted file: \(item.name)")
                                }
                                dispatchGroup.leave()
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(.success(()))
            }
        }
    }
}
