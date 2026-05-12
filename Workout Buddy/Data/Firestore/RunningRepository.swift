import Foundation

final class RunningRepository {

    private let service: FirestoreService

    init(service: FirestoreService) {
        self.service = service
    }

    func listenAll() -> AsyncStream<Result<[RunningLog], AppError>> {
        let path = "\(AppConstants.Firestore.userRoot)/\(AppConstants.Firestore.Collections.runningLogs)"
        return service.listenCollection(path: path)
    }

    func saveRun(_ log: RunningLog, id: String) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.runningLogs, id)
        try await service.setDocument(path: path, value: log)
    }

    func deleteRun(id: String) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.runningLogs, id)
        try await service.deleteDocument(path: path)
    }

    // MARK: - Six-month goals
    func fetchSixMonthGoals() async throws -> [SixMonthGoal] {
        struct GoalsDoc: Codable { var goals: [SixMonthGoal] }
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.goals, AppConstants.Firestore.Documents.sixMonth)
        let doc: GoalsDoc? = try await service.fetchDocument(path: path)
        return doc?.goals ?? []
    }
}
