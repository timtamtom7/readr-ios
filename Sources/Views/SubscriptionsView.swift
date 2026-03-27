import SwiftUI

/// R10: Subscriptions page with tier comparison
struct ReadrSubscriptionsView: View {
    @State private var selectedPlan: SubscriptionPlan?

    enum SubscriptionPlan: String, CaseIterable {
        case premium = "Premium"
        case pro = "Pro"

        var price: String {
            switch self {
            case .premium: return "$4.99"
            case .pro: return "$9.99"
            }
        }

        var period: String {
            "/month"
        }

        var features: [String] {
            switch self {
            case .premium:
                return [
                    "Unlimited book scanning",
                    "Cloud backup",
                    "Reading insights",
                    "Export quotes",
                    "Priority support"
                ]
            case .pro:
                return [
                    "Everything in Premium",
                    "Unlimited cloud storage",
                    "Team sharing",
                    "API access",
                    "Dedicated support"
                ]
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        plansSection
                        faqSection
                    }
                    .padding(16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Subscribe")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(DesignTokens.accent)

            VStack(spacing: 8) {
                Text("Unlock Premium Features")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DesignTokens.primaryText)

                Text("Get unlimited scanning, cloud backup, and advanced insights.")
                    .font(.system(size: 15))
                    .foregroundColor(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }

    private var plansSection: some View {
        VStack(spacing: 12) {
            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.primaryText)

                    HStack(spacing: 4) {
                        Text(plan.price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DesignTokens.accent)
                        Text(plan.period)
                            .font(.system(size: 14))
                            .foregroundColor(DesignTokens.secondaryText)
                    }
                }

                Spacer()
            }
            .padding(16)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(DesignTokens.accent)

                        Text(feature)
                            .font(.system(size: 14))
                            .foregroundColor(DesignTokens.primaryText)
                    }
                }
            }
            .padding(16)

            Button {
                Theme.Haptics.medium()
                selectedPlan = plan
            } label: {
                Text("Subscribe")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(DesignTokens.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .accessibilityLabel("Subscribe to \(plan.rawValue) plan")
        }
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FAQ")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignTokens.primaryText)

            VStack(spacing: 0) {
                faqRow(question: "Can I cancel anytime?", answer: "Yes, you can cancel your subscription at any time.")
                Divider()
                faqRow(question: "What happens to my data if I cancel?", answer: "Your scanned books remain accessible. Premium features revert to free tier limits.")
                Divider()
                faqRow(question: "Is there a free trial?", answer: "Yes, new subscribers get a 7-day free trial.")
            }
            .background(DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func faqRow(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(DesignTokens.primaryText)

            Text(answer)
                .font(.system(size: 13))
                .foregroundColor(DesignTokens.secondaryText)
        }
        .padding(14)
    }
}
