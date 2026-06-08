import Foundation

final class RemoteAIService: CampaignAIProvider {
    var endpoint = URL(string: "https://YOUR_BACKEND_URL.com/launchflyer-ai")

    func generateCampaign(from request: CampaignRequest) async throws -> GeneratedCampaign {
        guard let endpoint else { throw AIServiceError.invalidBackendURL }
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(RemoteCampaignPayload(request: request))

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(GeneratedCampaign.self, from: data)
    }

    func generateFlyerDesign(from request: CampaignRequest) async throws -> FlyerDesignDocument {
        let campaign = try await generateCampaign(from: request)
        return FlyerDesignDocument(
            headline: campaign.headlines.first ?? request.businessName,
            subtitle: "One idea. Complete campaign.",
            offer: request.offer,
            eventDetails: [request.dateTime, request.location].filter { !$0.isEmpty }.joined(separator: " • "),
            callToAction: request.callToAction,
            imagePlaceholder: "Remote design image",
            logoPlaceholder: request.businessName,
            qrCodePlaceholder: "QR",
            contactDetails: "Contact details",
            style: request.style,
            layout: .hero,
            spacing: 18
        )
    }

    func generateSocialPack(from request: CampaignRequest) async throws -> [CampaignPackAsset] {
        let campaign = try await generateCampaign(from: request)
        return campaign.assets
    }

    func generateCopy(from request: CopywritingRequest) async throws -> [String] {
        let campaignRequest = CampaignRequest(
            module: "copywriter",
            campaignType: .localCampaign,
            businessName: request.topic,
            campaignBrief: request.topic,
            voiceTranscript: "",
            dateTime: "",
            location: "",
            offer: request.format,
            style: .luxury,
            targetAudience: request.audience,
            callToAction: "Learn more"
        )
        let campaign = try await generateCampaign(from: campaignRequest)
        return campaign.socialCaptions
    }

    func recommendTemplates(for profile: UserProfile?, goal: MainGoal?) async -> [TemplateDescriptor] {
        TemplateCatalog.default.templates
    }

    func generateFromVoice(transcript: String) async throws -> GeneratedCampaign {
        let request = CampaignRequest(
            module: "voice-campaign",
            campaignType: .localCampaign,
            businessName: "Voice Campaign",
            campaignBrief: transcript,
            voiceTranscript: transcript,
            dateTime: "",
            location: "",
            offer: "",
            style: .electric,
            targetAudience: "",
            callToAction: ""
        )
        return try await generateCampaign(from: request)
    }
}

private struct RemoteCampaignPayload: Encodable {
    var module: String
    var campaignType: String
    var businessName: String
    var campaignBrief: String
    var voiceTranscript: String
    var style: String
    var targetAudience: String

    init(request: CampaignRequest) {
        module = request.module
        campaignType = request.campaignType.rawValue
        businessName = request.businessName
        campaignBrief = request.campaignBrief
        voiceTranscript = request.voiceTranscript
        style = request.style.rawValue
        targetAudience = request.targetAudience
    }
}
