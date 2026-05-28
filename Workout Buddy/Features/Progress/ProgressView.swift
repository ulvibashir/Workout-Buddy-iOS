import SwiftUI
import Combine

// MARK: - Onboarding Flow
// This file was ProgressView.swift — repurposed as the full onboarding flow.

struct OnboardingFlow: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var step: OnboardingStep = .welcome
    @State private var profile = UserProfile()

    enum OnboardingStep {
        case welcome, signIn, healthPermission, profileSetup, backfill
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            switch step {
            case .welcome:
                WelcomeView { step = .signIn }
            case .signIn:
                SignInView(onBack: { step = .welcome }) {
                    step = .healthPermission
                }
            case .healthPermission:
                HealthPermissionView(onSkip: { step = .profileSetup }) {
                    step = .profileSetup
                }
            case .profileSetup:
                ProfileSetupView(profile: $profile) {
                    step = .backfill
                }
            case .backfill:
                BackfillProgressView {
                    // Completion handled by authViewModel state change
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }
}

// MARK: - Welcome Screen

struct WelcomeView: View {
    let onGetStarted: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.appSurface],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.appPrimary)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(y: appeared ? 0 : -40)
                    .opacity(appeared ? 1 : 0)

                VStack(spacing: Spacing.xs) {
                    Text("Workout Buddy")
                        .font(.appTitle1)
                        .foregroundStyle(Color.appTextPrimary)
                        .opacity(appeared ? 1 : 0)

                    Text("Your personal hybrid athlete companion")
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                }

                Spacer()

                VStack(spacing: Spacing.md) {
                    Button("Get Started", action: onGetStarted)
                        .buttonStyle(PrimaryButtonStyle(color: .appPrimary))
                        .padding(.horizontal, Spacing.xxl)
                        .offset(y: appeared ? 0 : 40)
                        .opacity(appeared ? 1 : 0)

                    Text("By continuing you agree to our Privacy Policy")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                        .opacity(appeared ? 1 : 0)
                }
                .padding(.bottom, Spacing.xxxl)
            }
            .padding(.horizontal, Spacing.md)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Sign In Screen

struct SignInView: View {
    let onBack: () -> Void
    let onSuccess: () -> Void
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            // Nav
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.appHeadline)
                        .foregroundStyle(Color.appTextPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.xl)

            Spacer()

            VStack(spacing: Spacing.md) {
                VStack(spacing: Spacing.xs) {
                    Text("Sign In")
                        .font(.appTitle1)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Sync your data across all devices")
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }

                if let error = authViewModel.error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                    }
                    .font(.appFootnote)
                    .foregroundStyle(.white)
                    .padding(Spacing.md)
                    .background(Color.appDanger)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .padding(.horizontal, Spacing.md)
                }

                Button {
                    isLoading = true
                    Task {
                        await authViewModel.signInWithGoogle()
                        isLoading = false
                        if authViewModel.state.isAuthenticated { onSuccess() }
                    }
                } label: {
                    HStack(spacing: Spacing.sm) {
                        if isLoading {
                            ProgressView().tint(.appTextPrimary)
                        } else {
                            Image(systemName: "globe")
                                .font(.appHeadline)
                            Text("Continue with Google")
                                .font(.appHeadline)
                        }
                    }
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                }
                .padding(.horizontal, Spacing.xxl)
                .disabled(isLoading)
            }

            Spacer()
        }
        .background(Color.appBackground)
    }
}

// MARK: - Health Permission Screen

struct HealthPermissionView: View {
    let onSkip: () -> Void
    let onContinue: () -> Void
    @State private var appeared = false
    private let healthKit = HealthKitManager()

    private let permissions: [(String, String)] = [
        ("heart.fill", "Heart Rate Variability"),
        ("heart.fill", "Resting Heart Rate"),
        ("lungs.fill", "VO2 Max"),
        ("moon.stars.fill", "Sleep Analysis"),
        ("figure.walk", "Steps & Activity"),
        ("scalemass.fill", "Body Weight"),
        ("figure.run", "Workouts"),
    ]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.xs) {
                Text("Connect Health")
                    .font(.appTitle1)
                    .foregroundStyle(Color.appTextPrimary)
                Text("Allow Workout Buddy to read your health data")
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.xxxl)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(permissions.indices, id: \.self) { index in
                    let (icon, label) = permissions[index]
                    HStack(spacing: Spacing.md) {
                        Image(systemName: icon)
                            .foregroundStyle(Color.appPrimary)
                            .frame(width: 24)
                        Text(label)
                            .font(.appBody)
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appSuccess)
                    }
                    .padding(Spacing.md)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                    .offset(x: appeared ? 0 : 40)
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        .spring(response: 0.4).delay(Double(index) * 0.06),
                        value: appeared
                    )
                }
            }
            .padding(.horizontal, Spacing.md)

            Spacer()

            VStack(spacing: Spacing.sm) {
                Button("Continue") {
                    Task {
                        await healthKit.requestAuthorization()
                        onContinue()
                    }
                }
                .buttonStyle(PrimaryButtonStyle(color: .appPrimary))
                .padding(.horizontal, Spacing.xxl)

                Button("Skip for now", action: onSkip)
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color.appBackground)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// MARK: - Profile Setup Screen

struct ProfileSetupView: View {
    @Binding var profile: UserProfile
    let onContinue: () -> Void
    @State private var name = "Ulvi"
    @State private var selectedGoals: Set<String> = ["hybrid_athlete", "hyrox", "ironman"]

    private let goals: [(String, String, String)] = [
        ("hybrid_athlete", "🏋️", "Hybrid Athlete"),
        ("hyrox", "💪", "HYROX"),
        ("ironman", "🏊", "Ironman"),
        ("marathon", "🏃", "Marathon"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.xs) {
                    Text("Tell us about you")
                        .font(.appTitle1)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .padding(.top, Spacing.xxxl)

                VStack(spacing: Spacing.md) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Your name")
                            .font(.appFootnote)
                            .foregroundStyle(Color.appTextSecondary)
                        TextField("Your name", text: $name)
                            .font(.appBody)
                            .padding(Spacing.md)
                            .background(Color.appSurface)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Goals")
                            .font(.appFootnote)
                            .foregroundStyle(Color.appTextSecondary)
                        ForEach(goals, id: \.0) { id, emoji, label in
                            Button {
                                if selectedGoals.contains(id) {
                                    selectedGoals.remove(id)
                                } else {
                                    selectedGoals.insert(id)
                                }
                            } label: {
                                HStack {
                                    Text(emoji + " " + label)
                                        .font(.appBody)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Spacer()
                                    if selectedGoals.contains(id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(
                                    selectedGoals.contains(id)
                                        ? Color.appPrimary.opacity(0.1)
                                        : Color.appSurface
                                )
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .stroke(
                                            selectedGoals.contains(id) ? Color.appPrimary : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)

                Button("Continue") {
                    profile.name = name.isEmpty ? "Ulvi" : name
                    profile.goals = Array(selectedGoals)
                    onContinue()
                }
                .buttonStyle(PrimaryButtonStyle(color: .appPrimary))
                .padding(.horizontal, Spacing.xxl)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .background(Color.appBackground)
    }
}

// MARK: - Backfill Progress Screen

struct BackfillProgressView: View {
    let onComplete: () -> Void
    @Environment(SyncEngine.self) private var syncEngine
    @State private var isDone = false
    @State private var currentMessage = "Reading heart rate data..."

    private let messages = [
        "Reading heart rate data...",
        "Fetching sleep history...",
        "Loading workout records...",
        "Syncing steps and calories...",
        "Almost done...",
    ]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            VStack(spacing: Spacing.md) {
                Text("Syncing your history")
                    .font(.appTitle1)
                    .foregroundStyle(Color.appTextPrimary)
                Text("This only happens once")
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }

            ZStack {
                Circle()
                    .stroke(Color.appSurfaceRaised, lineWidth: 12)
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: isDone ? 1 : syncEngine.backfillProgress)
                    .stroke(isDone ? Color.appSuccess : Color.appPrimary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: syncEngine.backfillProgress)

                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appSuccess)
                } else {
                    VStack(spacing: 4) {
                        Text("\(Int(syncEngine.backfillProgress * 100))%")
                            .font(.appMetricSmall)
                            .foregroundStyle(Color.appTextPrimary)
                            .contentTransition(.numericText())
                    }
                }
            }

            Text(isDone ? "All done! 🎉" : currentMessage)
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
                .animation(.easeInOut, value: isDone)

            Spacer()
        }
        .background(Color.appBackground)
        .task {
            await syncEngine.performInitialBackfill()
            withAnimation { isDone = true }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            onComplete()
        }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
            guard !isDone else { return }
            currentMessage = messages.randomElement() ?? messages[0]
        }
    }
}
