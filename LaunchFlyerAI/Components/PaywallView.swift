import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var services: AppServices

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        freePlan
                        subscriptionPlans
                        restoreButton
                        legalLine

                        if let message = services.subscriptionService.errorMessage {
                            ErrorBanner(message: message)
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .task {
                await services.subscriptionService.loadProducts()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(.launchGold)
            Text("LaunchFlyer AI Pro")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Unlimited campaigns, premium templates, no watermark, AI copywriter, brand kits, batch exports, and agency workflows.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.66))
        }
        .padding(.top, 26)
    }

    private var freePlan: some View {
        GlassPanel(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Free Plan", systemImage: "sparkles")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Text("3/month")
                        .font(.headline.bold())
                        .foregroundStyle(.launchMint)
                }
                FeatureList(features: SubscriptionPlan.free.includedFeatures)
            }
        }
    }

    private var subscriptionPlans: some View {
        VStack(spacing: 14) {
            ForEach(SubscriptionSKU.allCases) { sku in
                PlanRow(
                    sku: sku,
                    price: services.subscriptionService.displayPrice(for: sku),
                    isCurrent: services.subscriptionService.currentProductID == sku.rawValue,
                    isPurchasing: services.subscriptionService.purchasingProductID == sku.rawValue,
                    canPurchase: services.subscriptionService.product(for: sku) != nil
                ) {
                    Task {
                        await services.subscriptionService.purchase(sku)
                    }
                }
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await services.subscriptionService.restorePurchases() }
        } label: {
            Label("Restore Purchases", systemImage: "arrow.clockwise")
        }
        .buttonStyle(SecondaryButtonStyle())
    }

    private var legalLine: some View {
        VStack(spacing: 8) {
            Text("Subscriptions renew automatically until cancelled. Manage or cancel from your Apple ID subscriptions.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: LegalLinks.privacyPolicy)
                Link("Terms of Use", destination: LegalLinks.termsOfUse)
            }
            .font(.caption.bold())
            .foregroundStyle(.launchMint)
        }
    }
}

private struct PlanRow: View {
    var sku: SubscriptionSKU
    var price: String
    var isCurrent: Bool
    var isPurchasing: Bool
    var canPurchase: Bool
    var action: () -> Void

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(sku.displayName)
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            if let badge = sku.badge {
                                Text(badge)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 5)
                                    .background(.launchGold, in: Capsule())
                            }
                        }

                        Text("\(price) \(sku.cadence)")
                            .font(.title3.bold())
                            .foregroundStyle(.launchMint)
                    }
                    Spacer()
                    Image(systemName: isCurrent ? "checkmark.seal.fill" : "crown.fill")
                        .foregroundStyle(isCurrent ? .launchMint : .white.opacity(0.5))
                }

                FeatureList(features: sku.benefits)

                Button(action: action) {
                    if isPurchasing {
                        ProgressView()
                            .tint(.black)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(buttonTitle)
                    }
                }
                .buttonStyle(PremiumButtonStyle())
                .disabled(isCurrent || !canPurchase || isPurchasing)

                if !canPurchase {
                    Text("Product ID: \(sku.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.46))
                }
            }
        }
    }

    private var buttonTitle: String {
        if isCurrent { return "Current plan" }
        if !canPurchase { return "StoreKit setup required" }
        return "Choose \(sku.plan.rawValue)"
    }
}

private struct FeatureList: View {
    var features: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.launchMint)
                    Text(feature)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                }
            }
        }
    }
}
