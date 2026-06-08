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

                        ForEach(SubscriptionPlan.allCases.filter { $0 != .free }) { plan in
                            PlanRow(plan: plan)
                        }

                        Button("Restore Purchases") {
                            Task { await services.subscriptionService.restorePurchases() }
                        }
                        .buttonStyle(SecondaryButtonStyle())
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
}

private struct PlanRow: View {
    var plan: SubscriptionPlan

    var body: some View {
        GlassPanel {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(plan.rawValue) Plan")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    Text(features)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.62))
                }
                Spacer()
                Text(plan.price)
                    .font(.headline.bold())
                    .foregroundStyle(.launchMint)
            }
        }
    }

    private var features: String {
        switch plan {
        case .creator:
            return "Unlimited campaigns, premium templates, no watermark."
        case .business:
            return "Brand kit, batch exports, event packs, print-ready exports."
        case .agency:
            return "Multiple brand kits, white-label exports, client folders."
        case .free:
            return "3 campaigns/month, basic templates, watermark."
        }
    }
}
