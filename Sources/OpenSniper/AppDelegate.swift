#if os(macOS)
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusMenuController = StatusMenuController()
    private let hotKeyManager = HotKeyManager()
    private let captureCoordinator = CaptureCoordinator()
    private let preferences = PreferencesStore.shared
    private var preferencesWindowController: PreferencesWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusMenuController.delegate = self
        statusMenuController.configure()

        captureCoordinator.delegate = self
        registerConfiguredHotKey()
    }

    private func registerConfiguredHotKey() {
        do {
            try hotKeyManager.register(shortcut: preferences.shortcut) { [weak self] in
                self?.captureCoordinator.beginCapture(mode: .text)
            }
            statusMenuController.setShortcut(preferences.shortcut.displayString)
        } catch {
            statusMenuController.showMessage("Shortcut unavailable")
            presentError("Could not register the global shortcut: \(error.localizedDescription)")
        }
    }

    private func presentError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "OpenSniper"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

extension AppDelegate: StatusMenuControllerDelegate {
    func statusMenuDidRequestTextCapture(_ controller: StatusMenuController) {
        captureCoordinator.beginCapture(mode: .text)
    }

    func statusMenuDidRequestBarcodeCapture(_ controller: StatusMenuController) {
        captureCoordinator.beginCapture(mode: .barcode)
    }

    func statusMenuDidRequestCopyLastCapture(_ controller: StatusMenuController) {
        guard let text = captureCoordinator.lastCapturedText, !text.isEmpty else {
            NSSound.beep()
            return
        }

        ClipboardWriter.copy(text)
        statusMenuController.showMessage("Copied")
    }

    func statusMenuDidRequestSpeech(_ controller: StatusMenuController) {
        guard let text = captureCoordinator.lastCapturedText, !text.isEmpty else {
            NSSound.beep()
            return
        }

        SpeechReader.shared.speak(text)
    }

    func statusMenuDidRequestPreferences(_ controller: StatusMenuController) {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
            preferencesWindowController?.delegate = self
        }

        preferencesWindowController?.showWindow(nil)
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func statusMenuDidRequestScreenRecordingSettings(_ controller: StatusMenuController) {
        ScreenCapturePermission.openSettings()
    }

    func statusMenuDidRequestQuit(_ controller: StatusMenuController) {
        NSApp.terminate(nil)
    }
}

extension AppDelegate: CaptureCoordinatorDelegate {
    func captureCoordinator(_ coordinator: CaptureCoordinator, didCopy text: String, mode: CaptureMode) {
        statusMenuController.setLastCapture(text)
        statusMenuController.showMessage(mode == .barcode ? "Code copied" : "Text copied")

        if preferences.speakAfterCapture, mode == .text {
            SpeechReader.shared.speak(text)
        }
    }

    func captureCoordinator(_ coordinator: CaptureCoordinator, didFailWith message: String) {
        statusMenuController.showMessage("Capture failed")
        presentError(message)
    }

    func captureCoordinatorDidCancel(_ coordinator: CaptureCoordinator) {
        statusMenuController.showMessage("Canceled")
    }
}

extension AppDelegate: PreferencesWindowControllerDelegate {
    func preferencesWindowControllerDidChangePreferences(_ controller: PreferencesWindowController) {
        registerConfiguredHotKey()
    }
}
#endif
