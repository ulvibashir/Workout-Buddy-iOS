import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var profile:       UserProfile = UserProfile()
    @Published var isLoading:     Bool = true
    @Published var showClearAlert: Bool = false
    @Published var isSyncing:     Bool = false
    @Published var syncMessage:   String?

    private let profileRepo:  ProfileRepository
    private let healthKit:    HealthKitService
    private let metricsRepo:  BodyMetricsRepository
    private var tasks: [Task<Void, Never>] = []

    init(container: AppContainer) {
        profileRepo = container.profileRepository
        healthKit   = container.healthKitService
        metricsRepo = container.bodyMetricsRepository
    }

    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [ Task { await listenProfile() } ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    // MARK: - Save profile changes
    func saveProfile() {
        let p = profile
        Task { try? await profileRepo.saveProfile(p) }
    }

    // MARK: - HealthKit sync
    func syncHealthKit() {
        isSyncing = true
        Task {
            let metric = await healthKit.buildLatestBodyMetric()
            if !metric.weight.isEmpty || !metric.rhr.isEmpty {
                try? await metricsRepo.save(metric: metric, forDate: Date.todayKey)
                syncMessage = "Synced latest data from Apple Health."
            } else {
                syncMessage = "No new data found in Apple Health."
            }
            isSyncing = false
        }
    }

    // MARK: - Private
    private func listenProfile() async {
        for await result in profileRepo.listenProfile() {
            if case .success(let p) = result { profile = p ?? UserProfile() }
            isLoading = false
        }
    }
}
