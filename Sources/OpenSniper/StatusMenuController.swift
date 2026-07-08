#if os(macOS)
import AppKit

protocol StatusMenuControllerDelegate: AnyObject {
    func statusMenuDidRequestTextCapture(_ controller: StatusMenuController)
    func statusMenuDidRequestBarcodeCapture(_ controller: StatusMenuController)
    func statusMenuDidRequestCopyLastCapture(_ controller: StatusMenuController)
    func statusMenuDidRequestSpeech(_ controller: StatusMenuController)
    func statusMenuDidRequestPreferences(_ controller: StatusMenuController)
    func statusMenuDidRequestScreenRecordingSettings(_ controller: StatusMenuController)
    func statusMenuDidRequestQuit(_ controller: StatusMenuController)
}

final class StatusMenuController: NSObject {
    weak var delegate: StatusMenuControllerDelegate?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let captureTextItem = NSMenuItem()
    private let copyLastItem = NSMenuItem()
    private let speakItem = NSMenuItem()
    private var restoreStatusWorkItem: DispatchWorkItem?

    func configure() {
        if let button = statusItem.button {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "viewfinder", accessibilityDescription: "OpenSniper")
            } else {
                button.title = "OS"
            }
            button.toolTip = "OpenSniper"
        }

        captureTextItem.title = "Capture Text"
        captureTextItem.target = self
        captureTextItem.action = #selector(captureText)
        menu.addItem(captureTextItem)

        let barcodeItem = NSMenuItem(title: "Capture QR or Barcode", action: #selector(captureBarcode), keyEquivalent: "")
        barcodeItem.target = self
        menu.addItem(barcodeItem)

        menu.addItem(.separator())

        copyLastItem.title = "Copy Last Capture"
        copyLastItem.target = self
        copyLastItem.action = #selector(copyLastCapture)
        copyLastItem.isEnabled = false
        menu.addItem(copyLastItem)

        speakItem.title = "Speak Last Capture"
        speakItem.target = self
        speakItem.action = #selector(speakLastCapture)
        speakItem.isEnabled = false
        menu.addItem(speakItem)

        menu.addItem(.separator())

        let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        let settingsItem = NSMenuItem(title: "Open Screen Recording Settings", action: #selector(openScreenRecordingSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit OpenSniper", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func setShortcut(_ shortcut: String) {
        captureTextItem.title = shortcut.isEmpty ? "Capture Text" : "Capture Text (\(shortcut))"
    }

    func setLastCapture(_ text: String) {
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        copyLastItem.isEnabled = hasText
        speakItem.isEnabled = hasText
    }

    func showMessage(_ message: String) {
        restoreStatusWorkItem?.cancel()

        guard let button = statusItem.button else {
            return
        }

        let originalTitle = button.title
        let originalImage = button.image
        button.image = nil
        button.title = message

        let workItem = DispatchWorkItem { [weak button] in
            button?.title = originalTitle
            button?.image = originalImage
        }
        restoreStatusWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: workItem)
    }

    @objc private func captureText() {
        delegate?.statusMenuDidRequestTextCapture(self)
    }

    @objc private func captureBarcode() {
        delegate?.statusMenuDidRequestBarcodeCapture(self)
    }

    @objc private func copyLastCapture() {
        delegate?.statusMenuDidRequestCopyLastCapture(self)
    }

    @objc private func speakLastCapture() {
        delegate?.statusMenuDidRequestSpeech(self)
    }

    @objc private func openPreferences() {
        delegate?.statusMenuDidRequestPreferences(self)
    }

    @objc private func openScreenRecordingSettings() {
        delegate?.statusMenuDidRequestScreenRecordingSettings(self)
    }

    @objc private func quit() {
        delegate?.statusMenuDidRequestQuit(self)
    }
}
#endif
