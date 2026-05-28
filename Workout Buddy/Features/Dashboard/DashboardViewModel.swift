import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class DashboardViewModel {

    var todayMetrics: HealthMetrics?
    var weeklyMetrics: [HealthMetrics] = []
    var todayWorkout: WorkoutLog?
    var todayPlan: WorkoutPlan?
    var weeklyWorkouts: [WorkoutLog] = []
    var weeklyRuns: [RunningLog] = []
    var userProfile: UserProfile = UserProfile()
    var isLoading: Bool = true
    var error: String?

    private let db = Firestore.firestore()
    private var uid: String

    init(uid: String) {
        self.uid = uid
    }

    // MARK: - Computed

    var readinessScore: Int { todayMetrics?.readinessScore ?? 0 }
    var readinessStatus: ReadinessStatus { todayMetrics?.readinessStatus ?? .caution }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }

    var weeklyCompletedCount: Int {
        weeklyWorkouts.filter { $0.status == .completed }.count
    }

    var weeklyTotalTrainingDays: Int {
        weeklyWorkouts.filter { $0.workoutType != WorkoutType.rest.rawValue }.count
    }

    var isPerfectWeek: Bool {
        weeklyTotalTrainingDays > 0 && weeklyCompletedCount == weeklyTotalTrainingDays
    }

    var weeklyRunDistance: Double {
        weeklyRuns.reduce(0) { $0 + $1.distance }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        let today = Date.today.dateKey
        let weekDays = Date.currentWeekDays()

        async let metricsSnap    = fetchTodayMetrics(today)
        async let weekMetrics    = fetchWeekMetrics(weekDays)
        async let todayLogSnap   = fetchWorkoutLog(for: today)
        async let weekLogsSnap   = fetchWeekWorkoutLogs(weekDays)
        async let runsSnap       = fetchWeekRuns()
        async let profileSnap    = fetchProfile()

        todayMetrics   = await metricsSnap
        weeklyMetrics  = await weekMetrics
        todayWorkout   = await todayLogSnap
        weeklyWorkouts = await weekLogsSnap
        weeklyRuns     = await runsSnap
        userProfile    = await profileSnap ?? UserProfile()
        isLoading      = false
    }

    // MARK: - Private Fetchers

    private func fetchTodayMetrics(_ date: String) async -> HealthMetrics? {
        try? await db.document("users/\(uid)/healthMetrics/\(date)").getDocument(as: HealthMetrics.self)
    }

    private func fetchWeekMetrics(_ days: [Date]) async -> [HealthMetrics] {
        var results: [HealthMetrics] = []
        for day in days {
            if let m = try? await db.document("users/\(uid)/healthMetrics/\(day.dateKey)").getDocument(as: HealthMetrics.self) {
                results.append(m)
            }
        }
        return results
    }

    private func fetchWorkoutLog(for date: String) async -> WorkoutLog? {
        try? await db.document("users/\(uid)/workoutLogs/\(date)").getDocument(as: WorkoutLog.self)
    }

    private func fetchWeekWorkoutLogs(_ days: [Date]) async -> [WorkoutLog] {
        var results: [WorkoutLog] = []
        for day in days {
            if let log = try? await db.document("users/\(uid)/workoutLogs/\(day.dateKey)").getDocument(as: WorkoutLog.self) {
                results.append(log)
            }
        }
        return results
    }

    private func fetchWeekRuns() async -> [RunningLog] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let snap = try? await db.collection("users/\(uid)/runningLogs")
            .whereField("createdAt", isGreaterThan: Timestamp(date: weekAgo))
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap?.documents.compactMap { try? $0.data(as: RunningLog.self) } ?? []
    }

    private func fetchProfile() async -> UserProfile? {
        try? await db.document("users/\(uid)/profile/main").getDocument(as: UserProfile.self)
    }
}
