import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class AppContainer: ObservableObject {

    // MARK: - Services
    let firestoreService: FirestoreService
    let healthKitService: HealthKitService

    // MARK: - Repositories
    let profileRepository: ProfileRepository
    let workoutRepository: WorkoutRepository
    let bodyMetricsRepository: BodyMetricsRepository
    let nutritionRepository: NutritionRepository
    let pullUpRepository: PullUpRepository
    let runningRepository: RunningRepository

    init() {
        let db = Firestore.firestore()
        firestoreService       = FirestoreService(db: db)
        healthKitService       = HealthKitService()
        profileRepository      = ProfileRepository(service: firestoreService)
        workoutRepository      = WorkoutRepository(service: firestoreService)
        bodyMetricsRepository  = BodyMetricsRepository(service: firestoreService)
        nutritionRepository    = NutritionRepository(service: firestoreService)
        pullUpRepository       = PullUpRepository(service: firestoreService)
        runningRepository      = RunningRepository(service: firestoreService)

        Task { await healthKitService.requestAuthorization() }
        let seeder = DataSeeder(db: db)
        Task { await seeder.seedIfNeeded() }
    }
}
