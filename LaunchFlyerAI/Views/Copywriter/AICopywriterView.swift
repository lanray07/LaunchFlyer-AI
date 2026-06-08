import SwiftUI

struct AICopywriterView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = CopywriterViewModel()

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Copywriter", title: "Campaign words")
                    GlassPanel {
                        VStack(spacing: 16) {
                            PremiumTextField("Topic or offer", text: $viewModel.topic)
                            PremiumTextField("Audience", text: $viewModel.audience)
                            PremiumTextField("Format", text: $viewModel.format)
                            Picker("Tone", selection: $viewModel.tone) {
                                ForEach(CopyTone.allCases) { tone in
                                    Text(tone.rawValue).tag(tone)
                                }
                            }
                            .pickerStyle(.segmented)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(["Flyer headlines", "CTAs", "Social captions", "Hashtags", "SMS copy", "Email subjects"], id: \.self) { format in
                                        FormChip(title: format, icon: "text.quote") {
                                            viewModel.format = format
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        Task { await viewModel.generate(using: services) }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.black)
                        } else {
                            Label("Generate Copy", systemImage: "text.quote")
                        }
                    }
                    .buttonStyle(PremiumButtonStyle())

                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }

                    ForEach(viewModel.results, id: \.self) { result in
                        GlassPanel(cornerRadius: 18) {
                            Text(result)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Copywriter")
    }
}
