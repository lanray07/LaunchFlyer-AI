import Foundation
import SwiftUI

final class WaveformAnimationManager: ObservableObject {
    @Published var samples: [CGFloat] = Array(repeating: 0.25, count: 32)

    private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            self?.samples = (0..<32).map { index in
                let wave = sin(Double(index) * 0.42 + Date().timeIntervalSince1970 * 4)
                return CGFloat(max(0.16, min(1.0, 0.45 + wave * 0.35 + Double.random(in: -0.08...0.08))))
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        samples = Array(repeating: 0.25, count: 32)
    }
}
