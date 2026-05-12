import Foundation
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {

    @Published var metrics:      [BodyMetric] = []
    @Published var goals:        [SixMonthGoal] = []
    @Published var profile:      UserProfile = UserProfile()
    @Published var isLoading:    Bool = true
    @Published var showLogSheet: Bool = false

    // Form state for manual logging
    @Published var formWeight: String = ""
    @Published var formRHR:    String = ""
    @Published var formHRV:    String = ""
    @Published var formVO2Max: String = ""

    private let metricsRepo:  BodyMetricsRepository
    private let runningRepo:  RunningRepository
    private let profileRepo:  ProfileRepository
    private let healthKit:    HealthKitService
    private var tasks: [Task<Void, Never>] = []

    var todayKey: String { Date.todayKey }

    init(container: AppContainer) {
        metricsRepo = container.bodyMetricsRepository
        runningRepo = container.runningRepository
        profileRepo = container.profileRepository
        healthKit   = container.healthKitService
    }

    var sortedMetrics: [BodyMetric] { metrics.sorted { ($0.id ?? "") < ($1.id ?? "") } }
    var latestMetric:  BodyMetric?  { sortedMetrics.last }

    // MARK: - Lifecycle
    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [
            Task { await listenMetrics() },
            Task { await loadGoals() },
            Task { await listenProfile() }
        ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    // MARK: - Save manual metric
    func saveMetric() {
        let metric = BodyMetric(weight: formWeight, rhr: formRHR, hrv: formHRV, vo2max: formVO2Max)
        let date   = todayKey
        showLogSheet = false
        resetForm()
        Task { try? await metricsRepo.save(metric: metric, forDate: date) }
    }

    // MARK: - Sync from HealthKit
    func syncFromHealthKit() {
        Task {
            let metric = await healthKit.buildLatestBodyMetric()
            guard !metric.weight.isEmpty || !metric.rhr.isEmpty || !metric.hrv.isEmpty else { return }
            try? await metricsRepo.save(metric: metric, forDate: todayKey)
        }
    }

    func resetForm() {
        formWeight = ""; formRHR = ""; formHRV = ""; formVO2Max = ""
    }

    // MARK: - Goal progress
    func progress(for goal: SixMonthGoal) -> Double {
        let current = currentValue(for: goal)
        let range   = abs(goal.month6 - goal.start)
        guard range > 0 else { return 0 }
        let moved   = goal.direction == "increase"
            ? current - goal.start
            : goal.start - current
        return max(0, min(1, moved / range))
    }

    private func currentValue(for goal: SixMonthGoal) -> Double {
        let b = profile.baselineMetrics
        switch goal.metric {
        case "Weight (kg)":          return latestMetric?.weightValue ?? b.weight
        case "Resting HR (bpm)":     return latestMetric?.rhrValue    ?? Double(b.rhr)
        case "HRV (ms)":             return latestMetric?.hrvValue     ?? Double(b.hrv)
        case "VO2 Max (ml/kg/min)":  return latestMetric?.vo2maxValue  ?? b.vo2max
        case "Pull-up Max (reps)":   return Double(b.pullUpMax)
        default:                     return goal.start
        }
    }

    // MARK: - Private listeners
    private func listenMetrics() async {
        for await result in metricsRepo.listenAll() {
            if case .success(let items) = result { metrics = items }
            isLoading = false
        }
    }

    private func loadGoals() async {
        goals = (try? await runningRepo.fetchSixMonthGoals()) ?? []
    }

    private func listenProfile() async {
        for await result in profileRepo.listenProfile() {
            if case .success(let p) = result { profile = p ?? UserProfile() }
        }
    }
}
