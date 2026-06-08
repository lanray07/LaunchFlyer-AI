import Foundation

final class MockAIService: CampaignAIProvider {
    private let internalPrompt = "You are LaunchFlyer AI, a premium marketing campaign assistant. Help users turn event, product, service, and business ideas into professional promotional campaign packs. Generate strong headlines, clear CTAs, campaign copy, and visual direction. Prioritize clarity, beauty, conversion, and brand consistency."

    func generateCampaign(from request: CampaignRequest) async throws -> GeneratedCampaign {
        try validate(request)
        try await Task.sleep(nanoseconds: 350_000_000)

        let name = request.businessName.isEmpty ? request.campaignType.rawValue : request.businessName
        let primaryHeadline = "\(name): \(request.offer.isEmpty ? "Launch Weekend" : request.offer)"
        let audience = request.targetAudience.isEmpty ? "local customers" : request.targetAudience
        let cta = request.callToAction.isEmpty ? "Book now" : request.callToAction

        return GeneratedCampaign(
            campaignConcept: "\(internalPrompt) Concept: a polished \(request.style.rawValue.lowercased()) launch campaign for \(audience), built around a clear offer and fast-action CTA.",
            headlines: [
                primaryHeadline,
                "One idea. Complete campaign.",
                "Launch anything in minutes.",
                "Make this promotion impossible to miss."
            ],
            flyerCopy: "\(request.campaignBrief)\n\n\(request.dateTime) \(request.location)\n\(cta).",
            socialCaptions: [
                "Big news: \(name) is ready to launch. \(cta) and be part of it.",
                "Your next favorite \(request.campaignType.rawValue.lowercased()) is here. Save the date and spread the word.",
                "Built for \(audience). Designed to move fast. \(cta)."
            ],
            hashtags: ["#LaunchFlyerAI", "#LocalMarketing", "#SmallBusiness", "#PromoDesign", "#LaunchDay"],
            designSuggestions: [
                "Use a dark glass base with electric contrast gradients.",
                "Lead with a bold offer, then stack date, place, and CTA.",
                "Create square, story, banner, and print variants from one shared layout."
            ],
            assets: Self.assets(for: request, headline: primaryHeadline, cta: cta)
        )
    }

    func generateFlyerDesign(from request: CampaignRequest) async throws -> FlyerDesignDocument {
        let campaign = try await generateCampaign(from: request)
        return FlyerDesignDocument(
            headline: campaign.headlines.first ?? "Launch anything in minutes.",
            subtitle: "One idea. Complete campaign.",
            offer: request.offer.isEmpty ? "Limited-time launch offer" : request.offer,
            eventDetails: [request.dateTime, request.location].filter { !$0.isEmpty }.joined(separator: " • "),
            callToAction: request.callToAction.isEmpty ? "Reserve now" : request.callToAction,
            imagePlaceholder: "Campaign image slot",
            logoPlaceholder: request.businessName.isEmpty ? "Logo" : request.businessName,
            qrCodePlaceholder: "QR code",
            contactDetails: "Website • Instagram • Phone",
            style: request.style,
            layout: .hero,
            spacing: 18
        )
    }

    func generateSocialPack(from request: CampaignRequest) async throws -> [CampaignPackAsset] {
        try validate(request)
        try await Task.sleep(nanoseconds: 250_000_000)
        let headline = request.businessName.isEmpty ? "New Campaign" : request.businessName
        return Self.assets(for: request, headline: headline, cta: request.callToAction.isEmpty ? "Learn more" : request.callToAction)
    }

    func generateCopy(from request: CopywritingRequest) async throws -> [String] {
        guard !request.topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.emptyPrompt
        }

        try await Task.sleep(nanoseconds: 220_000_000)
        return [
            "\(request.topic): crafted for attention, built for action.",
            "A \(request.tone.rawValue.lowercased()) campaign line for \(request.audience.isEmpty ? "your audience" : request.audience).",
            "Turn the moment into momentum with a clear offer and a confident CTA.",
            "Now live: \(request.topic). Save it, share it, and show up."
        ]
    }

    func recommendTemplates(for profile: UserProfile?, goal: MainGoal?) async -> [TemplateDescriptor] {
        let targetCategory = profile?.userType ?? "Business"
        return TemplateCatalog.default.templates
            .filter { $0.category.localizedCaseInsensitiveContains(targetCategory) || $0.isFeatured }
            .prefix(8)
            .map { $0 }
    }

    func generateFromVoice(transcript: String) async throws -> GeneratedCampaign {
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.emptyPrompt
        }

        let request = CampaignRequest(
            module: "voice-campaign",
            campaignType: .event,
            businessName: "Voice Campaign",
            campaignBrief: transcript,
            voiceTranscript: transcript,
            dateTime: "",
            location: "",
            offer: "Fresh launch announcement",
            style: .electric,
            targetAudience: "local community",
            callToAction: "Share the launch"
        )
        return try await generateCampaign(from: request)
    }

    private func validate(_ request: CampaignRequest) throws {
        let hasPrompt = !request.campaignBrief.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !request.voiceTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !request.businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if !hasPrompt {
            throw AIServiceError.emptyPrompt
        }
    }

    private static func assets(for request: CampaignRequest, headline: String, cta: String) -> [CampaignPackAsset] {
        CampaignAssetType.allCases.map { type in
            CampaignPackAsset(
                type: type,
                title: type.rawValue,
                headline: headline,
                subtitle: request.offer.isEmpty ? "Premium promotional campaign" : request.offer,
                cta: cta,
                style: request.style,
                exportSizes: exportSizes(for: type)
            )
        }
    }

    private static func exportSizes(for type: CampaignAssetType) -> [String] {
        switch type {
        case .instagramPost: return ["1080x1080"]
        case .instagramStory: return ["1080x1920"]
        case .facebookBanner: return ["1640x624"]
        case .emailBanner: return ["1200x628"]
        case .poster: return ["24x36 in"]
        case .flyer: return ["A5", "US Letter"]
        default: return ["1080x1080", "1200x1500"]
        }
    }
}
