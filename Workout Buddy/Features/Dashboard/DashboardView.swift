import SwiftUI

// Entry point — extracts container from environment and passes to VM
struct DashboardView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _DashboardView(vm: DashboardViewModel(container: container))
    }
}

private struct _DashboardView: View {
    @StateObject var vm: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    quoteCard
                    if let workout = vm.todayWorkout { todayWorkoutCard(workout) }
                    bodyMetricsGrid
                    summaryStatsGrid
                    weekOverview
                    if !vm.recentRuns.isEmpty    { recentRunsCard    }
                    if !vm.recentPullUps.isEmpty { recentPullUpsCard }
                    marathonCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle(vm.profile.name)
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Quote banner
    private var quoteCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .frame(width: 3)
                .foregroundColor(AppTheme.accent)
            Text("\"\(vm.todayQuote)\"")
                .font(.caption)
                .foregroundColor(AppTheme.textMuted)
                .italic()
                .padding(.vertical, 8)
            Spacer()
        }
        .padding(.horizontal, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }

    // MARK: - Today's workout
    private func todayWorkoutCard(_ workout: WorkoutDay) -> some View {
        let done  = vm.completedDays[vm.currentDayKey] ?? false
        let color = Color(hex: workout.color)
        return NavigationLink(destination: WorkoutView()) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TODAY'S SESSION")
                        .font(.caption2).tracking(0.8)
                        .foregroundColor(AppTheme.textMuted)
                    Text(workout.name)
                        .font(.title3).bold()
                    HStack(spacing: 4) {
                        Text(workout.duration)
                        Text("·")
                        Text(workout.intensity + " intensity")
                        if done { Text("· Completed ✓").foregroundColor(AppTheme.accentGreen) }
                    }
                    .font(.caption).foregroundColor(AppTheme.textMuted)
                }
                Spacer()
                Image(systemName: "bolt.fill").foregroundColor(color).font(.title2)
            }
            .padding(16)
            .background(AppTheme.cardBackground)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .inset(by: 0.5)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: 4).frame(width: 4).foregroundColor(color)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Metric cards row
    private var bodyMetricsGrid: some View {
        let m = vm.latestMetric
        let b = vm.profile.baselineMetrics
        return HStack(spacing: 8) {
            SmallMetricCell(label: "Weight", value: m?.weight ?? String(b.weight), unit: "kg",  color: AppTheme.accentOrange, icon: "scalemass.fill")
            SmallMetricCell(label: "RHR",    value: m?.rhr    ?? String(b.rhr),    unit: "bpm", color: AppTheme.accent,       icon: "heart.fill")
            SmallMetricCell(label: "HRV",    value: m?.hrv    ?? String(b.hrv),    unit: "ms",  color: AppTheme.accentGreen,  icon: "waveform.path.ecg")
        }
    }

    // MARK: - Summary stats
    private var summaryStatsGrid: some View {
        HStack(spacing: 8) {
            StatsCell(label: "Workouts/wk", value: "\(vm.completedThisWeek)", unit: "done", color: AppTheme.accentPurple)
            StatsCell(label: "Pull-up Max",  value: "\(vm.allTimeMaxPullUp)",  unit: "reps", color: AppTheme.accent)
            StatsCell(label: "Total km",     value: "\(Int(vm.totalRunKm))",   unit: "km",   color: AppTheme.accentBlue)
        }
    }

    // MARK: - Week overview
    private var weekOverview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THIS WEEK")
                .font(.caption2).tracking(0.8)
                .foregroundColor(AppTheme.textMuted)
            HStack(spacing: 6) {
                ForEach(AppConstants.Firestore.WeekDays.all, id: \.self) { day in
                    let wd      = vm.workoutDays[day]
                    let done    = vm.completedDays[day] ?? false
                    let isToday = day == vm.currentDayKey
                    let color   = wd.map { Color(hex: $0.color) } ?? AppTheme.border
                    RoundedRectangle(cornerRadius: 8)
                        .fill(done ? color : isToday ? color.opacity(0.33) : color.opacity(0.13))
                        .frame(height: 40)
                        .overlay(
                            VStack(spacing: 1) {
                                Text(day.prefix(1).uppercased()).font(.caption2).bold()
                                if done { Text("✓").font(.system(size: 8)) }
                            }
                            .foregroundColor(done || isToday ? .white : color)
                        )
                        .overlay(
                            isToday && !done
                                ? RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 1)
                                : nil
                        )
                }
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }

    // MARK: - Recent runs
    private var recentRunsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Runs").font(.subheadline).bold()
                Spacer()
                NavigationLink("See all", destination: RunningView())
                    .font(.caption).foregroundColor(AppTheme.accentBlue)
            }
            ForEach(vm.recentRuns) { run in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(run.distance, specifier: "%.1f") km").font(.callout).bold()
                        Text(run.date).font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        if !run.avgPace.isEmpty {
                            Text("\(run.avgPace)/km").font(.callout).bold().foregroundColor(AppTheme.accentBlue)
                        }
                        if run.avgHR > 0 {
                            Text("\(run.avgHR) bpm").font(.caption).foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                .padding(.vertical, 4)
                if run.id != vm.recentRuns.last?.id { Divider().background(AppTheme.border) }
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }

    // MARK: - Recent pull-ups
    private var recentPullUpsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Pull-ups").font(.subheadline).bold()
                Spacer()
                NavigationLink("See all", destination: PullUpsView())
                    .font(.caption).foregroundColor(AppTheme.accent)
            }
            ForEach(vm.recentPullUps) { session in
                HStack {
                    Text(session.id ?? "").font(.caption).foregroundColor(AppTheme.textMuted)
                    Spacer()
                    Text("\(session.maxReps) max").font(.callout).bold().foregroundColor(AppTheme.accent)
                    Text("\(session.totalReps) total").font(.caption).foregroundColor(AppTheme.textMuted)
                }
                .padding(.vertical, 4)
                if session.id != vm.recentPullUps.last?.id { Divider().background(AppTheme.border) }
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }

    // MARK: - Marathon achievement
    private var marathonCard: some View {
        let m = vm.profile.achievements.bakuMarathon2026
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "trophy.fill").foregroundColor(AppTheme.accentOrange)
                Text("Baku Marathon 2026 — \(m.date)").font(.subheadline).bold()
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 8) {
                ForEach([
                    ("Distance",  "\(m.distance)km"),
                    ("Time",      m.officialTime),
                    ("Avg Pace",  "\(m.avgPace)/km"),
                    ("Avg HR",    "\(m.avgHR) bpm"),
                    ("Elevation", "\(m.elevation)m"),
                    ("Calories",  "\(m.calories.formatted())")
                ], id: \.0) { item in
                    VStack(spacing: 2) {
                        Text(item.1).font(.callout).bold()
                        Text(item.0).font(.caption2).foregroundColor(AppTheme.textMuted)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.cardSecondary)
                    .cornerRadius(8)
                }
            }
            Text("Sprint finish km 40-42 · First ever marathon")
                .font(.caption).foregroundColor(AppTheme.accentOrange).italic()
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
        .overlay(
            VStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.accentOrange)
                    .frame(height: 3)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Private reusable cells
private struct SmallMetricCell: View {
    let label: String; let value: String; let unit: String
    let color: Color; let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundColor(color).font(.callout)
            Text(value).font(.title3).bold()
            Text(unit).font(.caption2).foregroundColor(AppTheme.textMuted)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

private struct StatsCell: View {
    let label: String; let value: String; let unit: String; let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title2).bold().foregroundColor(color)
            Text(unit).font(.caption2).foregroundColor(AppTheme.textMuted)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            VStack {
                RoundedRectangle(cornerRadius: 12).fill(color).frame(height: 3)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
