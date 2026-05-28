import Foundation
import Combine

// Running is now tracked automatically via HealthKit sync in SyncEngine.
// This stub is kept so that any remaining old references compile cleanly.
@MainActor
final class RunningViewModel: ObservableObject {
    @Published var runs: [RunningLog] = []
}
