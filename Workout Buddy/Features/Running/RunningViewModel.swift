import Foundation
import Combine
import HealthKit

@MainActor
final class RunningViewModel: ObservableObject {

    @Published var runs:         [RunningLog] = []
    @Published var isLoading:    Bool = true
    @Published var showAddSheet: Bool = false
    @Published var editRun:      RunningLog?
    @Published var isImporting:  Bool = false
    @Published var importMessage: String?

    // Form state
    @Published var formDate:     String = Date.todayKey
    @Published var formDistance: String = ""
    @Published var formTime:     String = ""
    @Published var formPace:     String = ""
    @Published var formHR:       String = ""
    @Published var formNotes:    String = ""
    @Published var formType:     String = "Easy"

    let runTypes = ["Easy", "Tempo", "Long", "Intervals", "Race", "Recovery"]

    private let runningRepo: RunningRepository
    private let healthKit:   HealthKitService
    private var tasks: [Task<Void, Never>] = []

    init(container: AppContainer) {
        runningRepo = container.runningRepository
        healthKit   = container.healthKitService
    }

    var sortedRuns: [RunningLog] { runs.sorted { $0.date > $1.date } }
    var totalKm: Double { runs.reduce(0) { $0 + $1.distance } }

    var longestRun: RunningLog? { runs.max(by: { $0.distance < $1.distance }) }
    var fastestPace: RunningLog? {
        runs.filter { !$0.avgPace.isEmpty }.min { lhs, rhs in
            pace(lhs.avgPace) < pace(rhs.avgPace)
        }
    }

    // MARK: - Lifecycle
    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [ Task { await listenRuns() } ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    // MARK: - CRUD
    func saveRun() {
        guard let distance = Double(formDistance) else { return }
        let id  = formDate + "-" + UUID().uuidString.prefix(6)
        let log = RunningLog(
            id:       String(id),
            date:     formDate,
            distance: distance,
            time:     formTime,
            avgPace:  formPace,
            avgHR:    Int(formHR) ?? 0,
            notes:    formNotes,
            runType:  formType
        )
        showAddSheet = false
        resetForm()
        Task { try? await runningRepo.saveRun(log, id: String(id)) }
    }

    func deleteRun(_ log: RunningLog) {
        guard let id = log.id else { return }
        Task { try? await runningRepo.deleteRun(id: id) }
    }

    // MARK: - HealthKit import
    func importFromHealthKit() {
        isImporting = true
        Task {
            let workouts = await healthKit.recentRunningWorkouts(limit: 20)
            var imported = 0
            for workout in workouts {
                let log = healthKit.runningLog(from: workout)
                let id  = log.date + "-hk-" + workout.uuid.uuidString.prefix(6)
                try? await runningRepo.saveRun(log, id: String(id))
                imported += 1
            }
            isImporting   = false
            importMessage = imported > 0 ? "Imported \(imported) runs from Apple Health." : "No new runs found."
        }
    }

    func resetForm() {
        formDate = Date.todayKey; formDistance = ""; formTime = ""; formPace = ""
        formHR   = ""; formNotes = ""; formType = "Easy"
    }

    // MARK: - Private
    private func listenRuns() async {
        for await result in runningRepo.listenAll() {
            if case .success(let items) = result { runs = items }
            isLoading = false
        }
    }

    private func pace(_ paceStr: String) -> Int {
        let parts = paceStr.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return Int.max }
        return parts[0] * 60 + parts[1]
    }
}
