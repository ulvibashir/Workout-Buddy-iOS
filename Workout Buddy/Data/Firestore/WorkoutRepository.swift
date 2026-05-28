import Foundation

final class WorkoutRepository {

    private let service: FirestoreService

    init(service: FirestoreService) {
        self.service = service
    }

    // MARK: - Workout plans (read from Firestore workoutPlans collection)

    func listenWorkoutDay(_ day: String) -> AsyncStream<Result<WorkoutPlan?, AppError>> {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.workoutDays, day)
        return service.listenDocument(path: path)
    }

    func fetchAllWorkoutDays() async throws -> [String: WorkoutPlan] {
        var result: [String: WorkoutPlan] = [:]
        for day in AppConstants.Firestore.WeekDays.all {
            let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.workoutDays, day)
            if let wd: WorkoutPlan = try await service.fetchDocument(path: path) {
                result[day] = wd
            }
        }
        return result
    }

    // MARK: - Workout logs (per-day completion state)

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
