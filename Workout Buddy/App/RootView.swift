import SwiftUI

struct RootView: View {
    @StateObject private var container = AppContainer()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            WorkoutView()
                .tabItem { Label("Workout", systemImage: "dumbbell.fill") }

            NutritionView()
                .tabItem { Label("Nutrition", systemImage: "fork.knife") }

            TrainView()
                .tabItem { Label("Train", systemImage: "figure.strengthtraining.traditional") }

            ProgressView()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .environmentObject(container)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accent)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(AppTheme.cardBackground)
        }
    }
}

// Train tab wraps Running and Pull-ups in a NavigationStack
struct TrainView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { PullUpsView() } label: {
                        Label("Pull-ups", systemImage: "figure.strengthtraining.traditional")
                    }
                    NavigationLink { RunningView() } label: {
                        Label("Running", systemImage: "figure.run")
                    }
                }
            }
            .navigationTitle("Train")
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
        }
    }
}
