import SwiftUI

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "See all"

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(.caption)
                    .foregroundColor(AppTheme.accent)
            }
        }
    }
}
