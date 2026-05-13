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

            ProgressView()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }

            CheatsheetView()
                .tabItem { Label("Guide", systemImage: "book.pages.fill") }
        }
        .environmentObject(container)
        .tint(AppTheme.accent)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(AppTheme.cardBackground)
        }
    }
}

