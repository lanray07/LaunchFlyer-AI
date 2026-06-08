import SwiftData
import SwiftUI

struct AnalyticsView: View {
    @Query private var campaigns: [Campaign]
    @Query private var exports: [ExportRecord]
    @Query private var assets: [CampaignAsset]

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader("Analytics", title: "Launch signals")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricPill(title: "Campaigns created", value: "\(campaigns.count)", icon: "megaphone.fill")
                        MetricPill(title: "Exports generated", value: "\(exports.count)", icon: "square.and.arrow.up.fill")
                        MetricPill(title: "Assets drafted", value: "\(assets.count)", icon: "photo.stack.fill")
                        MetricPill(title: "Brand consistency", value: "92%", icon: "checkmark.seal.fill")
                    }
                    GlassPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Template usage")
                                .font(.headline)
                                .foregroundStyle(.white)
                            ProgressView(value: campaigns.isEmpty ? 0.2 : 0.72)
                                .tint(.launchMint)
                            Text("Placeholder analytics are ready for backend events, export tracking, and template performance.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Analytics")
    }
}
