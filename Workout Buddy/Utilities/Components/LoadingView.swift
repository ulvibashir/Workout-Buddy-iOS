import SwiftUI

struct LoadingView: View {
    var message: String = "Loading…"

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.2)
                    .tint(AppTheme.accent)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(24)
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
        }
    }
}
