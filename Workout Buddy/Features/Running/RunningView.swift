import SwiftUI
import Charts

struct RunningView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _RunningView(vm: RunningViewModel(container: container))
    }
}

private struct _RunningView: View {
    @StateObject var vm: RunningViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    statsRow
                    distanceChart
                    runHistorySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("Running")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            vm.importFromHealthKit()
                        } label: {
                            Image(systemName: "heart.circle").foregroundColor(AppTheme.accentGreen)
                        }
                        Button {
                            vm.showAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill").foregroundColor(AppTheme.accentBlue)
                        }
                    }
                }
            }
            .sheet(isPresented: $vm.showAddSheet) {
                AddRunSheet(vm: vm).presentationDetents([.large])
            }
            .alert("Health Import", isPresented: .constant(vm.importMessage != nil)) {
                Button("OK") { vm.importMessage = nil }
            } message: {
                Text(vm.importMessage ?? "")
            }
            .overlay {
                if vm.isImporting {
                    LoadingView(message: "Importing from Apple Health…")
                }
            }
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
    }
    
    // MARK: - Stats row
    private var statsRow: some View {
        HStack(spacing: 8) {
            StatTile(
                label: "Total km",
                value: "\(Int(vm.totalKm))",
                unit: "km",
                color: AppTheme.accentBlue
            )
            StatTile(
                label: "Longest Run",
                value: String(
                    format: "%.1f",
                    vm.longestRun?.distance ?? 0.0
                ),
                unit: "km",
                color: AppTheme.accentGreen
            )
            StatTile(
                label: "Best Pace",
                value: vm.fastestPace?.avgPace ?? "—",
                unit: "/km",
                color: AppTheme.accent
            )
        }
    }

    // MARK: - Distance chart
    private var distanceChart: some View {
        let data = vm.sortedRuns.reversed().suffix(10)
        guard !data.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Distances").font(.subheadline).bold()
                Chart(Array(data.enumerated()), id: \.offset) { _, run in
                    BarMark(
                        x: .value("Date", String(run.date.suffix(5))),
                        y: .value("km", run.distance)
                    )
                    .foregroundStyle(AppTheme.accentBlue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 120)
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

    // MARK: - History list
    private var runHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All Runs").font(.subheadline).bold()
            if vm.sortedRuns.isEmpty {
                Text("No runs logged yet.")
                    .font(.caption).foregroundColor(AppTheme.textMuted)
                    .padding(.vertical, 8)
            }
            ForEach(vm.sortedRuns) { run in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("\(run.distance, specifier: "%.1f") km").font(.callout).bold()
                            Text("·").foregroundColor(AppTheme.textMuted)
                            Text(run.runType)
                                .font(.caption).bold()
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(AppTheme.accentBlue.opacity(0.2))
                                .foregroundColor(AppTheme.accentBlue)
                                .cornerRadius(6)
                        }
                        HStack(spacing: 6) {
                            Text(run.date).font(.caption)
                            if !run.time.isEmpty     { Text("· \(run.time)").font(.caption) }
                            if !run.avgPace.isEmpty  { Text("· \(run.avgPace)/km").font(.caption) }
                        }
                        .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    if run.avgHR > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill").font(.caption2).foregroundColor(AppTheme.accent)
                            Text("\(run.avgHR)").font(.caption)
                        }
                    }
                }
                .padding(.vertical, 8)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { vm.deleteRun(run) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                Divider().background(AppTheme.border)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }
}

// MARK: - Add run sheet
private struct AddRunSheet: View {
    @ObservedObject var vm: RunningViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Run Details") {
                    HStack {
                        Text("Date")
                        Spacer()
                        TextField("yyyy-MM-dd", text: $vm.formDate)
                            .multilineTextAlignment(.trailing).foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Distance (km)")
                        Spacer()
                        TextField("0.0", text: $vm.formDistance)
                            .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Time")
                        Spacer()
                        TextField("H:MM:SS", text: $vm.formTime)
                            .multilineTextAlignment(.trailing).foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Avg Pace (/km)")
                        Spacer()
                        TextField("M:SS", text: $vm.formPace)
                            .multilineTextAlignment(.trailing).foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Avg HR (bpm)")
                        Spacer()
                        TextField("0", text: $vm.formHR)
                            .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                    }
                    Picker("Run Type", selection: $vm.formType) {
                        ForEach(vm.runTypes, id: \.self) { Text($0) }
                    }
                }
                Section("Notes") {
                    TextField("Optional notes…", text: $vm.formNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Log Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { vm.saveRun() }
                        .disabled(vm.formDistance.isEmpty)
                }
            }
        }
    }
}

private struct StatTile: View {
    let label: String; let value: String; let unit: String; let color: Color
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title3).bold().foregroundColor(color)
            Text(unit).font(.caption2).foregroundColor(AppTheme.textMuted)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}
