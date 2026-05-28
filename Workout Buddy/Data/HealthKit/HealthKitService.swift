import HealthKit
import Foundation

// MARK: - HealthKit Query Rules

enum HealthDataRule {
    case lowestOfDay
    case highestOfDay
    case latestValue
    case sumOfDay
    case lastNightSleep
    case latestSample
}

// MARK: - HealthKitManager

final class HealthKitManager {

    private let store = HKHealthStore()
    private(set) var isAuthorized = false

    // MARK: - Authorization

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.workoutType(),
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
        ]
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            return false
        }
    }

    // MARK: - HRV

    func fetchHRV(for date: Date, rule: HealthDataRule = .highestOfDay) async -> Double? {
        await fetchQuantity(
            type: .heartRateVariabilitySDNN,
            unit: .secondUnit(with: .milli),
            date: date,
            rule: rule
        )
    }

    // MARK: - RHR

    func fetchRHR(for date: Date, rule: HealthDataRule = .lowestOfDay) async -> Double? {
        await fetchQuantity(
            type: .restingHeartRate,
            unit: HKUnit.count().unitDivided(by: .minute()),
            date: date,
            rule: rule
        )
    }

    // MARK: - VO2 Max

    func fetchVO2Max() async -> Double? {
        await fetchLatestQuantity(
            type: .vo2Max,
            unit: HKUnit.literUnit(with: .milli)
                .unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute()))
        )
    }

    // MARK: - Steps

    func fetchSteps(for date: Date) async -> Int? {
        let val = await fetchSum(type: .stepCount, unit: .count(), date: date)
        return val.map { Int($0) }
    }

    // MARK: - Active Calories

    func fetchActiveCalories(for date: Date) async -> Double? {
        await fetchSum(type: .activeEnergyBurned, unit: .kilocalorie(), date: date)
    }

    // MARK: - Weight

    func fetchWeight() async -> Double? {
        await fetchLatestQuantity(type: .bodyMass, unit: .gramUnit(with: .kilo))
    }

    // MARK: - Sleep

    func fetchSleep(for date: Date) async -> Double? {
        await withCheckedContinuation { continuation in
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            // Look back: sleep from day before to capture nighttime sleep
            let sleepStart = Calendar.current.date(byAdding: .hour, value: -8, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: sleepStart, end: endOfDay)
            let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let query = HKSampleQuery(
                sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil); return
                }
                let asleep = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                    $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                    $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                    $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
                let totalSeconds = asleep.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: totalSeconds > 0 ? totalSeconds / 3600 : nil)
            }
            store.execute(query)
        }
    }

    // MARK: - Running Workouts

    func fetchRecentRunningWorkouts(limit: Int = 10) async -> [HKWorkout] {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForWorkouts(with: .running)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate, limit: limit, sortDescriptors: [sort]
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            store.execute(query)
        }
    }

    // MARK: - Background Delivery

    func registerBackgroundDelivery(syncEngine: SyncEngine) {
        let types: [HKQuantityTypeIdentifier] = [
            .heartRateVariabilitySDNN, .restingHeartRate, .vo2Max, .bodyMass,
            .stepCount, .activeEnergyBurned
        ]
        for typeID in types {
            guard let type = HKObjectType.quantityType(forIdentifier: typeID) else { continue }
            store.enableBackgroundDelivery(for: type, frequency: .immediate) { success, _ in
                guard success else { return }
                self.store.execute(HKObserverQuery(sampleType: type, predicate: nil) { _, handler, _ in
                    Task {
                        await syncEngine.syncSpecificMetric(typeID.rawValue)
                        handler()
                    }
                })
            }
        }
    }

    // MARK: - Convert HKWorkout → RunningLog

    func runningLog(from workout: HKWorkout) -> RunningLog {
        let distance = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
        let duration = Int(workout.duration)
        let paceSecPerKm = distance > 0 ? workout.duration / distance : 0
        let paceMin = Int(paceSecPerKm) / 60
        let paceSec = Int(paceSecPerKm) % 60
        let paceString = String(format: "%d:%02d", paceMin, paceSec)
        return RunningLog(
            date: workout.startDate.dateKey,
            distance: (distance * 10).rounded() / 10,
            duration: duration,
            avgPace: paceString,
            source: "healthkit"
        )
    }

    // MARK: - Private helpers

    private func fetchQuantity(
        type: HKQuantityTypeIdentifier, unit: HKUnit,
        date: Date, rule: HealthDataRule
    ) async -> Double? {
        switch rule {
        case .highestOfDay: return await fetchHighestInDay(type: type, unit: unit, date: date)
        case .lowestOfDay:  return await fetchLowestInDay(type: type, unit: unit, date: date)
        case .sumOfDay:     return await fetchSum(type: type, unit: unit, date: date)
        default:            return await fetchLatestQuantity(type: type, unit: unit)
        }
    }

    private func fetchHighestInDay(type: HKQuantityTypeIdentifier, unit: HKUnit, date: Date) async -> Double? {
        let samples = await fetchDaySamples(type: type, date: date)
        return samples.map { $0.quantity.doubleValue(for: unit) }.max()
    }

    private func fetchLowestInDay(type: HKQuantityTypeIdentifier, unit: HKUnit, date: Date) async -> Double? {
        let samples = await fetchDaySamples(type: type, date: date)
        return samples.map { $0.quantity.doubleValue(for: unit) }.min()
    }

    private func fetchDaySamples(type: HKQuantityTypeIdentifier, date: Date) async -> [HKQuantitySample] {
        await withCheckedContinuation { continuation in
            let start = Calendar.current.startOfDay(for: date)
            let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            let pred  = HKQuery.predicateForSamples(withStart: start, end: end)
            let sort  = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: HKQuantityType(type), predicate: pred,
                limit: HKObjectQueryNoLimit, sortDescriptors: [sort]
            ) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            store.execute(query)
        }
    }

    private func fetchLatestQuantity(type: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: HKQuantityType(type), predicate: nil, limit: 1, sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func fetchSum(type: HKQuantityTypeIdentifier, unit: HKUnit, date: Date) async -> Double? {
        await withCheckedContinuation { continuation in
            let start = Calendar.current.startOfDay(for: date)
            let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            let pred  = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(type), quantitySamplePredicate: pred, options: .cumulativeSum
            ) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }
}

// MARK: - Backward compatible HealthKitService alias
typealias HealthKitService = HealthKitManager
