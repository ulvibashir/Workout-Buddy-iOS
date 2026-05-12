import HealthKit
import Foundation
import Combine

@MainActor
final class HealthKitService: ObservableObject {

    private let store = HKHealthStore()

    @Published var isAuthorized  = false
    @Published var lastSyncDate: Date?

    // MARK: - Authorization
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.vo2Max),
            HKQuantityType(.bodyMass),
            HKQuantityType(.activeEnergyBurned),
            HKObjectType.workoutType()
        ]

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
        } catch {
            isAuthorized = false
        }
    }

    // MARK: - Latest sample queries
    func latestRHR() async -> Double? {
        await latestQuantity(type: .restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
    }

    func latestHRV() async -> Double? {
        await latestQuantity(type: .heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
    }

    func latestVO2Max() async -> Double? {
        // VO2Max in ml/kg/min
        let unit = HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute()))
        return await latestQuantity(type: .vo2Max, unit: unit)
    }

    func latestWeight() async -> Double? {
        await latestQuantity(type: .bodyMass, unit: .gramUnit(with: .kilo))
    }

    // MARK: - Recent running workouts
    func recentRunningWorkouts(limit: Int = 10) async -> [HKWorkout] {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForWorkouts(with: .running)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: limit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            store.execute(query)
        }
    }

    // MARK: - Build BodyMetric from latest HealthKit data
    func buildLatestBodyMetric() async -> BodyMetric {
        async let rhr     = latestRHR()
        async let hrv     = latestHRV()
        async let vo2max  = latestVO2Max()
        async let weight  = latestWeight()

        let (r, h, v, w) = await (rhr, hrv, vo2max, weight)

        return BodyMetric(
            weight: w.map { String(format: "%.1f", $0) } ?? "",
            rhr:    r.map { String(Int($0)) } ?? "",
            hrv:    h.map { String(Int($0)) } ?? "",
            vo2max: v.map { String(format: "%.1f", $0) } ?? ""
        )
    }

    // MARK: - Convert HKWorkout → RunningLog
    func runningLog(from workout: HKWorkout) -> RunningLog {
        let distance   = (workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0)
        let duration   = workout.duration
        let hours      = Int(duration) / 3600
        let minutes    = Int(duration) % 3600 / 60
        let seconds    = Int(duration) % 60
        let timeString = hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%d:%02d", minutes, seconds)

        let paceSecPerKm = distance > 0 ? duration / distance : 0
        let paceMin = Int(paceSecPerKm) / 60
        let paceSec = Int(paceSecPerKm) % 60
        let paceString = String(format: "%d:%02d", paceMin, paceSec)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateKey = df.string(from: workout.startDate)

        return RunningLog(
            date:     dateKey,
            distance: (distance * 10).rounded() / 10,
            time:     timeString,
            avgPace:  paceString,
            avgHR:    0,
            notes:    "Imported from Apple Health",
            runType:  "Easy"
        )
    }

    // MARK: - Private helper
    private func latestQuantity(type: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sampleType = HKQuantityType(type)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
