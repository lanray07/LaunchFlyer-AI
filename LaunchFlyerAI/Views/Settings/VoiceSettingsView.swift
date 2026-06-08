import SwiftUI

struct VoiceSettingsView: View {
    @AppStorage("launchflyer.voice.locale") private var locale = "en_US"
    @AppStorage("launchflyer.voice.liveTranscript") private var liveTranscript = true
    @AppStorage("launchflyer.voice.autoPause") private var autoPause = true
    @AppStorage("launchflyer.voice.saveTranscripts") private var saveTranscripts = true
    @AppStorage("launchflyer.voice.noiseReduction") private var noiseReduction = true
    @AppStorage("launchflyer.voice.haptics") private var haptics = true
    @AppStorage("launchflyer.voice.promptTemplate") private var promptTemplate = "Turn this spoken idea into a clear campaign brief, flyer copy, CTA, social captions, hashtags, and visual direction."

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader("Voice Settings", title: "Campaign dictation")
                    GlassPanel {
                        VStack(spacing: 16) {
                            Picker("Recognition language", selection: $locale) {
                                Text("English (US)").tag("en_US")
                                Text("English (UK)").tag("en_GB")
                                Text("Spanish").tag("es_ES")
                                Text("French").tag("fr_FR")
                            }
                            .pickerStyle(.menu)

                            PremiumToggleRow(title: "Live transcription", subtitle: "Show editable text while the user speaks.", isOn: $liveTranscript)
                            PremiumToggleRow(title: "Auto-pause on silence", subtitle: "Pause capture after long silence to keep briefs tidy.", isOn: $autoPause)
                            PremiumToggleRow(title: "Save transcripts", subtitle: "Store voice transcripts locally with generated campaign briefs.", isOn: $saveTranscripts)
                            PremiumToggleRow(title: "Noise reduction", subtitle: "Prefer clean speech input in busy local business environments.", isOn: $noiseReduction)
                            PremiumToggleRow(title: "Recording haptics", subtitle: "Use haptic feedback for record, pause, resume, and stop.", isOn: $haptics)
                            PremiumTextEditor(title: "Voice prompt template", placeholder: "Add voice-to-campaign instructions.", text: $promptTemplate, minHeight: 110)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Voice Settings")
    }
}
