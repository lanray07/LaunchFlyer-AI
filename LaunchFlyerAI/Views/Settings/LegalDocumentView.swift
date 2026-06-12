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

                            if let externalURL = document.externalURL {
                                Link("Open \(document.title)", destination: externalURL)
                                    .buttonStyle(SecondaryButtonStyle())
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
    var externalURL: URL?

    static let privacy = LegalDocument(
        title: "Privacy Policy",
        sections: [
            .init(title: "Data storage", body: "LaunchFlyer AI stores campaigns, brand kits, voice transcripts, exports, and subscription state locally on device using SwiftData unless a remote backend is configured."),
            .init(title: "Voice input", body: "Speech recognition is used only after permission is granted. Transcripts can be edited before generation and are stored locally for campaign history."),
            .init(title: "AI requests", body: "Mock AI is enabled by default. When RemoteAIService is enabled, campaign briefs are sent to the configured backend endpoint for generation."),
            .init(title: "Purchases", body: "Subscriptions are processed through Apple StoreKit and managed by the user's Apple ID subscription settings.")
        ],
        externalURL: LegalLinks.privacyPolicy
    )

    static let terms = LegalDocument(
        title: "Terms of Use",
        sections: [
            .init(title: "Creative output", body: "Generated flyers, captions, hashtags, and campaign packs are editable creative drafts. Users are responsible for reviewing claims, dates, offers, and legal compliance before publishing."),
            .init(title: "Subscriptions", body: "Premium plans unlock advanced templates, unlimited campaigns, export capabilities, brand kits, and agency workflows according to the active StoreKit entitlement. Subscription titles, durations, and prices are shown before purchase. Subscriptions renew automatically until cancelled and can be managed from Apple ID subscription settings."),
            .init(title: "Acceptable use", body: "Users may not generate deceptive, infringing, abusive, unsafe, or unlawful promotional material."),
            .init(title: "Service changes", body: "Features, templates, export formats, and backend AI providers may evolve as LaunchFlyer AI grows.")
        ],
        externalURL: LegalLinks.termsOfUse
    )
}

struct LegalSection: Hashable {
    var title: String
    var body: String
}

enum LegalLinks {
    static let privacyPolicy = URL(string: "https://lanray07.github.io/LaunchFlyer-AI/privacy-policy.html")!
    static let termsOfUse = URL(string: "https://lanray07.github.io/LaunchFlyer-AI/terms-of-use.html")!
    static let appleStandardEULA = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}
