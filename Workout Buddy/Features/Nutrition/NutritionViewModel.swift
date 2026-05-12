import Foundation
import Combine
import SwiftUI

@MainActor
final class NutritionViewModel: ObservableObject {

    @Published var log:          NutritionLog = NutritionLog(foods: [], water: 0, supplements: [])
    @Published var targets:      NutritionTargets = .default
    @Published var foodDatabase: [FoodItem] = []
    @Published var supplements:  [Supplement] = []
    @Published var isLoading:    Bool = true
    @Published var isTrainingDay: Bool = true

    private let nutritionRepo: NutritionRepository
    private var tasks: [Task<Void, Never>] = []

    var todayKey: String { Date.todayKey }

    init(container: AppContainer) {
        nutritionRepo = container.nutritionRepository
    }

    var activeTargets: NutritionTargets.MacroTarget {
        isTrainingDay ? targets.trainingDays : targets.restDays
    }

    var totalCalories: Double { log.foods.reduce(0) { $0 + $1.calories } }
    var totalProtein:  Double { log.foods.reduce(0) { $0 + $1.protein } }
    var totalCarbs:    Double { log.foods.reduce(0) { $0 + $1.carbs } }
    var totalFats:     Double { log.foods.reduce(0) { $0 + $1.fats } }

    // MARK: - Lifecycle
    func start() {
        tasks.forEach { $0.cancel() }
        tasks = [
            Task { await listenTodayLog() },
            Task { await loadStaticData() }
        ]
    }

    func stop() { tasks.forEach { $0.cancel() }; tasks = [] }

    // MARK: - Mutations
    func addFood(_ food: FoodItem, servings: Double) {
        let entry = food.loggedFood(servings: servings)
        log.foods.append(entry)
        saveLog()
    }

    func removeFood(at offsets: IndexSet) {
        log.foods.remove(atOffsets: offsets)
        saveLog()
    }

    func addWater(ml: Int = 250) { log.water += ml; saveLog() }
    func removeWater(ml: Int = 250) { log.water = max(0, log.water - ml); saveLog() }

    func toggleSupplement(_ name: String) {
        if log.supplements.contains(name) {
            log.supplements.removeAll { $0 == name }
        } else {
            log.supplements.append(name)
        }
        saveLog()
    }

    // MARK: - Private
    private func listenTodayLog() async {
        for await result in nutritionRepo.listenLog(date: todayKey) {
            if case .success(let l) = result {
                log = l ?? NutritionLog(foods: [], water: 0, supplements: [])
            }
            isLoading = false
        }
    }

    private func loadStaticData() async {
        async let tResult = nutritionRepo.fetchTargets()
        async let fResult = nutritionRepo.fetchFoodDatabase()
        async let sResult = nutritionRepo.fetchSupplements()
        do {
            let (t, f, s) = try await (tResult, fResult, sResult)
            targets      = t ?? .default
            foodDatabase = f
            supplements  = s
        } catch {}
    }

    private func saveLog() {
        let log  = self.log
        let date = todayKey
        Task { try? await nutritionRepo.saveLog(log, date: date) }
    }
}
