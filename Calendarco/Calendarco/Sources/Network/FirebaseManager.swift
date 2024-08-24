import Firebase
import FirebaseStorage
import Foundation

final class FirebaseManager: Sendable {
    static let shared = FirebaseManager()

    private let storage = Storage.storage()

    func deleteFileFromFirebaseStorage(downloadURL: String?, completion: @escaping (Bool) -> Void) {
        guard let downloadURL = downloadURL else {
            completion(false)
            return
        }

        let storageRef = Storage.storage().reference(forURL: downloadURL)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting file from Firebase Storage: \(error)")
                completion(false)
            } else {
                print("File deleted successfully from Firebase Storage")
                completion(true)
            }
        }
    }

    func uploadFileToFirebaseStorage(fileURL: URL, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("events/\(UUID().uuidString)")

        storageRef.putFile(from: fileURL, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload file to Firebase Storage: \(error)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    completion(nil)
                    return
                }

                guard let downloadURL = url else {
                    print("Download URL is nil")
                    completion(nil)
                    return
                }

                print("File successfully uploaded to Firebase Storage: \(downloadURL)")
                completion(downloadURL)
            }
        }
    }

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
            let cutoffDate = now.addingTimeInterval(-(Constants.fileExistencePeriod))

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
