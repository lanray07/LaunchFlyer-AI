import Combine
import Foundation

final class CampaignPromptViewModel: ObservableObject {
    @Published var campaignType: CampaignType = .event
    @Published var businessName = ""
    @Published var dateTime = ""
    @Published var location = ""
    @Published var offer = ""
    @Published var targetAudience = ""
    @Published var visualStyle: VisualStyle = .electric
    @Published var callToAction = ""
    @Published var brief = ""
    @Published var generatedCampaign: GeneratedCampaign?
    @Published var flyerDesign: FlyerDesignDocument?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var request: CampaignRequest {
        CampaignRequest(
            module: "campaign-prompt",
            campaignType: campaignType,
            businessName: businessName,
            campaignBrief: brief,
            voiceTranscript: "",
            dateTime: dateTime,
            location: location,
            offer: offer,
            style: visualStyle,
            targetAudience: targetAudience,
            callToAction: callToAction
        )
    }

    @MainActor
    func generate(using services: AppServices) async {
        isLoading = true
        errorMessage = nil
        generatedCampaign = nil
        flyerDesign = nil
        do {
            async let campaign = services.campaignGenerationService.generate(request)
            async let design = services.flyerDesignService.generateDesign(request)
            generatedCampaign = try await campaign
            flyerDesign = try await design
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
