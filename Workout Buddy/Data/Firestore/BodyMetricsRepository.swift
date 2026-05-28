import Foundation

final class BodyMetricsRepository {

    private let service: FirestoreService

    init(service: FirestoreService) {
        self.service = service
    }

    func listenAll() -> AsyncStream<Result<[HealthMetrics], AppError>> {
        let path = "\(AppConstants.Firestore.userRoot)/\(AppConstants.Firestore.Collections.bodyMetrics)"
        return service.listenCollection(path: path)
    }

    func save(metric: HealthMetrics, forDate date: String) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.bodyMetrics, date)
        try await service.setDocument(path: path, value: metric)
    }

    func delete(date: String) async throws {
        let path = AppConstants.Firestore.path(AppConstants.Firestore.Collections.bodyMetrics, date)
        try await service.deleteDocument(path: path)
    }
}
