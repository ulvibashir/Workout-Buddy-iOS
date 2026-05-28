import SwiftUI

// MARK: - Main Tab View
// This file was ViewController.swift — repurposed as the root tab container.

struct MainTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SyncEngine.self) private var syncEngine
    @Environment(NetworkMonitor.self) private var networkMonitor

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar.fill")
                    }

                WorkoutView()
                    .tabItem {
                        Label("Workout", systemImage: "dumbbell.fill")
                    }

                NutritionView()
                    .tabItem {
                        Label("Nutrition", systemImage: "fork.knife")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .tint(Color.appPrimary)

            if !networkMonitor.isConnected {
                OfflineBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(), value: networkMonitor.isConnected)
        .task {
            guard let uid = authViewModel.currentUID else { return }
            syncEngine.configure(uid: uid)
            await DataSeeder(uid: uid).seedIfNeeded()
            await syncEngine.onAppForeground()
        }
    }
}
