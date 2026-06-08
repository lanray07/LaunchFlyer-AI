import SwiftData
import SwiftUI

@main
struct LaunchFlyerAIApp: App {
    @StateObject private var services = AppServices.mock()

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Campaign.self,
            CampaignAsset.self,
            Template.self,
            BrandKit.self,
            VoiceTranscript.self,
            ExportRecord.self,
            SubscriptionState.self
        ])

        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false))
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(services)
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
        }
    }
}
