import SwiftUI

struct BrandKitCard: View {
    var brandName: String
    var colors: [String]
    var contactDetails: String

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(brandName.isEmpty ? "Starter Brand Kit" : brandName)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text(contactDetails.isEmpty ? "Logo, colors, fonts, handles" : contactDetails)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    Spacer()
                    Image(systemName: "seal.fill")
                        .foregroundStyle(.launchMint)
                }

                HStack(spacing: 10) {
                    ForEach(colors.prefix(6), id: \.self) { token in
                        Circle()
                            .fill(Color(hex: token))
                            .frame(width: 34, height: 34)
                            .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
    }
}
