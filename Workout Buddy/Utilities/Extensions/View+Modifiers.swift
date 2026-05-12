import SwiftUI

// MARK: - Card style modifier
extension View {
    func cardStyle(padding: CGFloat = 14) -> some View {
        self
            .padding(padding)
            .background(AppTheme.cardBackground)
            .cornerRadius(14)
    }

    func sectionTitle() -> some View {
        self
            .font(.caption2)
            .foregroundColor(AppTheme.textMuted)
            .tracking(0.8)
            .textCase(.uppercase)
    }

    // Dismiss keyboard on tap
    func dismissKeyboard() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
