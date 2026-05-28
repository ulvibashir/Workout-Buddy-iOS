import SwiftUI

struct LoggedSet {
    var weight: Double?
    var reps: Int?
    var completed: Bool = false
}

struct ExerciseRowView: View {
    let exercise:    Exercise
    let accentColor: Color
    let onRestTimer: (Int) -> Void

    @State private var loggedSets:   [LoggedSet]
    @State private var isExpanded:   Bool = false
    @State private var allCompleted: Bool = false

    init(exercise: Exercise, accentColor: Color, onRestTimer: @escaping (Int) -> Void) {
        self.exercise    = exercise
        self.accentColor = accentColor
        self.onRestTimer = onRestTimer
        _loggedSets = State(initialValue: Array(repeating: LoggedSet(), count: exercise.sets ?? 0))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button {
                withAnimation(.spring(response: 0.3)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Circle()
                        .fill(allCompleted ? AppTheme.accentGreen : accentColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: allCompleted ? "checkmark" : "figure.strengthtraining.traditional")
                                .font(.caption)
                                .foregroundColor(allCompleted ? .white : accentColor)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name).font(.callout).bold()
                        HStack(spacing: 6) {
                            if !setsRepsText.isEmpty { Text(setsRepsText) }
                            if let w = exercise.weight { Text("@ \(w)").foregroundColor(AppTheme.textMuted) }
                        }
                        .font(.caption).foregroundColor(AppTheme.textMuted)
                        if let notes = exercise.notes, !notes.isEmpty {
                            Text(notes).font(.caption2).foregroundColor(AppTheme.textMuted).italic()
                        }
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption).foregroundColor(AppTheme.textMuted)
                }
                .padding(12)
            }
            .buttonStyle(.plain)

            // Expanded: per-set logging
            if isExpanded {
                Divider().background(AppTheme.border)
                VStack(spacing: 8) {
                    // Column headers
                    HStack {
                        Text("Set").frame(width: 36)
                        Spacer()
                        Text("Weight (kg)").frame(width: 100)
                        Spacer()
                        Text("Reps").frame(width: 70)
                        Spacer()
                        Text("Done").frame(width: 44)
                    }
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.horizontal, 12)

                    ForEach(loggedSets.indices, id: \.self) { i in
                        SetRow(
                            setNumber: i + 1,
                            set:       $loggedSets[i],
                            color:     accentColor
                        ) {
                            if loggedSets[i].completed { onRestTimer(90) }
                            updateAllCompleted()
                        }
                    }

                    Button {
                        onRestTimer(90)
                    } label: {
                        Label("Start Rest Timer", systemImage: "timer")
                            .font(.caption).bold()
                            .foregroundColor(accentColor)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }

    private var setsRepsText: String {
        switch (exercise.sets, exercise.reps) {
        case let (s?, r?): return "\(s) × \(r)"
        case let (s?, nil): return "\(s) sets"
        case let (nil, r?): return r
        case (nil, nil): return ""
        }
    }

    private func updateAllCompleted() {
        allCompleted = loggedSets.allSatisfy(\.completed)
    }
}

// MARK: - Per-set row
private struct SetRow: View {
    let setNumber: Int
    @Binding var set: LoggedSet
    let color:     Color
    let onChange:  () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text("\(setNumber)").font(.callout).bold()
                .frame(width: 36)
                .foregroundColor(AppTheme.textMuted)

            Spacer()

            TextField("—", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: 100)
                .padding(.vertical, 6)
                .background(AppTheme.cardSecondary)
                .cornerRadius(8)
                .font(.callout)

            Spacer()

            TextField("—", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 70)
                .padding(.vertical, 6)
                .background(AppTheme.cardSecondary)
                .cornerRadius(8)
                .font(.callout)

            Spacer()

            Button {
                set.completed.toggle()
                onChange()
            } label: {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(set.completed ? AppTheme.accentGreen : AppTheme.border)
            }
            .frame(width: 44)
        }
        .padding(.horizontal, 12)
    }
}
