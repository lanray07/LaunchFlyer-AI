import Foundation

struct CampaignRequest: Codable, Equatable {
    var module: String
    var campaignType: CampaignType
    var businessName: String
    var campaignBrief: String
    var voiceTranscript: String
    var dateTime: String
    var location: String
    var offer: String
    var style: VisualStyle
    var targetAudience: String
    var callToAction: String
}

struct GeneratedCampaign: Codable, Equatable {
    var campaignConcept: String
    var headlines: [String]
    var flyerCopy: String
    var socialCaptions: [String]
    var hashtags: [String]
    var designSuggestions: [String]
    var assets: [CampaignPackAsset]
}

struct CopywritingRequest: Codable, Equatable {
    var topic: String
    var audience: String
    var tone: CopyTone
    var format: String
}

protocol CampaignAIProvider {
    func generateCampaign(from request: CampaignRequest) async throws -> GeneratedCampaign
    func generateFlyerDesign(from request: CampaignRequest) async throws -> FlyerDesignDocument
    func generateSocialPack(from request: CampaignRequest) async throws -> [CampaignPackAsset]
    func generateCopy(from request: CopywritingRequest) async throws -> [String]
    func recommendTemplates(for profile: UserProfile?, goal: MainGoal?) async -> [TemplateDescriptor]
    func generateFromVoice(transcript: String) async throws -> GeneratedCampaign
}

enum AIServiceError: LocalizedError {
    case invalidBackendURL
    case emptyPrompt

    var errorDescription: String? {
        switch self {
        case .invalidBackendURL:
            return "The remote backend URL is not configured."
        case .emptyPrompt:
            return "Add a campaign idea before generating."
        }
    }
}
