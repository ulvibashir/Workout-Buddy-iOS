import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class WorkoutViewModel {

    var selectedDate: Date = .today
    var workoutPlans: [String: WorkoutPlan] = [:]
    var weekWorkoutLogs: [String: WorkoutLog] = [:]
    var isLoading: Bool = false
    var error: String?
    var showConfetti: Bool = false

    private let db = Firestore.firestore()
    private var uid: String

    init(uid: String) {
        self.uid = uid
    }

    // MARK: - Computed

    var selectedPlan: WorkoutPlan? {
        workoutPlans[selectedDate.weekdayName]
    }

    var selectedLog: WorkoutLog? {
        weekWorkoutLogs[selectedDate.dateKey]
    }

    var showActionButtons: Bool {
        !isLoading && selectedDate.isToday && (selectedLog == nil || selectedLog?.status == .pending)
    }

    var canMarkCompleted: Bool {
        !isLoading && (selectedLog?.status == .postponed || selectedLog?.status == .missed)
    }

    // MARK: - Data Loading

    func loadWeekData() async {
        isLoading = true
        let weekDays = Date.currentWeekDays()

        // Load plans
        for day in WorkoutPlan.dayOrder {
            if let plan = try? await db.document("users/\(uid)/workoutPlans/\(day)").getDocument(as: WorkoutPlan.self) {
                workoutPlans[day] = plan
            }
        }

        // Load logs
        for day in weekDays {
            if let log = try? await db.document("users/\(uid)/workoutLogs/\(day.dateKey)").getDocument(as: WorkoutLog.self) {
                weekWorkoutLogs[day.dateKey] = log
            }
        }
        isLoading = false
    }

    // MARK: - Actions

    func completeWorkout() async {
        guard let plan = selectedPlan else { return }
        let log = WorkoutLog(
            date: selectedDate.dateKey,
            workoutType: plan.type,
            workoutName: plan.name,
            status: .completed,
            isAutoMissed: false,
            completedAt: Timestamp(date: Date()),
            exercises: plan.exercises
        )
        try? await saveLog(log)
        weekWorkoutLogs[selectedDate.dateKey] = log
        showConfetti = true
    }

    func postponeWorkout() async {
        guard let plan = selectedPlan else { return }
        let log = WorkoutLog(
            date: selectedDate.dateKey,
            workoutType: plan.type,
            workoutName: plan.name,
            status: .postponed,
            isAutoMissed: false,
            postponedAt: Timestamp(date: Date()),
            exercises: plan.exercises
        )
        try? await saveLog(log)
        weekWorkoutLogs[selectedDate.dateKey] = log
    }

    func markAsCompleted() async {
        guard let existing = selectedLog else { return }
        var updated = existing
        updated.status = .completed
        updated.completedAt = Timestamp(date: Date())
        updated.isAutoMissed = false
        try? await saveLog(updated)
        weekWorkoutLogs[selectedDate.dateKey] = updated
    }

    private func saveLog(_ log: WorkoutLog) async throws {
        try db.document("users/\(uid)/workoutLogs/\(log.date)").setData(from: log, merge: true)
    }
}
