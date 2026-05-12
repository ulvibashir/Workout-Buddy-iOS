import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _WorkoutView(vm: WorkoutViewModel(container: container))
    }
}

private struct _WorkoutView: View {
    @StateObject var vm: WorkoutViewModel

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            daySelector
                            if let workout = vm.selectedWorkout {
                                workoutHeader(workout)
                                exerciseList(workout)
                                completionButton
                            } else {
                                Text("No workout scheduled")
                                    .foregroundColor(AppTheme.textMuted)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
            .sheet(isPresented: $vm.showRestTimer) {
                RestTimerView(duration: vm.restDuration)
                    .presentationDetents([.medium])
            }
            .alert("Workout Complete! 💪", isPresented: $vm.showCompletionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Great work on \(vm.selectedWorkout?.name ?? "today's session")!")
            }
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Day selector
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.orderedDays, id: \.self) { day in
                    let isSelected = day == vm.selectedDay
                    let isDone     = vm.completedDays[day] ?? false
                    let color      = vm.workoutDays[day].map { Color(hex: $0.color) } ?? AppTheme.border
                    Button {
                        vm.selectedDay = day
                    } label: {
                        VStack(spacing: 2) {
                            Text(day.prefix(3).capitalized)
                                .font(.caption).bold()
                            if isDone {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.accentGreen)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? color : color.opacity(0.15))
                        .foregroundColor(isSelected ? .white : color)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Workout header
    private func workoutHeader(_ workout: WorkoutDay) -> some View {
        let color = Color(hex: workout.color)
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name).font(.title2).bold()
                HStack(spacing: 8) {
                    Label(workout.duration, systemImage: "clock")
                    Label(workout.intensity + " intensity", systemImage: "flame.fill")
                }
                .font(.caption).foregroundColor(AppTheme.textMuted)
            }
            Spacer()
            if vm.isSelectedDayCompleted {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.accentGreen)
                    .font(.title2)
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: 4).frame(width: 4).foregroundColor(color)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Exercise list
    private func exerciseList(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 10) {
            if !workout.warmup.isEmpty {
                ExerciseSectionView(title: "Warm-up", exercises: workout.warmup, color: .yellow, onRestTimer: { secs in vm.triggerRestTimer(seconds: secs) })
            }
            ExerciseSectionView(title: "Main Work", exercises: workout.exercises, color: Color(hex: workout.color), onRestTimer: { secs in vm.triggerRestTimer(seconds: secs) })
            if !workout.cooldown.isEmpty {
                ExerciseSectionView(title: "Cool-down", exercises: workout.cooldown, color: .blue, onRestTimer: { secs in vm.triggerRestTimer(seconds: secs) })
            }
        }
    }

    // MARK: - Completion button
    private var completionButton: some View {
        Group {
            if vm.isSelectedDayCompleted {
                Button(role: .destructive) {
                    vm.unmarkCompleted()
                } label: {
                    Label("Mark as Incomplete", systemImage: "xmark.circle")
                        .font(.subheadline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.cardSecondary)
                        .foregroundColor(AppTheme.textMuted)
                        .cornerRadius(14)
                }
            } else {
                Button {
                    vm.markCompleted()
                } label: {
                    Label("Mark as Complete", systemImage: "checkmark.circle.fill")
                        .font(.subheadline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Exercise section
private struct ExerciseSectionView: View {
    let title:       String
    let exercises:   [Exercise]
    let color:       Color
    let onRestTimer: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2).tracking(0.8)
                .foregroundColor(AppTheme.textMuted)
                .padding(.horizontal, 4)
            ForEach(exercises) { exercise in
                ExerciseRowView(exercise: exercise, accentColor: color, onRestTimer: onRestTimer)
            }
        }
    }
}
