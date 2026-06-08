import AVFoundation
import Combine
import Foundation
import Speech

final class SpeechRecognitionService: NSObject, ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isRecording = false
    @Published private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.authorizationStatus = status
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    func start() async {
        guard await requestAuthorization() else {
            errorMessage = "Speech recognition permission is required."
            return
        }

        do {
            try startRecording()
        } catch {
            errorMessage = error.localizedDescription
            stop()
        }
    }

    func pause() {
        audioEngine.pause()
        isRecording = false
    }

    func resume() {
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }

    func replaceTranscript(with value: String) {
        transcript = value
    }

    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if let error {
                    self?.errorMessage = error.localizedDescription
                    self?.stop()
                }
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
}
