import SwiftData
import SwiftUI

struct BrandKitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var brandKits: [BrandKit]
    @State private var brandName = ""
    @State private var colors = "#60F5C8,#7C5CFF,#FF3D81,#F8D66D"
    @State private var logoPlaceholder = "LaunchFlyer logo mark"
    @State private var fontsPlaceholder = "Display: New York Bold | Body: SF Pro"
    @State private var contactDetails = ""
    @State private var socialHandles = ""
    @State private var qrCodePlaceholder = "Website QR code"

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Brand Kit", title: "Apply everywhere")
                    BrandKitCard(brandName: brandName, colors: colorTokens, contactDetails: contactDetails)

                    GlassPanel {
                        VStack(spacing: 16) {
                            PremiumTextField("Brand name", text: $brandName)
                            PremiumTextField("Brand colors, comma separated hex", text: $colors)
                            PremiumTextField("Logo slot", text: $logoPlaceholder)
                            PremiumTextField("Font pairing", text: $fontsPlaceholder)
                            PremiumTextField("Contact details", text: $contactDetails)
                            PremiumTextField("Social handles", text: $socialHandles)
                            PremiumTextField("QR code label", text: $qrCodePlaceholder)
                            Button {
                                save()
                            } label: {
                                Label("Save Brand Kit", systemImage: "checkmark.seal.fill")
                            }
                            .buttonStyle(PremiumButtonStyle())
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Brand Kit")
        .onAppear(perform: load)
    }

    private var colorTokens: [String] {
        colors.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private func load() {
        guard let kit = brandKits.first else { return }
        brandName = kit.brandName
        colors = kit.colors
        logoPlaceholder = kit.logoPlaceholder
        fontsPlaceholder = kit.fontsPlaceholder
        contactDetails = kit.contactDetails
        socialHandles = kit.socialHandles
        qrCodePlaceholder = kit.qrCodePlaceholder
    }

    private func save() {
        let kit = brandKits.first ?? BrandKit(brandName: brandName, colors: colors)
        kit.brandName = brandName
        kit.colors = colors
        kit.logoPlaceholder = logoPlaceholder
        kit.fontsPlaceholder = fontsPlaceholder
        kit.contactDetails = contactDetails
        kit.socialHandles = socialHandles
        kit.qrCodePlaceholder = qrCodePlaceholder
        if brandKits.isEmpty {
            modelContext.insert(kit)
        }
        try? modelContext.save()
    }
}
