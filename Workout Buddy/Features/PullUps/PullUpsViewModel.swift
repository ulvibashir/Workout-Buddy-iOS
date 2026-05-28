import Foundation
import FirebaseFirestore

// MARK: - SyncEngine
// Orchestrates all HealthKit → Firebase sync operations.

@MainActor
@Observable
final class SyncEngine {

    // Singleton for background task access
    static let shared = SyncEngine()

    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var syncError: String?
    var backfillProgress: Double = 0

    private let healthKit = HealthKitManager()
    private let db = Firestore.firestore()
    private var uid: String?

    // MARK: - Configure with auth UID

    func configure(uid: String) {
        self.uid = uid
    }

    // MARK: - On App Foreground

    func onAppForeground() async {
        guard let uid else { return }
        await checkMissedWorkouts(uid: uid)
        await syncHealthData(uid: uid)
    }

    // MARK: - Health Data Sync

    func syncHealthData() async {
        guard let uid else { return }
        await syncHealthData(uid: uid)
    }

    private func syncHealthData(uid: String) async {
        isSyncing = true

        if !healthKit.isAuthorized {
            await healthKit.requestAuthorization()
        }

        let today = Date.today
        let dateKey = today.dateKey

        async let hrv      = healthKit.fetchHRV(for: today, rule: .highestOfDay)
        async let rhr      = healthKit.fetchRHR(for: today, rule: .lowestOfDay)
        async let vo2      = healthKit.fetchVO2Max()
        async let sleep    = healthKit.fetchSleep(for: Date.yesterday)
        async let steps    = healthKit.fetchSteps(for: today)
        async let calories = healthKit.fetchActiveCalories(for: today)
        async let weight   = healthKit.fetchWeight()

        let metrics = HealthMetrics(
            date: dateKey,
            hrv: await hrv,
            rhr: await rhr,
            vo2max: await vo2,
            sleepHours: await sleep,
            steps: await steps,
            activeCalories: await calories,
            weight: await weight,
            lastSyncedAt: Timestamp(date: Date()),
            syncSource: "foreground"
        )

        try? await db.document("users/\(uid)/healthMetrics/\(dateKey)")
            .setData(try Firestore.Encoder().encode(metrics), merge: true)

        lastSyncDate = Date()
        isSyncing = false
    }

    // MARK: - Sync specific metric (from background delivery)

    func syncSpecificMetric(_ typeID: String) async {
        await syncHealthData()
    }

    // MARK: - Auto-miss yesterday's workout if still pending

    private func checkMissedWorkouts(uid: String) async {
        let yesterday = Date.yesterday.dateKey
        let ref = db.document("users/\(uid)/workoutLogs/\(yesterday)")

        let snap = try? await ref.getDocument()
        guard let snap, snap.exists else { return }

        let status = snap.data()?["status"] as? String ?? "pending"
        if status == "pending" {
            try? await ref.setData([
                "status": WorkoutStatus.missed.rawValue,
                "isAutoMissed": true,
                "statusChangedAt": Timestamp(date: Date())
            ], merge: true)
        }
    }

    // MARK: - 90-Day Backfill (first launch only)

    func performInitialBackfill() async {
        guard let uid else { return }
        if !healthKit.isAuthorized { await healthKit.requestAuthorization() }
        let days = (0...89).map { Date.today.addingTimeInterval(-Double($0) * 86400) }

        for (index, day) in days.enumerated() {
            await syncDay(day, uid: uid)
            backfillProgress = Double(index + 1) / Double(days.count)
        }
        backfillProgress = 1.0
    }

    private func syncDay(_ day: Date, uid: String) async {
        let dateKey = day.dateKey

        async let hrv      = healthKit.fetchHRV(for: day, rule: .highestOfDay)
        async let rhr      = healthKit.fetchRHR(for: day, rule: .lowestOfDay)
        async let steps    = healthKit.fetchSteps(for: day)
        async let calories = healthKit.fetchActiveCalories(for: day)
        async let sleep    = healthKit.fetchSleep(for: day)

        let metrics = HealthMetrics(
            date: dateKey,
            hrv: await hrv,
            rhr: await rhr,
            sleepHours: await sleep,
            steps: await steps,
            activeCalories: await calories,
            lastSyncedAt: Timestamp(date: Date()),
            syncSource: "backfill"
        )

        try? await db.document("users/\(uid)/healthMetrics/\(dateKey)")
            .setData(try Firestore.Encoder().encode(metrics), merge: true)
    }
}

// MARK: - Date helpers

extension Date {
    static var today: Date { Date() }
    static var yesterday: Date { Date().addingTimeInterval(-86400) }

    var dateKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var dayLetter: String {
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f.string(from: self)
    }

    var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: self)
    }

    var weekdayName: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: self).lowercased()
    }

    static func currentWeekDays() -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }
}
