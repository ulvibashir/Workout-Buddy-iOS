import Foundation
import FirebaseFirestore
import Combine

// MARK: - App Container
// Lightweight DI container — kept for backward compatibility with any remaining old references.
// New code uses @Observable ViewModels created directly with uid from AuthViewModel.

@MainActor
final class AppContainer: ObservableObject {

    let firestoreService: FirestoreService
    let healthKitService: HealthKitManager

    // Legacy repositories (kept to prevent compile errors during migration)
    let workoutRepository: WorkoutRepository
    let profileRepository: ProfileRepository
    let bodyMetricsRepository: BodyMetricsRepository
    let nutritionRepository: NutritionRepository
    let pullUpRepository: PullUpRepository
    let runningRepository: RunningRepository

    init() {
        let db = Firestore.firestore()
        firestoreService      = FirestoreService(db: db)
        healthKitService      = HealthKitManager()
        workoutRepository     = WorkoutRepository(service: firestoreService)
        profileRepository     = ProfileRepository(service: firestoreService)
        bodyMetricsRepository = BodyMetricsRepository(service: firestoreService)
        nutritionRepository   = NutritionRepository(service: firestoreService)
        pullUpRepository      = PullUpRepository(service: firestoreService)
        runningRepository     = RunningRepository(service: firestoreService)
    }
}
