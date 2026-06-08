import SwiftUI

struct ExportSettingsView: View {
    @AppStorage("launchflyer.export.defaultFormat") private var defaultFormat = ExportFormat.png.rawValue
    @AppStorage("launchflyer.export.defaultSize") private var defaultSize = "1080x1350"
    @AppStorage("launchflyer.export.includeBrandKit") private var includeBrandKit = true
    @AppStorage("launchflyer.export.includeWatermark") private var includeWatermark = true
    @AppStorage("launchflyer.export.optimizeForPrint") private var optimizeForPrint = true
    @AppStorage("launchflyer.export.batchNaming") private var batchNaming = "CampaignName_AssetType_Date"
    @AppStorage("launchflyer.export.destinationFolder") private var destinationFolder = "LaunchFlyer Exports"

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader("Export Settings", title: "Output defaults")
                    GlassPanel {
                        VStack(spacing: 16) {
                            Picker("Default format", selection: $defaultFormat) {
                                ForEach(ExportFormat.allCases) { format in
                                    Text(format.rawValue).tag(format.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)

                            PremiumTextField("Default size", text: $defaultSize)
                            PremiumTextField("Batch file naming", text: $batchNaming)
                            PremiumTextField("Destination folder", text: $destinationFolder)
                            PremiumToggleRow(title: "Apply brand kit", subtitle: "Automatically include saved colors, logo, contact details, and QR code.", isOn: $includeBrandKit)
                            PremiumToggleRow(title: "Include free-plan watermark", subtitle: "Keep watermark visible until a premium entitlement removes it.", isOn: $includeWatermark)
                            PremiumToggleRow(title: "Optimize PDF for print", subtitle: "Use the print-ready PDF render path for flyer and poster exports.", isOn: $optimizeForPrint)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Export Settings")
    }
}
