import SwiftData
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @Query private var campaigns: [Campaign]
    @Query private var assets: [CampaignAsset]
    @Query private var exports: [ExportRecord]
    @Query private var brandKits: [BrandKit]
    @State private var showingPaywall = false
    @State private var confirmDelete = false

    var body: some View {
        ZStack {
            PremiumBackground()
            List {
                Section {
                    SettingsRow(title: "Manage subscription", icon: "creditcard.fill") {
                        showingPaywall = true
                    }
                    NavigationLink {
                        ExportCenterView()
                    } label: {
                        Label("Export settings", systemImage: "square.and.arrow.up")
                    }
                    NavigationLink {
                        BrandKitView()
                    } label: {
                        Label("Brand settings", systemImage: "paintpalette.fill")
                    }
                    SettingsRow(title: "Voice settings", icon: "waveform") {}
                    SettingsRow(title: "Design preferences", icon: "slider.horizontal.3") {}
                }

                Section {
                    SettingsRow(title: "Privacy policy", icon: "lock.shield.fill") {}
                    SettingsRow(title: "Terms of use", icon: "doc.text.fill") {}
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Delete all projects", systemImage: "trash.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .confirmationDialog("Delete all local projects?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete all projects", role: .destructive) {
                deleteAll()
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            await services.subscriptionService.loadProducts()
        }
    }

    private func deleteAll() {
        campaigns.forEach { modelContext.delete($0) }
        assets.forEach { modelContext.delete($0) }
        exports.forEach { modelContext.delete($0) }
        brandKits.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}

private struct SettingsRow: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
    }
}
