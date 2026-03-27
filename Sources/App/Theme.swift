import SwiftUI

// MARK: - iOS 26 Liquid Glass Theme
// Design system aligned with Apple's Liquid Glass design language

enum Theme {

    // MARK: - Corner Radius Tokens (iOS 26 Liquid Glass)
    enum CornerRadius {
        /// Extra small: 6pt — tags, small chips
        static let xs: CGFloat = 6
        /// Small: 8pt — small cards, thumbnails
        static let small: CGFloat = 8
        /// Medium: 10pt — list items, compact cards
        static let medium: CGFloat = 10
        /// Default: 12pt — standard cards, surfaces
        static let `default`: CGFloat = 12
        /// Large: 14pt — feature cards, modals
        static let large: CGFloat = 14
        /// Extra large: 16pt — major surfaces, sheets
        static let xl: CGFloat = 16
        /// XXL: 20pt — capture view frames
        static let xxl: CGFloat = 20
        /// xxxl: 24pt — full-width liquid glass surfaces
        static let xxxl: CGFloat = 24
    }

    // MARK: - Font Size (minimum 11pt per iOS 26 accessibility)
    enum FontSize {
        static let min: CGFloat = 11

        /// Caption minimum: 11pt (maps to .caption)
        static let caption: CGFloat = 11
        /// Caption 2 minimum: 11pt
        static let caption2: CGFloat = 11
        /// Footnote: 11pt
        static let footnote: CGFloat = 11
        /// Subheadline: 13pt
        static let subheadline: CGFloat = 13
        /// Body: 15pt
        static let body: CGFloat = 15
        /// Callout: 17pt
        static let callout: CGFloat = 17
        /// Headline: 18pt
        static let headline: CGFloat = 18
        /// Title 3: 20pt
        static let title3: CGFloat = 20
        /// Title 2: 22pt
        static let title2: CGFloat = 22
        /// Title: 24pt
        static let title: CGFloat = 24
        /// Large title: 28pt
        static let largeTitle: CGFloat = 28
    }

    // MARK: - Haptic Feedback
    enum Haptics {
        /// Light impact — subtle UI feedback
        static func light() {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Medium impact — standard button press
        static func medium() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Heavy impact — significant actions
        static func heavy() {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Soft impact — iOS 26 Liquid Glass feel
        static func soft() {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Rigid impact — iOS 26 Liquid Glass feel
        static func rigid() {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare()
            generator.impactOccurred()
        }

        /// Selection changed
        static func selection() {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }

        /// Success notification
        static func success() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }

        /// Warning notification
        static func warning() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)
        }

        /// Error notification
        static func error() {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }

    // MARK: - Button Styles

    /// Primary liquid glass button — filled accent
    struct PrimaryButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isEnabled ? DesignTokens.accent : DesignTokens.accent.opacity(0.4))
                )
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    /// Secondary liquid glass button — outlined
    struct SecondaryButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: Theme.FontSize.body, weight: .medium))
                .foregroundStyle(isEnabled ? DesignTokens.accent : DesignTokens.accent.opacity(0.4))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .stroke(isEnabled ? DesignTokens.accent : DesignTokens.accent.opacity(0.4), lineWidth: 1.5)
                )
                .opacity(configuration.isPressed ? 0.7 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    /// Icon button — circular touch target
    struct IconButtonStyle: ButtonStyle {
        let size: CGFloat

        init(size: CGFloat = 44) {
            self.size = size
        }

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(DesignTokens.surface.opacity(configuration.isPressed ? 0.6 : 0.0))
                )
                .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
        }
    }

    /// Card button — pressable card surface
    struct CardButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .opacity(configuration.isPressed ? 0.85 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

// MARK: - Font Extension
extension Font {
    static let liquidGlassCaption: Font = .system(size: Theme.FontSize.caption, weight: .regular)
    static let liquidGlassCaptionMedium: Font = .system(size: Theme.FontSize.caption, weight: .medium)
    static let liquidGlassFootnote: Font = .system(size: Theme.FontSize.footnote, weight: .regular)
    static let liquidGlassBody: Font = .system(size: Theme.FontSize.body, weight: .regular)
    static let liquidGlassBodyMedium: Font = .system(size: Theme.FontSize.body, weight: .medium)
    static let liquidGlassHeadline: Font = .system(size: Theme.FontSize.headline, weight: .semibold)
}
