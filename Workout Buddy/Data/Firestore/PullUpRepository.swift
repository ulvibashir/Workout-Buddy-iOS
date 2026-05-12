import Foundation

final class PullUpRepository {

    private let service: FirestoreService

    init(service: FirestoreService) {
        self.service = service
    }

    func listenAll() -> AsyncStream<Result<[PullUpLog], AppError>> {
        let path = "\(AppConstants.Firestore.userRoot)/\(AppConstants.Firestore.Collections.pullUpLogs)"
        return service.listenCollection(path: path)
    }

    func saveSession(_ log: PullUpLog, date: String) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.pullUpLogs, date)
        try await service.setDocument(path: path, value: log)
    }

    func fetchProgram() async throws -> PullUpProgram? {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.pullupProgram, AppConstants.Firestore.Documents.programMain)
        return try await service.fetchDocument(path: path)
    }
}
