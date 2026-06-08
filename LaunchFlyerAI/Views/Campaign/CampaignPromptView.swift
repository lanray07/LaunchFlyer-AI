import SwiftData
import SwiftUI

struct CampaignPromptView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CampaignPromptViewModel()

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Generator", title: "Campaign Prompt")
                    promptForm
                    generateButton
                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }
                    if let campaign = viewModel.generatedCampaign {
                        generatedResults(campaign)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Create")
    }

    private var promptForm: some View {
        GlassPanel {
            VStack(spacing: 16) {
                Picker("Campaign type", selection: $viewModel.campaignType) {
                    ForEach(CampaignType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)

                PremiumTextField("Business or event name", text: $viewModel.businessName)
                PremiumTextField("Date/time", text: $viewModel.dateTime)
                PremiumTextField("Location", text: $viewModel.location)
                PremiumTextField("Offer", text: $viewModel.offer)
                PremiumTextField("Target audience", text: $viewModel.targetAudience)
                PremiumTextField("Call to action", text: $viewModel.callToAction)

                Picker("Visual style", selection: $viewModel.visualStyle) {
                    ForEach(VisualStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                TextEditor(text: $viewModel.brief)
                    .frame(minHeight: 118)
                    .padding(12)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if viewModel.brief.isEmpty {
                            Text("Describe the campaign, audience, vibe, and must-have details.")
                                .foregroundStyle(.white.opacity(0.38))
                                .padding(.top, 20)
                                .padding(.leading, 17)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
    }

    private var generateButton: some View {
        Button {
            Task { @MainActor in
                await viewModel.generate(using: services)
                saveGeneratedCampaign()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.black)
            } else {
                Label("Generate Campaign Pack", systemImage: "sparkles")
            }
        }
        .buttonStyle(PremiumButtonStyle())
        .disabled(viewModel.isLoading)
    }

    private func generatedResults(_ campaign: GeneratedCampaign) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Campaign concept")
                        .font(.headline)
                        .foregroundStyle(.launchMint)
                    Text(campaign.campaignConcept)
                        .foregroundStyle(.white.opacity(0.72))
                    Divider().overlay(.white.opacity(0.1))
                    ForEach(campaign.headlines, id: \.self) { headline in
                        Label(headline, systemImage: "quote.opening")
                            .foregroundStyle(.white)
                    }
                }
            }

            if let design = viewModel.flyerDesign {
                FlyerCanvasView(document: design)
                    .frame(height: 460)
            }

            OneTapCampaignPackView(campaign: campaign) {
                Task { @MainActor in
                    await viewModel.generate(using: services)
                }
            }
        }
    }

    @MainActor
    private func saveGeneratedCampaign() {
        guard let generated = viewModel.generatedCampaign else { return }
        let title = viewModel.businessName.isEmpty ? generated.headlines.first ?? "Untitled campaign" : viewModel.businessName
        let campaign = Campaign(
            title: title,
            campaignType: viewModel.campaignType.rawValue,
            brief: viewModel.brief,
            style: viewModel.visualStyle.rawValue
        )
        modelContext.insert(campaign)
        for asset in generated.assets {
            modelContext.insert(
                CampaignAsset(
                    campaignId: campaign.id,
                    assetType: asset.type.rawValue,
                    designData: asset.headline,
                    exportFormat: ExportFormat.png.rawValue
                )
            )
        }
        try? modelContext.save()
    }
}

struct PremiumTextField: View {
    var title: String
    @Binding var text: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        _text = text
    }

    var body: some View {
        TextField(title, text: $text)
            .textInputAutocapitalization(.words)
            .foregroundStyle(.white)
            .padding(14)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
    }
}

struct ErrorBanner: View {
    var message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.launchBerry.opacity(0.32), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
