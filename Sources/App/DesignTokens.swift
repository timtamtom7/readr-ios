import SwiftUI

// MARK: - Design Tokens
enum DesignTokens {
    static let bgLight = Color(hex: "faf8f5")
    static let bgDark = Color(hex: "141210")
    static let surfaceLight = Color(hex: "ffffff")
    static let surfaceDark = Color(hex: "1e1c1a")
    static let textPrimary = Color(hex: "1c1917")
    static let textSecondary = Color(hex: "78716c")
    static let accent = Color(hex: "c87b4f")
    static let bookPlaceholder = Color(hex: "e8e0d5")

    // MARK: - Corner Radius Tokens (iOS 26 Liquid Glass)
    enum CornerRadius {
        /// Extra small: 6pt
        static let xs: CGFloat = 6
        /// Small: 8pt
        static let small: CGFloat = 8
        /// Medium: 10pt
        static let medium: CGFloat = 10
        /// Default: 12pt
        static let `default`: CGFloat = 12
        /// Large: 14pt
        static let large: CGFloat = 14
        /// Extra large: 16pt
        static let xl: CGFloat = 16
        /// XXL: 20pt
        static let xxl: CGFloat = 20
    }

    static var background: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "141210")
                : UIColor(hex: "faf8f5")
        })
    }

    static var surface: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "1e1c1a")
                : UIColor(hex: "ffffff")
        })
    }

    static var primaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "f5f0eb")
                : UIColor(hex: "1c1917")
        })
    }

    static var secondaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "a8a29e")
                : UIColor(hex: "78716c")
        })
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
