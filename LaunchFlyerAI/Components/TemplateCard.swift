import SwiftUI

struct TemplateCard: View {
    var template: TemplateDescriptor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: template.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 156)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(template.title)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Text(template.category)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .padding()
                    }

                if template.premium {
                    Label("Pro", systemImage: "crown.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.launchGold, in: Capsule())
                        .padding(10)
                }
            }
        }
    }
}
