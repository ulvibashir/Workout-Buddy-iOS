import Foundation
import Combine
import SwiftUI

@MainActor
final class PullUpsViewModel: ObservableObject {

    @Published var logs:          [PullUpLog] = []
    @Published var program:       PullUpProgram?
    @Published var currentSets:   [Int] = []
    @Published var isLoading:     Bool = true
    @Published var showAddSheet:  Bool = false
    @Published var setInput:      String = ""

    private let pullUpRepo: PullUpRepository
    private let healthKit:  HealthKitService
    private var tasks: [Task<Void, Never>] = []

    var todayKey: String { Date.todayKey }

    init(container: AppContainer) {
        pullUpRepo = container.pullUpRepository
        healthKit  = container.healthKitService
    }

    var sortedLogs: [PullUpLog] {
        logs.sorted { ($0.id ?? "") > ($1.id ?? "") }
    }

    var allTimeMax: Int {
        logs.map(\.maxReps).max() ?? (program?.currentMax ?? 12)
    }

    var weekTotal: Int {
        let cal = Calendar.current
        return logs.filter {
            guard let id = $0.id,
                  let date = DateFormatter.yyyyMMdd.date(from: id)
            else { return false }
            return cal.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        }.reduce(0) { $0 + $1.totalReps }
    }

    // MARK: - Lifecycle
    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [
            Task { await listenLogs() },
            Task { await loadProgram() }
        ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    // MARK: - Session management
    func addSet() {
        guard let reps = Int(setInput), reps > 0 else { return }
        currentSets.append(reps)
        setInput = ""
    }

    func removeSet(at offsets: IndexSet) {
        currentSets.remove(atOffsets: offsets)
    }

    func saveSession() {
        guard !currentSets.isEmpty else { return }
        let log = PullUpLog(
            sets:      currentSets,
            maxReps:   currentSets.max() ?? 0,
            totalReps: currentSets.reduce(0, +)
        )
        let date = todayKey
        currentSets   = []
        showAddSheet  = false
        Task { try? await pullUpRepo.saveSession(log, date: date) }
    }

    // MARK: - Private
    private func listenLogs() async {
        for await result in pullUpRepo.listenAll() {
            if case .success(let items) = result { logs = items }
            isLoading = false
        }
    }

    private func loadProgram() async {
        program = try? await pullUpRepo.fetchProgram()
    }
}

