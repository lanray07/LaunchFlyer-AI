import SwiftData
import SwiftUI

struct VoiceCampaignBuilderView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = VoiceCampaignViewModel()
    @StateObject private var recorder = VoiceRecordingService()
    @StateObject private var waveform = WaveformAnimationManager()
    @State private var editableTranscript = ""

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader("Voice Campaign Builder", title: "Say the idea")
                    recorderPanel
                    transcriptEditor
                    generateButton
                    if let error = services.speechRecognitionService.errorMessage ?? viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }
                    if let campaign = viewModel.generatedCampaign {
                        preview(campaign)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Voice")
        .onReceive(services.speechRecognitionService.$transcript) { value in
            if value != editableTranscript {
                editableTranscript = value
            }
        }
    }

    private var recorderPanel: some View {
        GlassPanel {
            VStack(spacing: 18) {
                VoiceWaveformView(samples: waveform.samples, isActive: services.speechRecognitionService.isRecording)
                HStack(spacing: 12) {
                    Button {
                        Task { @MainActor in
                            await startRecording()
                        }
                    } label: {
                        Label("Record", systemImage: "mic.fill")
                    }
                    .buttonStyle(PremiumButtonStyle())

                    Button {
                        pauseOrResume()
                    } label: {
                        Label(services.speechRecognitionService.isRecording ? "Pause" : "Resume", systemImage: services.speechRecognitionService.isRecording ? "pause.fill" : "play.fill")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button {
                        stopRecording()
                    } label: {
                        Image(systemName: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityLabel("Stop recording")
                }
            }
        }
    }

    private var transcriptEditor: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text("Live transcript")
                    .font(.headline)
                    .foregroundStyle(.white)
                TextEditor(text: $editableTranscript)
                    .frame(minHeight: 150)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onChange(of: editableTranscript) { _, newValue in
                        services.speechRecognitionService.replaceTranscript(with: newValue)
                    }
            }
        }
    }

    private var generateButton: some View {
        Button {
            Task { @MainActor in
                await viewModel.generate(from: editableTranscript, using: services)
                saveTranscript()
            }
        } label: {
            if viewModel.isGenerating {
                ProgressView().tint(.black)
            } else {
                Label("Create Campaign From Voice", systemImage: "wand.and.stars")
            }
        }
        .buttonStyle(PremiumButtonStyle())
        .disabled(viewModel.isGenerating)
    }

    private func preview(_ campaign: GeneratedCampaign) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI campaign preview")
                        .font(.headline)
                        .foregroundStyle(.launchMint)
                    Text(campaign.flyerCopy)
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            OneTapCampaignPackView(campaign: campaign)
        }
    }

    @MainActor
    private func startRecording() async {
        recorder.start()
        waveform.start()
        await services.speechRecognitionService.start()
    }

    @MainActor
    private func pauseOrResume() {
        if services.speechRecognitionService.isRecording {
            recorder.pause()
            services.speechRecognitionService.pause()
        } else {
            recorder.resume()
            services.speechRecognitionService.resume()
        }
    }

    @MainActor
    private func stopRecording() {
        recorder.stop()
        waveform.stop()
        services.speechRecognitionService.stop()
    }

    @MainActor
    private func saveTranscript() {
        guard let campaign = viewModel.generatedCampaign else { return }
        modelContext.insert(VoiceTranscript(transcript: editableTranscript, generatedBrief: campaign.flyerCopy))
        try? modelContext.save()
    }
}
