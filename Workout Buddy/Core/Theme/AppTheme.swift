import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - UIColor hex extension (used by adaptive colors)
#if canImport(UIKit)
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8)  & 0xFF) / 255,
            blue:  CGFloat(rgb         & 0xFF) / 255,
            alpha: 1
        )
    }
}
#endif

// MARK: - Color System

extension Color {
    // Primary
    static let appPrimary      = Color(hex: "#23B8A7")
    static let appPrimaryLight = Color(hex: "#FF8C5E")
    static let container       = Color(hex: "#152123")

    // Background (adaptive light/dark)
    static let appBackground    = Color(adaptiveDark: "#000000",  light: "#F2F2F7")
    static let appSurface       = Color(adaptiveDark: "#1C1C1E",  light: "#FFFFFF")
    static let appSurfaceRaised = Color(adaptiveDark: "#2C2C2E",  light: "#F2F2F7")

    // Text (adaptive)
    static let appTextPrimary   = Color(adaptiveDark: "#FFFFFF",  light: "#000000")
    static let appTextSecondary = Color(hex: "#8E8E93")
    static let appTextTertiary  = Color(hex: "#C7C7CC")

    // Status
    static let appSuccess = Color(hex: "#30D158")
    static let appWarning = Color(hex: "#FFD60A")
    static let appDanger  = Color(hex: "#FF453A")
    static let appInfo    = Color(hex: "#0A84FF")

    // Border (adaptive)
    static let appBorder = Color(adaptiveDark: "#38383A", light: "#E5E5EA")

    // Day-specific workout colors
    static let dayMonday    = Color(hex: "#FF6B35")
    static let dayTuesday   = Color(hex: "#0A84FF")
    static let dayWednesday = Color(hex: "#BF5AF2")
    static let dayThursday  = Color(hex: "#32D74B")
    static let dayFriday    = Color(hex: "#FF375F")
    static let daySaturday  = Color(hex: "#FF453A")
    static let daySunday    = Color(hex: "#636366")

    // Status aliases
    static let statusCompleted = Color.appSuccess
    static let statusPostponed = Color.appWarning
    static let statusMissed    = Color.appDanger
    static let statusPending   = Color.appTextSecondary

    // MARK: - Initializers

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8)  & 0xFF) / 255,
            blue:  Double(rgb         & 0xFF) / 255
        )
    }

    init(adaptiveDark dark: String, light: String) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(hexString: dark)
                : UIColor(hexString: light)
        })
        #else
        self.init(hex: dark)
        #endif
    }

    // Returns the day color for a given weekday name
    static func dayColor(for weekday: String) -> Color {
        switch weekday.lowercased() {
        case "monday":    return .dayMonday
        case "tuesday":   return .dayTuesday
        case "wednesday": return .dayWednesday
        case "thursday":  return .dayThursday
        case "friday":    return .dayFriday
        case "saturday":  return .daySaturday
        default:          return .daySunday
        }
    }

    static func statusColor(for status: WorkoutStatus) -> Color {
        switch status {
        case .completed: return .statusCompleted
        case .postponed: return .statusPostponed
        case .missed:    return .statusMissed
        case .pending:   return .statusPending
        }
    }
}

// MARK: - Typography

extension Font {
    // Display
    static let appLargeTitle  = Font.system(size: 34, weight: .bold,     design: .rounded)
    static let appTitle1      = Font.system(size: 28, weight: .bold,     design: .rounded)
    static let appTitle2      = Font.system(size: 22, weight: .bold,     design: .rounded)
    static let appTitle3      = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Body
    static let appHeadline    = Font.system(size: 17, weight: .semibold)
    static let appBody        = Font.system(size: 17, weight: .regular)
    static let appCallout     = Font.system(size: 16, weight: .regular)
    static let appSubheadline = Font.system(size: 15, weight: .regular)
    static let appFootnote    = Font.system(size: 13, weight: .regular)
    static let appCaption     = Font.system(size: 12, weight: .regular)
    static let appCaption2    = Font.system(size: 11, weight: .regular)

    // Metric display
    static let appMetricLarge  = Font.system(size: 48, weight: .bold, design: .rounded)
    static let appMetricMedium = Font.system(size: 32, weight: .bold, design: .rounded)
    static let appMetricSmall  = Font.system(size: 24, weight: .bold, design: .rounded)
}

// MARK: - Spacing

enum Spacing {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum Radius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let pill: CGFloat = 999
}

// MARK: - Legacy AppTheme compatibility (used by older views)
enum AppTheme {
    static let background:     Color = .appBackground
    static let cardBackground: Color = .appSurface
    static let cardSecondary:  Color = .appSurfaceRaised
    static let accent:         Color = .appPrimary
    static let accentGreen:    Color = .appSuccess
    static let accentBlue:     Color = .appInfo
    static let accentOrange:   Color = .appWarning
    static let accentPurple:   Color = Color(hex: "#BF5AF2")
    static let textPrimary:    Color = .appTextPrimary
    static let textMuted:      Color = .appTextSecondary
    static let border:         Color = .appBorder
}
