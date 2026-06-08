import Combine
import Foundation

final class CopywriterViewModel: ObservableObject {
    @Published var topic = ""
    @Published var audience = ""
    @Published var tone: CopyTone = .bold
    @Published var format = "Flyer headlines"
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
