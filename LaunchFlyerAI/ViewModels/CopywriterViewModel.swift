import Combine
import Foundation

final class CopywriterViewModel: ObservableObject {
    @Published var topic = "Grand opening weekend for Glow & Grind Coffee"
    @Published var audience = "Local professionals, students, creators, and weekend brunch customers"
    @Published var tone: CopyTone = .bold
    @Published var format = "Flyer headlines, CTAs, social captions, hashtags, SMS copy, and email subject lines"
    @Published var results: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @MainActor
    func generate(using services: AppServices) async {
        isLoading = true
        errorMessage = nil
        do {
            results = try await services.copywritingService.generate(
                CopywritingRequest(topic: topic, audience: audience, tone: tone, format: format)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
