import SwiftUI

struct DesignPreferencesView: View {
    @AppStorage("launchflyer.design.defaultStyle") private var defaultStyle = VisualStyle.electric.rawValue
    @AppStorage("launchflyer.design.defaultLayout") private var defaultLayout = FlyerLayout.hero.rawValue
    @AppStorage("launchflyer.design.applyBrandKit") private var applyBrandKit = true
    @AppStorage("launchflyer.design.premiumShadows") private var premiumShadows = true
    @AppStorage("launchflyer.design.safeAreaGuides") private var safeAreaGuides = true
    @AppStorage("launchflyer.design.highContrastPreview") private var highContrastPreview = false
    @AppStorage("launchflyer.design.defaultCTA") private var defaultCTA = "Book now"

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader("Design Preferences", title: "Creative defaults")
                    GlassPanel {
                        VStack(spacing: 16) {
                            Picker("Default visual style", selection: $defaultStyle) {
                                ForEach(VisualStyle.allCases) { style in
                                    Text(style.rawValue).tag(style.rawValue)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Default flyer layout", selection: $defaultLayout) {
                                ForEach(FlyerLayout.allCases) { layout in
                                    Text(layout.rawValue).tag(layout.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)

                            PremiumTextField("Default CTA", text: $defaultCTA)
                            PremiumToggleRow(title: "Auto-apply brand kit", subtitle: "Use saved colors, fonts, logo, and contact details on new campaigns.", isOn: $applyBrandKit)
                            PremiumToggleRow(title: "Premium shadows", subtitle: "Use deeper Apple-quality depth and glass styling in previews.", isOn: $premiumShadows)
                            PremiumToggleRow(title: "Show safe-area guides", subtitle: "Keep critical text clear for story, feed, and print crops.", isOn: $safeAreaGuides)
                            PremiumToggleRow(title: "High-contrast previews", subtitle: "Boost preview contrast for quick accessibility checks.", isOn: $highContrastPreview)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Design")
    }
}
