import SwiftUI
import Charts

struct PullUpsView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _PullUpsView(vm: PullUpsViewModel(container: container))
    }
}

private struct _PullUpsView: View {
    @StateObject var vm: PullUpsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    statsRow
                    if let prog = vm.program { programCard(prog) }
                    progressChart
                    historySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("Pull-ups")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $vm.showAddSheet) {
                AddPullUpSheet(vm: vm)
                    .presentationDetents([.medium, .large])
            }
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Stats row
    private var statsRow: some View {
        HStack(spacing: 8) {
            StatPill(label: "All-time Max",  value: "\(vm.allTimeMax)", unit: "reps",  color: AppTheme.accent)
            StatPill(label: "This Week",     value: "\(vm.weekTotal)",  unit: "total", color: AppTheme.accentGreen)
            StatPill(label: "Sessions",      value: "\(vm.logs.count)", unit: "total", color: AppTheme.accentBlue)
        }
    }

    // MARK: - Program card
    private func programCard(_ prog: PullUpProgram) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Training Program", systemImage: "list.bullet.clipboard").font(.subheadline).bold()
                Spacer()
                Text("Max: \(prog.currentMax) reps").font(.caption).foregroundColor(AppTheme.accent)
            }
            Divider().background(AppTheme.border)
            HStack(spacing: 8) {
                ForEach(prog.weeklyProgression.prefix(4)) { week in
                    VStack(spacing: 2) {
                        Text("Wk \(week.week)").font(.caption2).foregroundColor(AppTheme.textMuted)
                        Text("\(week.sets)×\(week.reps)").font(.callout).bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppTheme.cardSecondary)
                    .cornerRadius(8)
                }
            }
            Text("Grips: \(prog.grips.joined(separator: " · "))")
                .font(.caption).foregroundColor(AppTheme.textMuted)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }

    // MARK: - Progress chart
    private var progressChart: some View {
        let data: [(String, Int)] = vm.sortedLogs.reversed().suffix(12).map { log in
            (log.id.map { String($0.suffix(5)) } ?? "", log.maxReps)
        }
        guard !data.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Max Reps Progress").font(.subheadline).bold()
                Chart(Array(data.enumerated()), id: \.offset) { _, point in
                    LineMark(
                        x: .value("Date",     point.0),
                        y: .value("Max Reps", point.1)
                    )
                    .foregroundStyle(AppTheme.accent)
                    PointMark(
                        x: .value("Date",     point.0),
                        y: .value("Max Reps", point.1)
                    )
                    .foregroundStyle(AppTheme.accent)
                }
                .chartYScale(domain: 0...(vm.allTimeMax + 3))
                .frame(height: 130)
                .chartXAxis {
                    AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted) }
                }
                .chartYAxis {
                    AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted) }
                }
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .cornerRadius(14)
        )
    }

    // MARK: - History
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session History").font(.subheadline).bold()
            if vm.sortedLogs.isEmpty {
                Text("No sessions yet. Log your first set!")
                    .font(.caption).foregroundColor(AppTheme.textMuted)
                    .padding(.vertical, 8)
            }
            ForEach(vm.sortedLogs) { log in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(log.id ?? "").font(.callout).bold()
                        Text("Sets: \(log.sets.map(String.init).joined(separator: " · "))")
                            .font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(log.maxReps) max").font(.callout).bold().foregroundColor(AppTheme.accent)
                        Text("\(log.totalReps) total").font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.vertical, 8)
                Divider().background(AppTheme.border)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }
}

// MARK: - Add session sheet
private struct AddPullUpSheet: View {
    @ObservedObject var vm: PullUpsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Set input
                HStack {
                    TextField("Reps", text: $vm.setInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                    Button("Add Set") {
                        vm.addSet()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .disabled(Int(vm.setInput) == nil)
                }
                .padding(.horizontal, 16)

                // Logged sets so far
                if !vm.currentSets.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sets logged:").font(.subheadline).foregroundColor(AppTheme.textMuted)
                        ForEach(vm.currentSets.indices, id: \.self) { i in
                            HStack {
                                Text("Set \(i + 1): \(vm.currentSets[i]) reps").font(.callout)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            Divider().background(AppTheme.border)
                        }
                        HStack {
                            Text("Max: \(vm.currentSets.max() ?? 0)").font(.callout).bold().foregroundColor(AppTheme.accent)
                            Spacer()
                            Text("Total: \(vm.currentSets.reduce(0, +))").font(.callout).bold()
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                }

                Spacer()

                Button {
                    vm.saveSession()
                } label: {
                    Text("Save Session")
                        .font(.subheadline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.currentSets.isEmpty ? AppTheme.border : AppTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(vm.currentSets.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("Log Pull-ups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
        }
    }
}

// MARK: - Stat pill
private struct StatPill: View {
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
    }
}

extension PullUpProgram.WeekPlan: Identifiable {
    public var id: Int { week }
}
