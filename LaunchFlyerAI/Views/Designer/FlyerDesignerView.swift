import SwiftUI

struct FlyerDesignerView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel: FlyerDesignerViewModel

    init(document: FlyerDesignDocument = .sample) {
        _viewModel = StateObject(wrappedValue: FlyerDesignerViewModel(document: document))
    }

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Designer", title: "Flyer Studio")
                    FlyerCanvasView(document: viewModel.document)
                        .frame(height: 520)
                    editingTools
                }
                .padding()
            }
        }
        .navigationTitle("Flyer")
    }

    private var editingTools: some View {
        GlassPanel {
            VStack(spacing: 15) {
                PremiumTextField("Headline", text: $viewModel.document.headline)
                PremiumTextField("Subtitle", text: $viewModel.document.subtitle)
                PremiumTextField("Offer", text: $viewModel.document.offer)
                PremiumTextField("Event details", text: $viewModel.document.eventDetails)
                PremiumTextField("CTA", text: $viewModel.document.callToAction)
                PremiumTextField("Image slot", text: $viewModel.document.imagePlaceholder)
                PremiumTextField("Logo slot", text: $viewModel.document.logoPlaceholder)
                PremiumTextField("QR code label", text: $viewModel.document.qrCodePlaceholder)
                PremiumTextField("Contact details", text: $viewModel.document.contactDetails)

                Picker("Layout", selection: $viewModel.document.layout) {
                    ForEach(FlyerLayout.allCases) { layout in
                        Text(layout.rawValue).tag(layout)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Colour style", selection: $viewModel.document.style) {
                    ForEach(VisualStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.menu)

                VStack(alignment: .leading) {
                    Text("Spacing")
                        .foregroundStyle(.white.opacity(0.7))
                    Slider(value: $viewModel.document.spacing, in: 8...34)
                        .tint(.launchMint)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(services.templateCatalog.templates.prefix(6)) { template in
                            Button {
                                viewModel.apply(template: template)
                            } label: {
                                Text(template.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 9)
                                    .background(.white.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FlyerCanvasView: View {
    var document: FlyerDesignDocument

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: document.style.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    GeometryReader { proxy in
                        Circle()
                            .fill(.white.opacity(0.16))
                            .frame(width: proxy.size.width * 0.7)
                            .blur(radius: 18)
                            .offset(x: proxy.size.width * 0.42, y: -proxy.size.height * 0.18)
                    }
                }

            VStack(alignment: .leading, spacing: document.spacing) {
                HStack {
                    Text(document.logoPlaceholder)
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.32), in: Capsule())
                    Spacer()
                    Text(document.qrCodePlaceholder)
                        .font(.caption.bold())
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.black)
                }

                Spacer()

                Text(document.headline)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .lineLimit(3)
                    .minimumScaleFactor(0.58)
                    .foregroundStyle(.white)

                Text(document.subtitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))

                Text(document.offer)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.launchGold, in: Capsule())

                Text(document.eventDetails)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))

                HStack {
                    Text(document.callToAction)
                        .font(.headline.bold())
                    Spacer()
                    Text(document.contactDetails)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
                .foregroundStyle(.white)
            }
            .padding(26)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.34), radius: 34, x: 0, y: 24)
    }
}
