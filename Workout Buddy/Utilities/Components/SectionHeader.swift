import SwiftUI

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .appPrimary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .foregroundStyle(Color.appPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.appSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.appPrimary, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    var trend: Trend? = nil
    var color: Color = .appPrimary
    var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .center, spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                    .frame(width: 22)
                Text(unit)
                    .font(.appCaption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if isLoading {
                SkeletonView().frame(height: 28)
            } else {
                Text(value)
                    .font(.appMetricSmall)
                    .foregroundStyle(Color.appTextPrimary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.appTextSecondary)

            if let trend { TrendIndicator(trend: trend) }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String = "See all"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appTitle3)
                    .foregroundStyle(Color.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(.appFootnote)
                    .foregroundStyle(Color.appPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Card Modifier

extension View {
    func cardStyle(padding: CGFloat = Spacing.md) -> some View {
        self
            .padding(padding)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }
}
