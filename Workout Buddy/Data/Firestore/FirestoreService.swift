import Foundation
import FirebaseFirestore

final class FirestoreService {

    private let db: Firestore

    init(db: Firestore) {
        self.db = db
    }

    // MARK: - Typed document ref helper
    func ref(_ path: String) -> DocumentReference {
        db.document(path)
    }

    func collectionRef(_ path: String) -> CollectionReference {
        db.collection(path)
    }

    // MARK: - Live document stream
    func listenDocument<T: Decodable>(
        path: String
    ) -> AsyncStream<Result<T?, AppError>> {
        AsyncStream { continuation in
            let listener = db.document(path).addSnapshotListener { snap, error in
                if let error {
                    continuation.yield(.failure(.firestoreRead("\(path): \(error.localizedDescription)")))
                    return
                }
                do {
                    let value = try snap?.data(as: T.self)
                    continuation.yield(.success(value))
                } catch {
                    continuation.yield(.failure(.decodingFailed("\(path): \(error.localizedDescription)")))
                }
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    // MARK: - Live collection stream
    func listenCollection<T: Decodable>(
        path: String
    ) -> AsyncStream<Result<[T], AppError>> {
        AsyncStream { continuation in
            let listener = db.collection(path).addSnapshotListener { snap, error in
                if let error {
                    continuation.yield(.failure(.firestoreRead("\(path): \(error.localizedDescription)")))
                    return
                }
                do {
                    let items = try snap?.documents.compactMap { try $0.data(as: T.self) } ?? []
                    continuation.yield(.success(items))
                } catch {
                    continuation.yield(.failure(.decodingFailed("\(path): \(error.localizedDescription)")))
                }
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    // MARK: - One-shot fetch
    func fetchDocument<T: Decodable>(path: String) async throws -> T? {
        let snap = try await db.document(path).getDocument()
        return try snap.data(as: T.self)
    }

    func fetchCollection<T: Decodable>(path: String) async throws -> [T] {
        let snap = try await db.collection(path).getDocuments()
        return try snap.documents.compactMap { try $0.data(as: T.self) }
    }

    // MARK: - Write
    func setDocument<T: Encodable>(path: String, value: T, merge: Bool = true) async throws {
        try db.document(path).setData(from: value, merge: merge)
    }

    func setData(path: String, data: [String: Any], merge: Bool = true) async throws {
        try await db.document(path).setData(data, merge: merge)
    }

    func deleteDocument(path: String) async throws {
        try await db.document(path).delete()
    }
}
