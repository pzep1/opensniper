#if os(macOS)
import AppKit

final class PreferencesStore {
    static let shared = PreferencesStore()

    private enum Keys {
        static let shortcut = "shortcut"
        static let joinLines = "joinLines"
        static let speakAfterCapture = "speakAfterCapture"
        static let recognitionLevel = "recognitionLevel"
        static let recognitionLanguages = "recognitionLanguages"
    }

    private let defaults = UserDefaults.standard

    private init() {
        defaults.register(defaults: [
            Keys.joinLines: true,
            Keys.speakAfterCapture: false,
            Keys.recognitionLevel: "accurate",
            Keys.recognitionLanguages: ""
        ])
    }

    var shortcut: KeyboardShortcut {
        get {
            guard let data = defaults.data(forKey: Keys.shortcut),
                  let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data)
            else {
                return .defaultShortcut
            }

            return shortcut
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.shortcut)
            }
        }
    }

    var joinLines: Bool {
        get { defaults.bool(forKey: Keys.joinLines) }
        set { defaults.set(newValue, forKey: Keys.joinLines) }
    }

    var speakAfterCapture: Bool {
        get { defaults.bool(forKey: Keys.speakAfterCapture) }
        set { defaults.set(newValue, forKey: Keys.speakAfterCapture) }
    }

    var recognitionLevel: String {
        get { defaults.string(forKey: Keys.recognitionLevel) ?? "accurate" }
        set { defaults.set(newValue, forKey: Keys.recognitionLevel) }
    }

    var recognitionLanguages: [String] {
        get {
            let rawValue = defaults.string(forKey: Keys.recognitionLanguages) ?? ""
            return rawValue
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            defaults.set(newValue.joined(separator: ", "), forKey: Keys.recognitionLanguages)
        }
    }

    var recognitionLanguagesText: String {
        get { defaults.string(forKey: Keys.recognitionLanguages) ?? "" }
        set { defaults.set(newValue, forKey: Keys.recognitionLanguages) }
    }
}
#endif
