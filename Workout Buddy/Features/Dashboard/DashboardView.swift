import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var vm: DashboardViewModel?

    var body: some View {
        Group {
            if let vm {
                DashboardContent(vm: vm)
            } else {
                loadingPlaceholder
            }
        }
        .task {
            guard vm == nil, let uid = authViewModel.currentUID else { return }
            let m = DashboardViewModel(uid: uid)
            vm = m
            await m.loadData()
        }
    }

    private var loadingPlaceholder: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                SkeletonView().frame(height: 28).padding(.horizontal, Spacing.md).padding(.top, Spacing.xl)
                SkeletonView().frame(height: 100).padding(.horizontal, Spacing.md)
                HStack(spacing: Spacing.xs) {
                    SkeletonView(); SkeletonView(); SkeletonView()
                }
                .frame(height: 110).padding(.horizontal, Spacing.md)
                HStack(spacing: Spacing.xs) {
                    SkeletonView(); SkeletonView(); SkeletonView()
                }
                .frame(height: 110).padding(.horizontal, Spacing.md)
                SkeletonView().frame(height: 65).padding(.horizontal, Spacing.md)
                SkeletonView().frame(height: 130).padding(.horizontal, Spacing.md)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - Main Content

private struct DashboardContent: View {
    @Bindable var vm: DashboardViewModel
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Header
                    headerView
                        .padding(.horizontal, Spacing.md)

                    if vm.isLoading {
                        skeletonState
                    } else {
                        readinessCard
                        primaryMetricsRow
                        secondaryMetricsRow
                        todayWorkoutCard
                        weeklySection
                        trendCharts
                    }
                }
                .padding(.bottom, Spacing.xxxl)
            }
            .refreshable { await vm.loadData() }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("\(vm.greeting), \(vm.userProfile.name) 👋")
                .font(.appTitle2)
                .foregroundStyle(Color.appTextPrimary)
            Text(Date.today.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.md)
    }

    // MARK: - Skeleton

    private var skeletonState: some View {
        VStack(spacing: Spacing.md) {
            SkeletonView().frame(height: 100).padding(.horizontal, Spacing.md)
            HStack(spacing: Spacing.xs) {
                SkeletonView(); SkeletonView(); SkeletonView()
            }
            .frame(height: 110).padding(.horizontal, Spacing.md)
            HStack(spacing: Spacing.xs) {
                SkeletonView(); SkeletonView(); SkeletonView()
            }
            .frame(height: 110).padding(.horizontal, Spacing.md)
            SkeletonView().frame(height: 65).padding(.horizontal, Spacing.md)
            SkeletonView().frame(height: 130).padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Readiness Card

    private var readinessCard: some View {
        HStack(spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\(vm.readinessScore)")
                    .font(.appMetricLarge)
                    .foregroundStyle(readinessColor)
                    .contentTransition(.numericText())
                Text("Readiness")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
                Text(vm.readinessStatus.label)
                    .font(.appFootnote)
                    .foregroundStyle(readinessColor)
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.appSurfaceRaised, lineWidth: 10)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: Double(vm.readinessScore) / 100)
                    .stroke(readinessColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: vm.readinessScore)
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.md)
    }

    private var readinessColor: Color {
        switch vm.readinessStatus {
        case .ready:   return .appSuccess
        case .caution: return .appWarning
        case .rest:    return .appDanger
        }
    }

    // MARK: - Primary Metrics (HRV, RHR, VO2Max)

    private var primaryMetricsRow: some View {
        HStack(spacing: Spacing.xs) {
            MetricCard(
                icon: "waveform.path.ecg",
                value: vm.todayMetrics?.hrv.map { String(Int($0)) } ?? "—",
                unit: "ms",
                label: "HRV",
                color: .appSuccess,
                isLoading: vm.isLoading
            )
            MetricCard(
                icon: "heart.fill",
                value: vm.todayMetrics?.rhr.map { String(Int($0)) } ?? "—",
                unit: "bpm",
                label: "RHR",
                color: .appDanger,
                isLoading: vm.isLoading
            )
            MetricCard(
                icon: "lungs.fill",
                value: vm.todayMetrics?.vo2max.map { String(format: "%.1f", $0) } ?? "—",
                unit: "ml/kg/min",
                label: "VO2 Max",
                color: .appInfo,
                isLoading: vm.isLoading
            )
        }
        .frame(height: 110)
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Secondary Metrics (Sleep, Steps, Calories)

    private var secondaryMetricsRow: some View {
        HStack(spacing: Spacing.xs) {
            MetricCard(
                icon: "moon.stars.fill",
                value: vm.todayMetrics?.sleepHours.map { String(format: "%.1f", $0) } ?? "—",
                unit: "hrs",
                label: "Sleep",
                color: .purple,
                isLoading: vm.isLoading
            )
            MetricCard(
                icon: "figure.walk",
                value: vm.todayMetrics?.steps.map { "\($0)" } ?? "—",
                unit: "steps",
                label: "Steps",
                color: .appInfo,
                isLoading: vm.isLoading
            )
            MetricCard(
                icon: "flame.fill",
                value: vm.todayMetrics?.activeCalories.map { String(Int($0)) } ?? "—",
                unit: "kcal",
                label: "Calories",
                color: .orange,
                isLoading: vm.isLoading
            )
        }
        .frame(height: 110)
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Today's Workout Preview

    private var todayWorkoutCard: some View {
        let workout = vm.todayWorkout
        let status = workout?.status ?? .pending
        let dayName = Date.today.weekdayName
        let dayColor = Color.dayColor(for: dayName)

        return HStack(spacing: Spacing.md) {
            Circle()
                .fill(dayColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(workout?.workoutName ?? "Today's Workout")
                    .font(.appHeadline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(dayName.capitalized)
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            workoutStatusBadge(status: status)
        }
        .padding(Spacing.md)
        .background(
            ZStack {
                Color.appSurface
                dayColor.opacity(0.08)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.md)
    }

    @ViewBuilder
    private func workoutStatusBadge(status: WorkoutStatus) -> some View {
        switch status {
        case .pending:
            HStack(spacing: 4) {
                Text("Today")
                    .font(.appFootnote)
                Image(systemName: "chevron.right")
                    .font(.appCaption)
            }
            .foregroundStyle(Color.appPrimary)
        case .completed:
            Label("Done ✓", systemImage: "checkmark.circle.fill")
                .font(.appFootnote)
                .foregroundStyle(Color.appSuccess)
        case .postponed:
            Text("Postponed")
                .font(.appFootnote)
                .foregroundStyle(Color.appWarning)
        case .missed:
            Text("Missed")
                .font(.appFootnote)
                .foregroundStyle(Color.appDanger)
        }
    }

    // MARK: - Weekly Section

    private var weeklySection: some View {
        VStack(spacing: Spacing.md) {
            SectionHeader(title: "This Week")
                .padding(.horizontal, Spacing.md)

            weeklyWorkoutStrip
            weeklyRunStats
        }
    }

    private var weeklyWorkoutStrip: some View {
        let days = Date.currentWeekDays()
        return VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                ForEach(days, id: \.self) { day in
                    let log = vm.weeklyWorkouts.first(where: { $0.date == day.dateKey })
                    let isToday = day.isToday
                    let dayColor = Color.dayColor(for: day.weekdayName)
                    let status = log?.status

                    VStack(spacing: Spacing.xxs) {
                        Text(day.dayLetter)
                            .font(.appCaption2)
                            .foregroundStyle(Color.appTextSecondary)

                        ZStack {
                            Circle()
                                .fill(circleBackground(status: status, isToday: isToday, dayColor: dayColor))
                                .frame(width: 36, height: 36)
                            if status == .completed {
                                Text("✓").font(.appCaption).foregroundStyle(.white)
                            } else if status == .missed {
                                Text("✗").font(.appCaption).foregroundStyle(.white)
                            } else {
                                Text(day.dayNumber)
                                    .font(.appSubheadline)
                                    .fontWeight(isToday ? .bold : .regular)
                                    .foregroundStyle(isToday ? dayColor : Color.appTextPrimary)
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(isToday ? dayColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            let completed = vm.weeklyCompletedCount
            let total = max(1, vm.weeklyTotalTrainingDays)
            VStack(spacing: Spacing.xxs) {
                Text("\(completed)/\(total) workouts completed this week")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.appSurfaceRaised)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.appPrimary)
                            .frame(width: geo.size.width * min(1, Double(completed) / Double(total)), height: 6)
                            .animation(.spring(), value: completed)
                    }
                }
                .frame(height: 6)
                if vm.isPerfectWeek {
                    Text("Perfect week! 🎉")
                        .font(.appCaption)
                        .foregroundStyle(Color.appSuccess)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.md)
    }

    private func circleBackground(status: WorkoutStatus?, isToday: Bool, dayColor: Color) -> Color {
        switch status {
        case .completed: return .appSuccess
        case .missed:    return .appDanger
        case .postponed: return .appWarning
        default:         return isToday ? dayColor.opacity(0.2) : Color.appSurfaceRaised
        }
    }

    private var weeklyRunStats: some View {
        let totalKm = vm.weeklyRunDistance
        let runs = vm.weeklyRuns
        return HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Label("Running", systemImage: "figure.run")
                    .font(.appHeadline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(String(format: "%.1f km · %d runs", totalKm, runs.count))
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            if !runs.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(runs.prefix(7), id: \.id) { run in
                        let maxDist = runs.prefix(7).map(\.distance).max() ?? 1
                        let height = max(8, CGFloat(run.distance / maxDist) * 40)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.dayTuesday)
                            .frame(width: 8, height: height)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Trend Charts

    private var trendCharts: some View {
        VStack(spacing: Spacing.md) {
            if vm.weeklyMetrics.count >= 2 {
                hrvTrendChart
                rhrTrendChart
            }
        }
    }

    private var hrvTrendChart: some View {
        let points = vm.weeklyMetrics.compactMap { m -> (String, Double)? in
            guard let v = m.hrv else { return nil }
            return (String(m.date.suffix(5)), v)
        }
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("HRV Trend").font(.appTitle3).foregroundStyle(Color.appTextPrimary)
            if points.isEmpty {
                Text("Not enough data yet")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(height: 100)
            } else {
                Chart(Array(points.enumerated()), id: \.offset) { _, point in
                    LineMark(x: .value("Date", point.0), y: .value("HRV", point.1))
                        .foregroundStyle(Color.appPrimary)
                    AreaMark(x: .value("Date", point.0), y: .value("HRV", point.1))
                        .foregroundStyle(Color.appPrimary.opacity(0.15))
                }
                .frame(height: 100)
                .chartXAxis { AxisMarks { AxisValueLabel().foregroundStyle(Color.appTextSecondary) } }
                .chartYAxis { AxisMarks { AxisValueLabel().foregroundStyle(Color.appTextSecondary) } }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.md)
    }

    private var rhrTrendChart: some View {
        let points = vm.weeklyMetrics.compactMap { m -> (String, Double)? in
            guard let v = m.rhr else { return nil }
            return (String(m.date.suffix(5)), v)
        }
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("RHR Trend").font(.appTitle3).foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("Lower is better ↓").font(.appCaption).foregroundStyle(Color.appTextSecondary)
            }
            if !points.isEmpty {
                Chart(Array(points.enumerated()), id: \.offset) { _, point in
                    LineMark(x: .value("Date", point.0), y: .value("RHR", point.1))
                        .foregroundStyle(Color.appDanger)
                    AreaMark(x: .value("Date", point.0), y: .value("RHR", point.1))
                        .foregroundStyle(Color.appDanger.opacity(0.1))
                }
                .frame(height: 100)
                .chartXAxis { AxisMarks { AxisValueLabel().foregroundStyle(Color.appTextSecondary) } }
                .chartYAxis { AxisMarks { AxisValueLabel().foregroundStyle(Color.appTextSecondary) } }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .padding(.horizontal, Spacing.md)
    }
}
