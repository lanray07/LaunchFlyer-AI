import SwiftUI

struct VoiceWaveformView: View {
    var samples: [CGFloat]
    var isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                Capsule()
                    .fill(
                        LinearGradient(colors: [.launchMint, .launchElectric], startPoint: .bottom, endPoint: .top)
                    )
                    .frame(width: 5, height: 18 + sample * 88)
                    .opacity(isActive ? 1 : 0.35)
            }
        }
        .frame(height: 124)
        .animation(.easeInOut(duration: 0.12), value: samples)
        .accessibilityLabel("Voice waveform")
    }
}
