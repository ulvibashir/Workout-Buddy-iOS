import SwiftUI
import FirebaseCore

// MARK: - App Entry Point
// This file was previously SceneDelegate — repurposed as the SwiftUI App entry point.

@main
struct WorkoutBuddyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authViewModel: AuthViewModel
    @State private var syncEngine: SyncEngine
    @State private var networkMonitor: NetworkMonitor
    @AppStorage("colorSchemePreference") private var colorSchemeRaw: String = "System"

    init() {
        FirebaseApp.configure()
        _authViewModel = State(initialValue: AuthViewModel())
        _syncEngine = State(initialValue: SyncEngine())
        _networkMonitor = State(initialValue: NetworkMonitor())
    }

    private var preferredColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "Light": return .light
        case "Dark":  return .dark
        default:      return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authViewModel)
                .environment(syncEngine)
                .environment(networkMonitor)
                .preferredColorScheme(preferredColorScheme)
        }
    }
}
