import SwiftUI
import Charts

struct ProgressView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _ProgressView(vm: ProgressViewModel(container: container))
    }
}

private struct _ProgressView: View {
    @StateObject var vm: ProgressViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    metricCards
                    if vm.sortedMetrics.count > 1 { weightChart; rhrChart; hrvChart }
                    goalsSection
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.fill").foregroundColor(AppTheme.textMuted)
                            Text("Settings").foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(AppTheme.textMuted)
                        }
                        .padding(14)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            vm.syncFromHealthKit()
                        } label: {
                            Image(systemName: "heart.circle.fill").foregroundColor(AppTheme.accentGreen)
                        }
                        Button {
                            vm.resetForm()
                            vm.showLogSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill").foregroundColor(AppTheme.accent)
                        }
                    }
                }
            }
            .sheet(isPresented: $vm.showLogSheet) {
                LogMetricSheet(vm: vm).presentationDetents([.medium])
            }
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Metric cards 2×2
    private var metricCards: some View {
        let b = vm.profile.baselineMetrics
        let m = vm.latestMetric
        return LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 8) {
            MetricTile(label: "Weight",    current: m?.weight ?? String(b.weight), unit: "kg",        color: AppTheme.accentOrange, icon: "scalemass.fill")
            MetricTile(label: "RHR",       current: m?.rhr    ?? String(b.rhr),    unit: "bpm",       color: AppTheme.accent,       icon: "heart.fill")
            MetricTile(label: "HRV",       current: m?.hrv    ?? String(b.hrv),    unit: "ms",        color: AppTheme.accentGreen,  icon: "waveform.path.ecg")
            MetricTile(label: "VO2 Max",   current: m?.vo2max ?? String(b.vo2max), unit: "ml/kg/min", color: AppTheme.accentBlue,   icon: "wind")
        }
    }

    // MARK: - Charts
    private var weightChart: some View { lineChart(title: "Weight (kg)", keyPath: \.weightValue, color: AppTheme.accentOrange) }
    private var rhrChart:    some View { lineChart(title: "Resting HR (bpm) ↓ better", keyPath: \.rhrValue, color: AppTheme.accent) }
    private var hrvChart:    some View { lineChart(title: "HRV (ms)", keyPath: \.hrvValue, color: AppTheme.accentGreen) }

    private func lineChart(title: String, keyPath: KeyPath<BodyMetric, Double>, color: Color) -> some View {
        // m.id?.suffix(5).map(String.init) would call Sequence.map (→ [String]).
        // Use Optional.map with an explicit closure instead.
        let points: [(String, Double)] = vm.sortedMetrics.compactMap { m in
            let v = m[keyPath: keyPath]
            guard v > 0, let id = m.id else { return nil }
            return (String(id.suffix(5)), v)
        }
        guard points.count > 1 else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.subheadline).bold()
                Chart(Array(points.enumerated()), id: \.offset) { _, point in
                    LineMark(
                        x: .value("Date",  point.0),
                        y: .value("Value", point.1)
                    )
                    .foregroundStyle(color)
                    AreaMark(
                        x: .value("Date",  point.0),
                        y: .value("Value", point.1)
                    )
                    .foregroundStyle(color.opacity(0.1))
                }
                .frame(height: 100)
                .chartXAxis { AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted) } }
                .chartYAxis { AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted) } }
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .cornerRadius(14)
        )
    }

    // MARK: - Goals
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "target").foregroundColor(AppTheme.accent)
                Text("6-Month Goals").font(.subheadline).bold()
            }
            ForEach(vm.goals) { goal in
                VStack(spacing: 4) {
                    HStack {
                        Text(goal.metric).font(.callout).bold()
                        Spacer()
                        Text("\(goal.start, specifier: "%.0f") → \(goal.month6, specifier: "%.0f") \(goal.unit)")
                            .font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(AppTheme.border).frame(height: 6)
                            RoundedRectangle(cornerRadius: 3).fill(AppTheme.accent)
                                .frame(width: geo.size.width * vm.progress(for: goal), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }
}

// MARK: - Log metric sheet
private struct LogMetricSheet: View {
    @ObservedObject var vm: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Body Metrics") {
                    numericField("Weight (kg)",       text: $vm.formWeight, placeholder: "68.0")
                    numericField("Resting HR (bpm)",  text: $vm.formRHR,    placeholder: "58")
                    numericField("HRV (ms)",          text: $vm.formHRV,    placeholder: "65")
                    numericField("VO2 Max",           text: $vm.formVO2Max, placeholder: "41.1")
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Log Metrics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { vm.saveMetric() }
                }
            }
        }
    }

    private func numericField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

// MARK: - Metric tile
private struct MetricTile: View {
    let label:   String; let current: String; let unit: String
    let color:   Color;  let icon:    String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color).font(.title3)
            Text(current).font(.title2).bold()
            Text(unit).font(.caption2).foregroundColor(AppTheme.textMuted)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}
