import Combine
import Foundation

final class VoiceCampaignViewModel: ObservableObject {
    @Published var generatedCampaign: GeneratedCampaign?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    @MainActor
    func generate(from transcript: String, using services: AppServices) async {
        isGenerating = true
        errorMessage = nil
        generatedCampaign = nil
        do {
            generatedCampaign = try await services.voiceCampaignService.generate(from: transcript)
        } catch {
            errorMessage = error.localizedDescription
        }
        isGenerating = false
    }
}
