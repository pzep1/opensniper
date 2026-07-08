#if os(macOS)
import AppKit

final class SpeechReader: NSObject, NSSpeechSynthesizerDelegate {
    static let shared = SpeechReader()

    private let synthesizer = NSSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking()
        }

        synthesizer.startSpeaking(text)
    }
}
#endif
