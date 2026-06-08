import SwiftUI

struct CampaignPreviewStudioView: View {
    var campaign: GeneratedCampaign = SampleData.generatedCampaign

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Preview Studio", title: "Launch context")
                    mobileMockups
                    feedPreview
                    whatsappPreview
                }
                .padding()
            }
        }
        .navigationTitle("Preview")
    }

    private var mobileMockups: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(campaign.assets.prefix(4)) { asset in
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.black)
                        .frame(width: 190, height: 360)
                        .overlay {
                            CampaignAssetPreview(title: asset.headline, subtitle: asset.subtitle, assetType: asset.type, style: asset.style)
                                .padding(16)
                        }
                        .overlay(RoundedRectangle(cornerRadius: 34).stroke(.white.opacity(0.12), lineWidth: 1))
                }
            }
        }
    }

    private var feedPreview: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Social feed preview", systemImage: "rectangle.grid.1x2.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(campaign.socialCaptions.first ?? "")
                    .foregroundStyle(.white.opacity(0.66))
                SocialPackPreview(assets: Array(campaign.assets.prefix(3)))
            }
        }
    }

    private var whatsappPreview: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 10) {
                Label("WhatsApp flyer preview", systemImage: "message.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(campaign.flyerCopy)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
