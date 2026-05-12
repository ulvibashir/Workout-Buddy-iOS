import Foundation

final class ProfileRepository {

    private let service: FirestoreService
    private var profilePath: String { AppConstants.Firestore.path(AppConstants.Firestore.Collections.profile, AppConstants.Firestore.Documents.profileMain) }

    init(service: FirestoreService) {
        self.service = service
    }

    func listenProfile() -> AsyncStream<Result<UserProfile?, AppError>> {
        service.listenDocument(path: profilePath)
    }

    func fetchProfile() async throws -> UserProfile? {
        try await service.fetchDocument(path: profilePath)
    }

    func saveProfile(_ profile: UserProfile) async throws {
        try await service.setDocument(path: profilePath, value: profile)
    }
}
