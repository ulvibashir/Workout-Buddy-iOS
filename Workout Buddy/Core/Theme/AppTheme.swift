import SwiftUI

enum AppTheme {
    static let background        = Color(hex: "#0f0f1a")
    static let cardBackground    = Color(hex: "#1a1a2e")
    static let cardSecondary     = Color(hex: "#242442")
    static let border            = Color(hex: "#2d2d4e")
    static let textPrimary       = Color.white
    static let textMuted         = Color(hex: "#9ca3af")
    static let accent            = Color(hex: "#e94560")
    static let accentBlue        = Color(hex: "#0077b6")
    static let accentGreen       = Color(hex: "#0f9b58")
    static let accentOrange      = Color(hex: "#fd7e14")
    static let accentPurple      = Color(hex: "#6f42c1")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
