import SwiftUI

struct ExportCard: View {
    var title: String
    var format: ExportFormat
    var size: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.launchMint)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundStyle(.white)
                        .font(.headline)
                    Text("\(format.rawValue) • \(size)")
                        .foregroundStyle(.white.opacity(0.58))
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }

    private var icon: String {
        switch format {
        case .png: return "photo"
        case .jpg: return "photo.fill"
        case .pdf: return "doc.richtext"
        }
    }
}
