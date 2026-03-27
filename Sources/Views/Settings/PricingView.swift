import SwiftUI

// MARK: - Subscription Tier Model
struct SubscriptionTier: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let period: String
    let tagline: String
    let features: [String]
    let isPopular: Bool
    let accentColor: Color

    static let free = SubscriptionTier(
        name: "Free",
        price: "$0",
        period: "forever",
        tagline: "Just getting started",
        features: [
            "5 scans per month",
            "Basic quote export",
            "Up to 10 books saved",
            "No cloud sync"
        ],
        isPopular: false,
        accentColor: DesignTokens.secondaryText
    )

    static let pro = SubscriptionTier(
        name: "Pro",
        price: "$4.99",
        period: "per month",
        tagline: "For serious readers",
        features: [
            "Unlimited scans",
            "Export quotes to PDF",
            "Cloud sync across devices",
            "Tags & highlights",
            "Priority OCR processing"
        ],
        isPopular: true,
        accentColor: DesignTokens.accent
    )

    static let scholar = SubscriptionTier(
        name: "Scholar",
        price: "$9.99",
        period: "per month",
        tagline: "For researchers & academics",
        features: [
            "Everything in Pro",
            "Unlimited book library",
            "Reading analytics",
            "Citation export (BibTeX, APA, MLA)",
            "AI book recommendations",
            "Priority support"
        ],
        isPopular: false,
        accentColor: Color(hex: "7b6bab")
    )
}

// MARK: - Pricing View
struct PricingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier?
    @State private var showingSubscribeButton = false

    private let tiers: [SubscriptionTier] = [.free, .pro, .scholar]

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Tier cards
                        VStack(spacing: 16) {
                            ForEach(tiers) { tier in
                                TierCard(
                                    tier: tier,
                                    isSelected: selectedTier?.id == tier.id,
                                    onSelect: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTier = tier
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Subscribe button
                        if let tier = selectedTier, tier.name != "Free" {
                            subscribeButton(for: tier)
                                .padding(.horizontal, 20)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Legal note
                        Text("Subscriptions auto-renew unless cancelled 24h before the period ends. Manage in Settings > Subscriptions.")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Choose Your Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        Theme.Haptics.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                    .accessibilityLabel("Close pricing")
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 32))
                .foregroundStyle(DesignTokens.accent)

            Text("Unlock your reading library")
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(DesignTokens.primaryText)

            Text("Capture every passage that moves you — without limits.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    private func subscribeButton(for tier: SubscriptionTier) -> some View {
        VStack(spacing: 12) {
            Button {
                Theme.Haptics.medium()
                // In production: trigger StoreKit purchase flow
            } label: {
                HStack {
                    Text("Start \(tier.name)")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(tier.price)/mo")
                        .fontWeight(.medium)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        colors: [tier.accentColor, tier.accentColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Start \(tier.name) subscription at \(tier.price) per month")

            Text("Try 7 days free — cancel anytime")
                .font(.caption)
                .foregroundStyle(DesignTokens.secondaryText)
        }
    }
}

// MARK: - Tier Card
struct TierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button {
            Theme.Haptics.selection()
            onSelect()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Popular badge
                if tier.isPopular {
                    HStack {
                        Text("Most Popular")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(tier.accentColor)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
                }

                // Header row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tier.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignTokens.primaryText)

                        Text(tier.tagline)
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(tier.price)
                            .font(.system(.title, design: .serif, weight: .bold))
                            .foregroundStyle(tier.accentColor)

                        Text(tier.period)
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }

                Divider()
                    .padding(.vertical, 12)

                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundStyle(tier.accentColor)
                                .frame(width: 16)

                            Text(feature)
                                .font(.subheadline)
                                .foregroundStyle(DesignTokens.primaryText)
                        }
                    }
                }

                // Selection indicator
                HStack {
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? tier.accentColor : DesignTokens.secondaryText.opacity(0.4))
                }
                .padding(.top, 12)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(paperGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? tier.accentColor : Color(hex: "e0d8c8"),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? tier.accentColor.opacity(0.15) : Color.black.opacity(0.04),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tier.name) plan, \(tier.price) per month")
    }

    private var paperGradient: some ShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color(hex: "fffdf8"),
                    Color(hex: "faf5ee"),
                    Color(hex: "f5efe4")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview("Pricing") {
    PricingView()
}
