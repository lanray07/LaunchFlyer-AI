import Foundation
import SwiftUI

final class AppServices: ObservableObject {
    let campaignGenerationService: CampaignGenerationService
    let flyerDesignService: FlyerDesignService
    let socialPackService: SocialPackService
    let copywritingService: CopywritingService
    let templateRecommendationService: TemplateRecommendationService
    let voiceCampaignService: VoiceCampaignService
    let subscriptionService: SubscriptionService
    let templateCatalog: TemplateCatalog
    let exportPipeline: ExportPipeline
    let speechRecognitionService: SpeechRecognitionService

    init(provider: CampaignAIProvider, mockAIEnabled: Bool) {
        campaignGenerationService = CampaignGenerationService(provider: provider)
        flyerDesignService = FlyerDesignService(provider: provider)
        socialPackService = SocialPackService(provider: provider)
        copywritingService = CopywritingService(provider: provider)
        templateRecommendationService = TemplateRecommendationService(provider: provider)
        voiceCampaignService = VoiceCampaignService(provider: provider)
        subscriptionService = SubscriptionService()
        templateCatalog = .default
        exportPipeline = ExportPipeline()
        speechRecognitionService = SpeechRecognitionService()
        MockAIConfiguration.isEnabled = mockAIEnabled
    }

    static func mock() -> AppServices {
        AppServices(provider: MockAIService(), mockAIEnabled: true)
    }

    static func remote() -> AppServices {
        AppServices(provider: RemoteAIService(), mockAIEnabled: false)
    }
}

enum MockAIConfiguration {
    static var isEnabled = true
}
