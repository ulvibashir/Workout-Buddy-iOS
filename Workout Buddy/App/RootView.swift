import SwiftUI

struct RootView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var splashVisible = true

    var body: some View {
        ZStack {
            contentView
            if splashVisible || authViewModel.state == .loading {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: authViewModel.state)
        .task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.6)) {
                splashVisible = false
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch authViewModel.state {
        case .loading:
            Color.appBackground.ignoresSafeArea()
        case .unauthenticated:
            OnboardingFlow()
        case .authenticated:
            MainTabView()
        }
    }
}

// MARK: - Splash View

struct SplashView: View {
    @State private var appeared = false
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: Spacing.md) {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.container)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(.enduranceLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                    )
                    .scaleEffect(appeared ? (isPulsing ? 1.05 : 0.97) : 0.6)
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                Text("Workout Buddy")
                    .font(.appTitle1)
                    .foregroundStyle(Color.appTextPrimary)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
            }
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                    appeared = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isPulsing = true
                }
            }
        }
    }
}
