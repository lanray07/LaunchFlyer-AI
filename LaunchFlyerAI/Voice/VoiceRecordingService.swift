import Combine
import Foundation

final class VoiceRecordingService: ObservableObject {
    @Published private(set) var elapsedSeconds: TimeInterval = 0
    @Published private(set) var isPaused = false

    private var timer: Timer?

    func start() {
        elapsedSeconds = 0
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, !self.isPaused else { return }
            self.elapsedSeconds += 1
        }
    }

    func pause() {
        isPaused = true
    }

    func resume() {
        isPaused = false
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isPaused = false
    }
}
