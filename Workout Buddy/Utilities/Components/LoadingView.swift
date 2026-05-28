import SwiftUI

// MARK: - Skeleton / Shimmer Loading

struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.md)
            .fill(Color(uiColor: .systemFill))
            .overlay(shimmerOverlay)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.5), location: 0.5),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: w * 0.6)
            .offset(x: isAnimating ? w * 1.3 : -w * 0.6)
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.appWarning)

            Text("Something went wrong")
                .font(.appTitle3)
                .foregroundStyle(Color.appTextPrimary)

            Text(message)
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again", action: retryAction)
                .buttonStyle(PrimaryButtonStyle(color: .appPrimary))
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text(icon).font(.system(size: 60))
            Text(title).font(.appTitle3).foregroundStyle(Color.appTextPrimary)
            Text(subtitle)
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Offline Banner

struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "wifi.slash")
            Text("No internet connection")
                .font(.appFootnote)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .frame(maxWidth: .infinity)
        .background(Color.appDanger)
        .foregroundStyle(.white)
    }
}

// MARK: - Trend Indicator

struct TrendIndicator: View {
    let trend: Trend

    var color: Color {
        switch trend {
        case .up:      return .appSuccess
        case .down:    return .appDanger
        case .neutral: return .appTextSecondary
        }
    }

    var body: some View {
        Text(trend.symbol).font(.appCaption).foregroundStyle(color)
    }
}

// MARK: - Legacy support
typealias LoadingView = EmptyStateView
