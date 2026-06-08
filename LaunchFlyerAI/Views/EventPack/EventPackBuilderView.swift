import SwiftUI

struct EventPackBuilderView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = CampaignPromptViewModel()
    @State private var didLoadPreset = false

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Event Pack", title: "Before and after")
                    GlassPanel {
                        VStack(spacing: 16) {
                            PremiumTextField("Event name", text: $viewModel.businessName)
                            PremiumTextField("Date/time", text: $viewModel.dateTime)
                            PremiumTextField("Location", text: $viewModel.location)
                            PremiumTextField("Offer or event promise", text: $viewModel.offer)
                            PremiumTextField("Target audience", text: $viewModel.targetAudience)
                            PremiumTextField("RSVP or ticket CTA", text: $viewModel.callToAction)
                            PremiumTextField("Contact details", text: $viewModel.contactDetails)
                            Picker("Style", selection: $viewModel.visualStyle) {
                                ForEach(VisualStyle.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            PremiumTextEditor(
                                title: "Event pack assets",
                                placeholder: "Event flyer, RSVP graphic, countdown story, speaker announcement, reminder post, thank-you post.",
                                text: $viewModel.deliverables,
                                minHeight: 96
                            )
                            PremiumTextEditor(
                                title: "Event details",
                                placeholder: "Add speakers, agenda, age range, ticket notes, dress code, sponsors, or accessibility details.",
                                text: $viewModel.brief,
                                minHeight: 120
                            )
                        }
                    }

                    Button {
                        viewModel.campaignType = .event
                        viewModel.brief = "Generate an event flyer, RSVP graphic, countdown story, speaker announcement, reminder post, and thank-you post."
                        Task { await viewModel.generate(using: services) }
                    } label: {
                        Label("Generate Event Pack", systemImage: "calendar.badge.plus")
                    }
                    .buttonStyle(PremiumButtonStyle())

                    eventAssets
                }
                .padding()
            }
        }
        .navigationTitle("Event Pack")
        .onAppear {
            guard !didLoadPreset else { return }
            viewModel.applyPreset(.churchEvent)
            didLoadPreset = true
        }
    }

    private var eventAssets: some View {
        let base = viewModel.generatedCampaign?.assets ?? SampleData.generatedCampaign.assets
        let mapped = ["Event flyer", "RSVP graphic", "Countdown story", "Speaker announcement", "Reminder post", "Thank-you post"]
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 16) {
            ForEach(Array(mapped.enumerated()), id: \.offset) { index, title in
                let asset = base[index % base.count]
                CampaignAssetPreview(title: title, subtitle: asset.subtitle, assetType: asset.type, style: asset.style)
            }
        }
    }
}
