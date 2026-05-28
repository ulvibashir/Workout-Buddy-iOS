import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {

    var profile: UserProfile = UserProfile()
    var healthWeight: Double? = nil
    var isLoading: Bool = false
    var isSyncing: Bool = false
    var lastSyncDate: Date? = nil
    var showSignOutAlert: Bool = false

    @ObservationIgnored
    @AppStorage("colorSchemePreference") var colorSchemePreferenceRaw: String = "System"

    var colorSchemePreference: ColorSchemePreference {
        get { ColorSchemePreference(rawValue: colorSchemePreferenceRaw) ?? .system }
        set { colorSchemePreferenceRaw = newValue.rawValue }
    }

    enum ColorSchemePreference: String, CaseIterable {
        case system = "System"
        case light  = "Light"
        case dark   = "Dark"

        var colorScheme: ColorScheme? {
            switch self {
            case .light:  return .light
            case .dark:   return .dark
            case .system: return nil
            }
        }
    }

    private let db = Firestore.firestore()
    private var uid: String

    init(uid: String) {
        self.uid = uid
    }

    func loadProfile() async {
        isLoading = true
        async let profileSnap = db.document("users/\(uid)/profile/main").getDocument(as: UserProfile.self)
        async let metricsSnap = db.document("users/\(uid)/healthMetrics/\(Date.today.dateKey)").getDocument(as: HealthMetrics.self)
        profile = (try? await profileSnap) ?? UserProfile()
        let metrics = try? await metricsSnap
        healthWeight = metrics?.weight
        lastSyncDate = metrics?.lastSyncedAt?.dateValue()
        isLoading = false
    }

    func saveProfile(_ updated: UserProfile) async {
        try? db.document("users/\(uid)/profile/main").setData(from: updated, merge: true)
        profile = updated
    }

    func syncNow(syncEngine: SyncEngine) async {
        isSyncing = true
        await syncEngine.syncHealthData()
        let metrics = try? await db.document("users/\(uid)/healthMetrics/\(Date.today.dateKey)").getDocument(as: HealthMetrics.self)
        healthWeight = metrics?.weight
        lastSyncDate = Date()
        isSyncing = false
    }
}
