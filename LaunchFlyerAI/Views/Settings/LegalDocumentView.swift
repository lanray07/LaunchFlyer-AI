import SwiftUI

struct LegalDocumentView: View {
    var document: LegalDocument

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader("Legal", title: document.title)
                    GlassPanel {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(document.sections, id: \.title) { section in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(section.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(section.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.68))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(document.title)
    }
}

struct LegalDocument: Hashable {
    var title: String
    var sections: [LegalSection]

    static let privacy = LegalDocument(
        title: "Privacy Policy",
        sections: [
            .init(title: "Data storage", body: "LaunchFlyer AI stores campaigns, brand kits, voice transcripts, exports, and subscription state locally on device using SwiftData unless a remote backend is configured."),
            .init(title: "Voice input", body: "Speech recognition is used only after permission is granted. Transcripts can be edited before generation and are stored locally for campaign history."),
            .init(title: "AI requests", body: "Mock AI is enabled by default. When RemoteAIService is enabled, campaign briefs are sent to the configured backend endpoint for generation."),
            .init(title: "Purchases", body: "Subscriptions are processed through Apple StoreKit and managed by the user's Apple ID subscription settings.")
        ]
    )

    static let terms = LegalDocument(
        title: "Terms of Use",
        sections: [
            .init(title: "Creative output", body: "Generated flyers, captions, hashtags, and campaign packs are editable creative drafts. Users are responsible for reviewing claims, dates, offers, and legal compliance before publishing."),
            .init(title: "Subscriptions", body: "Premium plans unlock advanced templates, unlimited campaigns, export capabilities, brand kits, and agency workflows according to the active StoreKit entitlement."),
            .init(title: "Acceptable use", body: "Users may not generate deceptive, infringing, abusive, unsafe, or unlawful promotional material."),
            .init(title: "Service changes", body: "Features, templates, export formats, and backend AI providers may evolve as LaunchFlyer AI grows.")
        ]
    )
}

struct LegalSection: Hashable {
    var title: String
    var body: String
}
