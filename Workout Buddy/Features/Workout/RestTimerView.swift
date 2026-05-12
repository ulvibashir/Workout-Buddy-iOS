import SwiftUI

struct RestTimerView: View {
    let duration: Int
    @Environment(\.dismiss) private var dismiss

    @State private var remaining: Int
    @State private var isRunning: Bool = true
    @State private var timer: Timer?

    init(duration: Int) {
        self.duration  = duration
        _remaining     = State(initialValue: duration)
    }

    private var progress: Double {
        duration > 0 ? Double(remaining) / Double(duration) : 0
    }

    var body: some View {
        VStack(spacing: 28) {
            Text("Rest Timer")
                .font(.title2).bold()

            // Arc progress ring
            ZStack {
                Circle()
                    .stroke(AppTheme.border, lineWidth: 10)
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        timerColor,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remaining)
                VStack(spacing: 2) {
                    Text(timeString)
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundColor(timerColor)
                    Text("seconds remaining").font(.caption).foregroundColor(AppTheme.textMuted)
                }
            }

            HStack(spacing: 16) {
                // Pause / Resume
                Button {
                    isRunning ? pauseTimer() : resumeTimer()
                } label: {
                    Label(isRunning ? "Pause" : "Resume",
                          systemImage: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.callout).bold()
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(AppTheme.cardSecondary)
                        .cornerRadius(12)
                }

                // Reset
                Button {
                    resetTimer()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise.circle.fill")
                        .font(.callout).bold()
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(AppTheme.cardSecondary)
                        .cornerRadius(12)
                }
            }

            // Quick-add buttons
            HStack(spacing: 10) {
                ForEach([15, 30, 60], id: \.self) { extra in
                    Button("+\(extra)s") {
                        remaining += extra
                    }
                    .font(.caption).bold()
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(AppTheme.accentBlue.opacity(0.2))
                    .foregroundColor(AppTheme.accentBlue)
                    .cornerRadius(10)
                }
            }

            Button("Done") { dismiss() }
                .font(.subheadline).bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.accent)
                .foregroundColor(.white)
                .cornerRadius(14)
        }
        .padding(24)
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }

    private var timeString: String { String(format: "%d:%02d", remaining / 60, remaining % 60) }

    private var timerColor: Color {
        if remaining > 30 { return AppTheme.accentGreen }
        if remaining > 10 { return AppTheme.accentOrange }
        return AppTheme.accent
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 { remaining -= 1 } else { timer?.invalidate(); dismiss() }
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }

    private func resumeTimer() {
        isRunning = true
        startTimer()
    }

    private func resetTimer() {
        timer?.invalidate()
        remaining  = duration
        isRunning  = true
        startTimer()
    }
}
