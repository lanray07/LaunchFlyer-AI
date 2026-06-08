import SwiftUI

struct SocialMediaPackBuilderView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = CampaignPromptViewModel()
    @State private var didLoadPreset = false

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Social Pack", title: "Every channel")
                    GlassPanel {
                        VStack(spacing: 16) {
                            PremiumTextField("Brand or offer", text: $viewModel.businessName)
                            PremiumTextField("Launch date/time", text: $viewModel.dateTime)
                            PremiumTextField("Location or link", text: $viewModel.location)
                            PremiumTextField("Offer", text: $viewModel.offer)
                            PremiumTextField("Audience", text: $viewModel.targetAudience)
                            PremiumTextField("CTA", text: $viewModel.callToAction)
                            PremiumTextField("Contact details", text: $viewModel.contactDetails)
                            Picker("Style", selection: $viewModel.visualStyle) {
                                ForEach(VisualStyle.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            PremiumTextEditor(
                                title: "Channel deliverables",
                                placeholder: "Instagram post, story, Reel cover, Facebook post, LinkedIn promo, Pinterest pin, WhatsApp status.",
                                text: $viewModel.deliverables,
                                minHeight: 96
                            )
                            PremiumTextEditor(
                                title: "Social creative notes",
                                placeholder: "Add hook, image direction, platform tone, and caption requirements.",
                                text: $viewModel.brandNotes,
                                minHeight: 96
                            )
                        }
                    }

                    Button {
                        viewModel.brief = "Create a complete social media pack for \(viewModel.businessName) with platform-specific copy, sizes, hooks, and CTAs."
                        Task { await viewModel.generate(using: services) }
                    } label: {
                        Label("Generate Social Pack", systemImage: "square.grid.2x2.fill")
                    }
                    .buttonStyle(PremiumButtonStyle())

                    SocialPackPreview(assets: viewModel.generatedCampaign?.assets ?? SampleData.generatedCampaign.assets)
                }
                .padding()
            }
        }
        .navigationTitle("Social")
        .onAppear {
            guard !didLoadPreset else { return }
            viewModel.applyPreset(.restaurantLaunch)
            viewModel.deliverables = "Instagram post, Instagram story, Facebook post, TikTok cover, LinkedIn promo, Pinterest pin, WhatsApp status, captions, hashtags, and email teaser."
            didLoadPreset = true
        }
    }
}
