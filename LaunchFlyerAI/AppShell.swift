import SwiftData
import SwiftUI

struct AppRootView: View {
    @AppStorage("launchflyer.hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .background(PremiumBackground())
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tag(AppTab.dashboard)
            .tabItem { Label("Home", systemImage: "sparkles") }

            NavigationStack {
                CampaignPromptView()
            }
            .tag(AppTab.create)
            .tabItem { Label("Create", systemImage: "wand.and.stars") }

            NavigationStack {
                VoiceCampaignBuilderView()
            }
            .tag(AppTab.voice)
            .tabItem { Label("Voice", systemImage: "waveform") }

            NavigationStack {
                TemplateGalleryView()
            }
            .tag(AppTab.templates)
            .tabItem { Label("Templates", systemImage: "rectangle.stack.fill") }

            NavigationStack {
                CampaignLibraryView()
            }
            .tag(AppTab.library)
            .tabItem { Label("Library", systemImage: "folder.fill") }
        }
        .tint(.launchMint)
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case create
    case voice
    case templates
    case library

    var id: String { rawValue }
}
