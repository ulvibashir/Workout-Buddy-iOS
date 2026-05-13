import SwiftUI
import UIKit

enum AppTheme {
    static let background     = Color(adaptive(dark: "#0f0f1a", light: "#f2f2f7"))
    static let cardBackground = Color(adaptive(dark: "#1a1a2e", light: "#ffffff"))
    static let cardSecondary  = Color(adaptive(dark: "#242442", light: "#f1f3f5"))
    static let border         = Color(adaptive(dark: "#2d2d4e", light: "#d1d1d6"))
    static let textPrimary    = Color(adaptive(dark: "#ffffff", light: "#0f0f1a"))
    static let textMuted      = Color(adaptive(dark: "#9ca3af", light: "#6c757d"))

    // Accent colors — same hue in both modes, lighter shade for light bg
    static let accent        = Color(adaptive(dark: "#e94560", light: "#d63251"))
    static let accentBlue    = Color(adaptive(dark: "#1a8cd8", light: "#0077b6"))
    static let accentGreen   = Color(adaptive(dark: "#0f9b58", light: "#0a7a46"))
    static let accentOrange  = Color(adaptive(dark: "#fd7e14", light: "#e06a00"))
    static let accentPurple  = Color(adaptive(dark: "#8b5cf6", light: "#6f42c1"))
}

// MARK: - Helpers

private func adaptive(dark darkHex: String, light lightHex: String) -> UIColor {
    UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: darkHex) : UIColor(hex: lightHex) }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8)  & 0xFF) / 255,
            blue:  CGFloat(rgb         & 0xFF) / 255,
            alpha: 1
        )
    }
}
