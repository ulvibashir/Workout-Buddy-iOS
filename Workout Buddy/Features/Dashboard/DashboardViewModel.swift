import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var profile:       UserProfile = UserProfile()
    @Published var workoutDays:   [String: WorkoutDay] = [:]
    @Published var completedDays: [String: Bool] = [:]
    @Published var bodyMetrics:   [BodyMetric] = []
    @Published var runLogs:       [RunningLog] = []
    @Published var pullUpLogs:    [PullUpLog] = []
    @Published var quotes:        [String] = []
    @Published var isLoading:     Bool = true

    private let profileRepo:   ProfileRepository
    private let workoutRepo:   WorkoutRepository
    private let metricsRepo:   BodyMetricsRepository
    private let runningRepo:   RunningRepository
    private let pullUpRepo:    PullUpRepository

    // Cancellation handles for listeners
    private var tasks: [Task<Void, Never>] = []

    init(container: AppContainer) {
        profileRepo = container.profileRepository
        workoutRepo = container.workoutRepository
        metricsRepo = container.bodyMetricsRepository
        runningRepo = container.runningRepository
        pullUpRepo  = container.pullUpRepository
    }

    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [
            Task { await listenProfile() },
            Task { await listenCompletedDays() },
            Task { await listenBodyMetrics() },
            Task { await listenRunLogs() },
            Task { await listenPullUpLogs() },
            Task { await loadWorkoutDays() },
            Task { await loadQuotes() }
        ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    // MARK: - Computed
    var todayKey: String { Date.todayKey }

    var currentDayKey: String {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date())
        let days = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
        return days[weekday - 1]
    }

    var todayWorkout: WorkoutDay? { workoutDays[currentDayKey] }

    var latestMetric: BodyMetric? {
        bodyMetrics.sorted { ($0.id ?? "") > ($1.id ?? "") }.first
    }

    var recentRuns: [RunningLog] {
        runLogs.sorted { $0.date > $1.date }.prefix(3).map { $0 }
    }

    var recentPullUps: [PullUpLog] {
        pullUpLogs.sorted { ($0.id ?? "") > ($1.id ?? "") }.prefix(3).map { $0 }
    }

    var allTimeMaxPullUp: Int {
        pullUpLogs.map(\.maxReps).max() ?? profile.baselineMetrics.pullUpMax
    }

    var totalRunKm: Double {
        runLogs.reduce(0) { $0 + $1.distance }
    }

    var completedThisWeek: Int {
        completedDays.values.filter { $0 }.count
    }

    var todayQuote: String {
        guard !quotes.isEmpty else { return "Train hard, recover harder." }
        let day = Calendar.current.component(.day, from: Date())
        return quotes[day % quotes.count]
    }

    // MARK: - Private listeners
    private func listenProfile() async {
        for await result in profileRepo.listenProfile() {
            switch result {
            case .success(let p): profile = p ?? UserProfile()
            case .failure: break
            }
            isLoading = false
        }
    }

    private func listenCompletedDays() async {
        for await result in workoutRepo.listenCompletedDays() {
            if case .success(let days) = result { completedDays = days ?? [:] }
        }
    }

    private func listenBodyMetrics() async {
        for await result in metricsRepo.listenAll() {
            if case .success(let items) = result { bodyMetrics = items }
        }
    }

    private func listenRunLogs() async {
        for await result in runningRepo.listenAll() {
            if case .success(let items) = result { runLogs = items }
        }
    }

    private func listenPullUpLogs() async {
        for await result in pullUpRepo.listenAll() {
            if case .success(let items) = result { pullUpLogs = items }
        }
    }

    private func loadWorkoutDays() async {
        workoutDays = (try? await workoutRepo.fetchAllWorkoutDays()) ?? [:]
    }

    private func loadQuotes() async {
        quotes = (try? await workoutRepo.fetchQuotes()) ?? []
    }
}
