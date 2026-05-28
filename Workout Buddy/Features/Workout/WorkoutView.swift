import SwiftUI

struct WorkoutView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var vm: WorkoutViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    WorkoutContent(vm: vm)
                } else {
                    loadingContent
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.appBackground.ignoresSafeArea())
        }
        .task {
            guard vm == nil, let uid = authViewModel.currentUID else { return }
            let m = WorkoutViewModel(uid: uid)
            vm = m
            await m.loadWeekData()
        }
    }

    private var loadingContent: some View {
        VStack(spacing: Spacing.md) {
            SkeletonView().frame(height: 60).padding(.horizontal, Spacing.md)
            SkeletonView().frame(height: 200).padding(.horizontal, Spacing.md)
            Spacer()
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - Main Content

private struct WorkoutContent: View {
    @Bindable var vm: WorkoutViewModel
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            weekStrip
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.lg)
                .background(Color.appSurface)

            ScrollView {
                VStack(spacing: Spacing.md) {
                    Spacer().frame(height: Spacing.xs)
                    if let plan = vm.selectedPlan {
                        workoutDayCard(plan: plan)
                    } else {
                        SkeletonView()
                            .frame(height: 200)
                            .padding(.horizontal, Spacing.md)
                    }

                    if vm.showActionButtons {
                        actionButtons
                    } else if vm.canMarkCompleted {
                        markCompletedButton
                    }
                }
                .padding(.bottom, Spacing.xxxl)
            }
            .background(Color.appBackground)
            .refreshable { await vm.loadWeekData() }
        }
        .overlay(alignment: .topLeading) {
            if vm.showConfetti {
                Rectangle()
                    .fill(.clear)
                    .overlay {
                        ForEach(0..<20, id: \.self) { i in
                            ConfettiParticle(index: i)
                        }
                    }
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vm.showConfetti = false
                        }
                    }
            }
        }
    }

    // MARK: - Week Strip

    private var weekStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(Date.currentWeekDays(), id: \.self) { day in
                    DayPillView(
                        date: day,
                        isSelected: day.dateKey == vm.selectedDate.dateKey,
                        status: vm.weekWorkoutLogs[day.dateKey]?.status
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            vm.selectedDate = day
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Day Pill

    private struct DayPillView: View {
        let date: Date
        let isSelected: Bool
        let status: WorkoutStatus?

        var dayColor: Color { Color.dayColor(for: date.weekdayName) }

        var body: some View {
            VStack(spacing: 4) {
                Text(date.dayLetter)
                    .font(.appCaption2)
                    .foregroundStyle(Color.appTextSecondary)

                ZStack {
                    Circle()
                        .fill(circleBackground)
                        .frame(width: 36, height: 36)

                    Text(date.dayNumber)
                        .font(.appSubheadline)
                        .fontWeight(date.isToday || isSelected ? .bold : .regular)
                        .foregroundStyle(numberColor)
                }
                .frame(width: 40, height: 40)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(response: 0.2), value: isSelected)

                Circle()
                    .fill(status.map { Color.statusColor(for: $0) } ?? Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(width: 44)
        }

        var circleBackground: Color {
            if date.isToday { return dayColor }
            if isSelected { return dayColor.opacity(0.2) }
            return Color.appSurfaceRaised
        }

        var numberColor: Color {
            if date.isToday { return .white }
            if isSelected { return dayColor }
            return .appTextPrimary
        }
    }

    // MARK: - Workout Day Card

    private func workoutDayCard(plan: WorkoutPlan) -> some View {
        let dayColor = Color(hex: plan.colorHex)

        return VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                HStack(spacing: Spacing.xs) {
                    Circle().fill(dayColor).frame(width: 12, height: 12)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plan.name).font(.appTitle3).foregroundStyle(Color.appTextPrimary)
                        Text(vm.selectedDate.weekdayName.capitalized).font(.appCaption).foregroundStyle(Color.appTextSecondary)
                    }
                }
                Spacer()
                Text(plan.duration)
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Divider()

            // Intensity
            HStack {
                Text("Intensity:")
                    .font(.appFootnote)
                    .foregroundStyle(Color.appTextSecondary)
                Text(plan.intensity)
                    .font(.appFootnote)
                    .foregroundStyle(dayColor)
            }

            // Special content for run/swim/rest days
            if plan.isRestDay {
                restDayContent
            } else {
                exercisesList(plan: plan)
            }

            // Status badge for completed/postponed/missed
            if let log = vm.selectedLog, log.status != .pending {
                statusBadge(log: log, plan: plan)
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(dayColor.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, Spacing.md)
    }

    private func exercisesList(plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Exercises")
                .font(.appFootnote)
                .foregroundStyle(Color.appTextSecondary)
            ForEach(plan.exercises, id: \.self) { exercise in
                HStack(spacing: Spacing.sm) {
                    Circle()
                        .fill(Color.appTextTertiary)
                        .frame(width: 6, height: 6)
                    Text(exercise)
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
    }

    private var restDayContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Rest & Recovery 😴")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
            let foamRolling = [
                ("IT Band", "2 min ea"), ("Quads", "90 sec ea"),
                ("Glutes (ball)", "90 sec ea"), ("Calves", "90 sec ea"),
                ("Thoracic Spine", "2 min"), ("Hip Flexors", "90 sec ea"),
                ("Lats", "60 sec")
            ]
            ForEach(foamRolling, id: \.0) { item, duration in
                HStack {
                    Text("🔄 \(item)")
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(duration)
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private func statusBadge(log: WorkoutLog, plan: WorkoutPlan) -> some View {
        switch log.status {
        case .completed:
            HStack {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.appSuccess)
                Text("Completed")
                    .font(.appFootnote)
                    .foregroundStyle(Color.appSuccess)
            }
        case .postponed:
            HStack {
                Text("🔄 Postponed")
                    .font(.appFootnote)
                    .foregroundStyle(Color.appWarning)
                Spacer()
            }
        case .missed:
            HStack {
                Text("❌ Missed")
                    .font(.appFootnote)
                    .foregroundStyle(Color.appDanger)
                Spacer()
            }
        case .pending:
            EmptyView()
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            Button {
                Task {
                    withAnimation(.spring(response: 0.2)) { buttonScale = 0.92 }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    withAnimation(.spring(response: 0.3)) { buttonScale = 1.0 }
                    await vm.completeWorkout()
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                }
            } label: {
                Label("Complete", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(color: .appSuccess))
            .scaleEffect(buttonScale)

            Button {
                Task {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    await vm.postponeWorkout()
                }
            } label: {
                Label("Postpone", systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, Spacing.md)
    }

    private var markCompletedButton: some View {
        Button {
            Task { await vm.markAsCompleted() }
        } label: {
            Text("Mark as Completed")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryButtonStyle())
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Simple Confetti Particle

private struct ConfettiParticle: View {
    let index: Int
    @State private var y: CGFloat = 0
    @State private var opacity: Double = 1
    private let colors: [Color] = [.appPrimary, .appSuccess, .appWarning, .appInfo, .purple]

    var body: some View {
        Circle()
            .fill(colors[index % colors.count])
            .frame(width: 8, height: 8)
            .position(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: y
            )
            .opacity(opacity)
            .onAppear {
                let startY = CGFloat.random(in: -20...0)
                y = startY
                withAnimation(.easeIn(duration: Double.random(in: 0.8...1.5)).delay(Double(index) * 0.05)) {
                    y = UIScreen.main.bounds.height + 50
                    opacity = 0
                }
            }
    }
}
