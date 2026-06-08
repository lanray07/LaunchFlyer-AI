import SwiftUI

struct OneTapCampaignPackView: View {
    var campaign: GeneratedCampaign?
    var onRegenerateAll: () -> Void = {}

    private var resolvedCampaign: GeneratedCampaign {
        campaign ?? SampleData.generatedCampaign
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("One-Tap Campaign Pack", title: "Complete launch set")
            GlassPanel {
                VStack(alignment: .leading, spacing: 16) {
                    SocialPackPreview(assets: resolvedCampaign.assets)
                    HStack(spacing: 10) {
                        Button {
                            onRegenerateAll()
                        } label: {
                            Label("Regenerate all", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        NavigationLink {
                            ExportCenterView()
                        } label: {
                            Label("Export all", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(PremiumButtonStyle())
                    }
                }
            }
        }
    }
}
