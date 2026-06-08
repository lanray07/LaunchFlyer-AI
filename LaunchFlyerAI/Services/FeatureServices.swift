import Foundation

final class CampaignGenerationService {
    private let provider: CampaignAIProvider

    init(provider: CampaignAIProvider) {
        self.provider = provider
    }

    func generate(_ request: CampaignRequest) async throws -> GeneratedCampaign {
        try await provider.generateCampaign(from: request)
    }
}

final class FlyerDesignService {
    private let provider: CampaignAIProvider

    init(provider: CampaignAIProvider) {
        self.provider = provider
    }

    func generateDesign(_ request: CampaignRequest) async throws -> FlyerDesignDocument {
        try await provider.generateFlyerDesign(from: request)
    }
}

final class SocialPackService {
    private let provider: CampaignAIProvider

    init(provider: CampaignAIProvider) {
        self.provider = provider
    }

    func generate(_ request: CampaignRequest) async throws -> [CampaignPackAsset] {
        try await provider.generateSocialPack(from: request)
    }
}

final class CopywritingService {
    private let provider: CampaignAIProvider

    init(provider: CampaignAIProvider) {
        self.provider = provider
    }

    func generate(_ request: CopywritingRequest) async throws -> [String] {
        try await provider.generateCopy(from: request)
    }
}

final class TemplateRecommendationService {
    private let provider: CampaignAIProvider

    init(provider: CampaignAIProvider) {
        self.provider = provider
    }

    func recommendations(for profile: UserProfile?, goal: MainGoal?) async -> [TemplateDescriptor] {
        await provider.recommendTemplates(for: profile, goal: goal)
    }
}

final class VoiceCampaignService {
    private let provider: CampaignAIProvider

    init(provider: CampaignAIProvider) {
        self.provider = provider
    }

    func generate(from transcript: String) async throws -> GeneratedCampaign {
        try await provider.generateFromVoice(transcript: transcript)
    }
}
