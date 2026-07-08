#if os(macOS)
import AppKit

protocol PreferencesWindowControllerDelegate: AnyObject {
    func preferencesWindowControllerDidChangePreferences(_ controller: PreferencesWindowController)
}

final class PreferencesWindowController: NSWindowController, NSTextFieldDelegate, NSWindowDelegate {
    weak var delegate: PreferencesWindowControllerDelegate?

    private let preferences = PreferencesStore.shared
    private let shortcutButton = NSButton(title: "", target: nil, action: nil)
    private let joinLinesButton = NSButton(checkboxWithTitle: "Join recognized lines into paragraphs", target: nil, action: nil)
    private let speakAfterCaptureButton = NSButton(checkboxWithTitle: "Speak text after capture", target: nil, action: nil)
    private let recognitionLevelPopup = NSPopUpButton()
    private let languagesField = NSTextField()
    private var recordingMonitor: Any?
    private var isRecordingShortcut = false

    convenience init() {
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 270),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "OpenSniper Preferences"
        window.center()
        self.init(window: window)
        window.delegate = self
        buildInterface()
        refresh()
    }

    deinit {
        stopRecordingShortcut()
    }

    private func buildInterface() {
        guard let contentView = window?.contentView else {
            return
        }

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22)
        ])

        stackView.addArrangedSubview(row(label: "Shortcut", control: shortcutButton))

        shortcutButton.target = self
        shortcutButton.action = #selector(recordShortcut)

        joinLinesButton.target = self
        joinLinesButton.action = #selector(toggleJoinLines)
        stackView.addArrangedSubview(joinLinesButton)

        speakAfterCaptureButton.target = self
        speakAfterCaptureButton.action = #selector(toggleSpeakAfterCapture)
        stackView.addArrangedSubview(speakAfterCaptureButton)

        recognitionLevelPopup.addItems(withTitles: ["Accurate", "Fast"])
        recognitionLevelPopup.target = self
        recognitionLevelPopup.action = #selector(changeRecognitionLevel)
        stackView.addArrangedSubview(row(label: "OCR mode", control: recognitionLevelPopup))

        languagesField.placeholderString = "Optional, for example: en-US, fr-FR"
        languagesField.delegate = self
        languagesField.target = self
        languagesField.action = #selector(changeLanguages)
        stackView.addArrangedSubview(row(label: "Languages", control: languagesField))

        let settingsButton = NSButton(title: "Open Screen Recording Settings", target: self, action: #selector(openScreenRecordingSettings))
        stackView.addArrangedSubview(settingsButton)
    }

    private func row(label: String, control: NSView) -> NSStackView {
        let labelView = NSTextField(labelWithString: label)
        labelView.widthAnchor.constraint(equalToConstant: 96).isActive = true

        if let control = control as? NSControl {
            control.controlSize = .regular
        }

        let row = NSStackView(views: [labelView, control])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 12

        control.translatesAutoresizingMaskIntoConstraints = false
        control.widthAnchor.constraint(greaterThanOrEqualToConstant: 230).isActive = true

        return row
    }

    private func refresh() {
        shortcutButton.title = isRecordingShortcut ? "Press shortcut..." : preferences.shortcut.displayString
        joinLinesButton.state = preferences.joinLines ? .on : .off
        speakAfterCaptureButton.state = preferences.speakAfterCapture ? .on : .off
        recognitionLevelPopup.selectItem(withTitle: preferences.recognitionLevel == "fast" ? "Fast" : "Accurate")
        languagesField.stringValue = preferences.recognitionLanguagesText
    }

    @objc private func recordShortcut() {
        guard !isRecordingShortcut else {
            stopRecordingShortcut()
            refresh()
            return
        }

        isRecordingShortcut = true
        refresh()

        recordingMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.captureShortcut(from: event)
            return nil
        }
    }

    private func captureShortcut(from event: NSEvent) {
        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])

        guard !modifiers.isEmpty else {
            NSSound.beep()
            return
        }

        preferences.shortcut = KeyboardShortcut(keyCode: UInt32(event.keyCode), modifiers: modifiers)
        stopRecordingShortcut()
        refresh()
        delegate?.preferencesWindowControllerDidChangePreferences(self)
    }

    private func stopRecordingShortcut() {
        if let recordingMonitor {
            NSEvent.removeMonitor(recordingMonitor)
            self.recordingMonitor = nil
        }
        isRecordingShortcut = false
    }

    @objc private func toggleJoinLines() {
        preferences.joinLines = joinLinesButton.state == .on
    }

    @objc private func toggleSpeakAfterCapture() {
        preferences.speakAfterCapture = speakAfterCaptureButton.state == .on
    }

    @objc private func changeRecognitionLevel() {
        preferences.recognitionLevel = recognitionLevelPopup.titleOfSelectedItem == "Fast" ? "fast" : "accurate"
    }

    @objc private func changeLanguages() {
        preferences.recognitionLanguagesText = languagesField.stringValue
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        changeLanguages()
    }

    func windowWillClose(_ notification: Notification) {
        stopRecordingShortcut()
        refresh()
    }

    @objc private func openScreenRecordingSettings() {
        ScreenCapturePermission.openSettings()
    }
}
#endif
