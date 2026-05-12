import Foundation

final class NutritionRepository {

    private let service: FirestoreService

    init(service: FirestoreService) {
        self.service = service
    }

    // MARK: - Daily log
    func listenLog(date: String) -> AsyncStream<Result<NutritionLog?, AppError>> {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.nutritionLogs, date)
        return service.listenDocument(path: path)
    }

    func saveLog(_ log: NutritionLog, date: String) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.nutritionLogs, date)
        try await service.setDocument(path: path, value: log, merge: false)
    }

    // MARK: - Food database
    func fetchFoodDatabase() async throws -> [FoodItem] {
        struct FoodDoc: Codable { var foods: [FoodItem] }
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.foodDatabase, AppConstants.Firestore.Documents.foodAll)
        let doc: FoodDoc? = try await service.fetchDocument(path: path)
        return doc?.foods ?? []
    }

    // MARK: - Targets
    func fetchTargets() async throws -> NutritionTargets? {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.nutritionConfig, AppConstants.Firestore.Documents.targets)
        return try await service.fetchDocument(path: path)
    }

    // MARK: - Supplements
    func fetchSupplements() async throws -> [Supplement] {
        struct SupDoc: Codable { var items: [Supplement] }
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.nutritionConfig, AppConstants.Firestore.Documents.supplements)
        let doc: SupDoc? = try await service.fetchDocument(path: path)
        return doc?.items ?? []
    }
}
