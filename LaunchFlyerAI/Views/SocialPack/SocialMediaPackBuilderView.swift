import SwiftUI

struct SocialMediaPackBuilderView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = CampaignPromptViewModel()

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Social Pack", title: "Every channel")
                    GlassPanel {
                        VStack(spacing: 16) {
                            PremiumTextField("Brand or offer", text: $viewModel.businessName)
                            PremiumTextField("Audience", text: $viewModel.targetAudience)
                            PremiumTextField("CTA", text: $viewModel.callToAction)
                            Picker("Style", selection: $viewModel.visualStyle) {
                                ForEach(VisualStyle.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    Button {
                        viewModel.brief = "Create a complete social media pack for \(viewModel.businessName)."
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
    }
}
