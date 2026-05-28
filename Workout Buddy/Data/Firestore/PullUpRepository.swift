import Foundation

// MARK: - Pull-up data types

struct PullUpLog: Codable, Identifiable {
    var id: String?
    var sets: [Int]
    var maxReps: Int  { sets.max() ?? 0 }
    var totalReps: Int { sets.reduce(0, +) }
}

struct PullUpProgram: Codable {
    var currentMax: Int
    var grips: [String]
    var weeklyProgression: [WeekPlan]

    struct WeekPlan: Codable {
        var week: Int
        var sets: Int
        var reps: Int
    }
}

// MARK: - Repository

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
