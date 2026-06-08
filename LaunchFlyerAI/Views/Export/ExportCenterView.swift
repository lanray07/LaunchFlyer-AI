import SwiftData
import SwiftUI

struct ExportCenterView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Campaign.createdAt, order: .reverse) private var campaigns: [Campaign]
    @Query(sort: \ExportRecord.createdAt, order: .reverse) private var exports: [ExportRecord]
    @State private var shareURL: URL?
    @State private var showingShareSheet = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Export Center", title: "Ship the pack")
                    exportOptions
                    exportHistory
                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Export")
        .sheet(isPresented: $showingShareSheet) {
            if let shareURL {
                ShareSheet(items: [shareURL])
            }
        }
    }

    private var exportOptions: some View {
        GlassPanel {
            VStack(spacing: 14) {
                ExportCard(title: "Instagram / social asset", format: .png, size: "1080x1350") {
                    export(format: .png, size: CGSize(width: 1080, height: 1350))
                }
                ExportCard(title: "Print-ready PDF", format: .pdf, size: "US Letter") {
                    export(format: .pdf, size: CGSize(width: 612, height: 792))
                }
                ExportCard(title: "Compressed web image", format: .jpg, size: "1200x628") {
                    export(format: .jpg, size: CGSize(width: 1200, height: 628))
                }
            }
        }
    }

    private var exportHistory: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("History", title: "Recent exports")
            if exports.isEmpty {
                EmptyStateView(title: "No exports yet", subtitle: "Exported files will appear here with format and size.", icon: "square.and.arrow.up")
            } else {
                ForEach(exports.prefix(8)) { record in
                    GlassPanel(cornerRadius: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(record.format)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(record.size)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            Spacer()
                            Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
    }

    private func export(format: ExportFormat, size: CGSize) {
        Task { @MainActor in
            do {
                let url = try services.exportPipeline.exportImage(
                    view: FlyerCanvasView(document: .sample),
                    format: format,
                    size: size
                )
                let campaignId = campaigns.first?.id ?? UUID()
                modelContext.insert(ExportRecord(campaignId: campaignId, format: format.rawValue, size: "\(Int(size.width))x\(Int(size.height))"))
                try? modelContext.save()
                shareURL = url
                showingShareSheet = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
