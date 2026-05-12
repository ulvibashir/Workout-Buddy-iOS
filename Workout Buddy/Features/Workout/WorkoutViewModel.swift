import Foundation
import Combine

@MainActor
final class WorkoutViewModel: ObservableObject {

    @Published var workoutDays:      [String: WorkoutDay] = [:]
    @Published var completedDays:    [String: Bool] = [:]
    @Published var selectedDay:      String = ""
    @Published var isLoading:        Bool = true
    @Published var showRestTimer:    Bool = false
    @Published var restDuration:     Int  = 90
    @Published var showCompletionAlert: Bool = false

    private let workoutRepo: WorkoutRepository
    private var tasks: [Task<Void, Never>] = []

    init(container: AppContainer) {
        workoutRepo = container.workoutRepository
        selectedDay = currentDayKey
    }

    var currentDayKey: String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let days = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
        return days[weekday - 1]
    }

    var orderedDays: [String] { AppConstants.Firestore.WeekDays.all }

    var selectedWorkout: WorkoutDay? { workoutDays[selectedDay] }

    var isSelectedDayCompleted: Bool { completedDays[selectedDay] ?? false }

    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [
            Task { await loadWorkoutDays() },
            Task { await listenCompletedDays() }
        ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    func markCompleted() {
        let day = selectedDay
        Task {
            try? await workoutRepo.markDayCompleted(day, completed: true)
            showCompletionAlert = true
        }
    }

    func unmarkCompleted() {
        let day = selectedDay
        Task { try? await workoutRepo.markDayCompleted(day, completed: false) }
    }

    func triggerRestTimer(seconds: Int = 90) {
        restDuration = seconds
        showRestTimer = true
    }

    private func loadWorkoutDays() async {
        workoutDays = (try? await workoutRepo.fetchAllWorkoutDays()) ?? [:]
        isLoading   = false
    }

    private func listenCompletedDays() async {
        for await result in workoutRepo.listenCompletedDays() {
            if case .success(let days) = result { completedDays = days ?? [:] }
        }
    }
}
