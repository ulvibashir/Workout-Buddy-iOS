import Foundation

final class WorkoutRepository {

    private let service: FirestoreService

    init(service: FirestoreService) {
        self.service = service
    }

    // MARK: - Workout program (read from seeded Firestore data)
    func listenWorkoutDay(_ day: String) -> AsyncStream<Result<WorkoutDay?, AppError>> {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.workoutDays, day)
        return service.listenDocument(path: path)
    }

    func fetchAllWorkoutDays() async throws -> [String: WorkoutDay] {
        var result: [String: WorkoutDay] = [:]
        for day in AppConstants.Firestore.WeekDays.all {
            let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.workoutDays, day)
            if let wd: WorkoutDay = try await service.fetchDocument(path: path) {
                result[day] = wd
            }
        }
        return result
    }

    // MARK: - Completion state
    func listenCompletedDays() -> AsyncStream<Result<[String: Bool]?, AppError>> {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.workoutLogs, AppConstants.Firestore.Documents.completed)
        return service.listenDocument(path: path)
    }

    func markDayCompleted(_ day: String, completed: Bool) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.workoutLogs, AppConstants.Firestore.Documents.completed)
        try await service.setData(path: path, data: [day: completed])
    }

    // MARK: - Pull-up program
    func fetchPullUpProgram() async throws -> PullUpProgram? {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.pullupProgram, AppConstants.Firestore.Documents.programMain)
        return try await service.fetchDocument(path: path)
    }

    // MARK: - Quotes
    func fetchQuotes() async throws -> [String] {
        struct QuotesDoc: Codable { var quotes: [String] }
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.goals, AppConstants.Firestore.Documents.quotes)
        let doc: QuotesDoc? = try await service.fetchDocument(path: path)
        return doc?.quotes ?? []
    }
}
