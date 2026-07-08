#if os(macOS)
import AppKit
import OpenSniperCore

protocol CaptureCoordinatorDelegate: AnyObject {
    func captureCoordinator(_ coordinator: CaptureCoordinator, didCopy text: String, mode: CaptureMode)
    func captureCoordinator(_ coordinator: CaptureCoordinator, didFailWith message: String)
    func captureCoordinatorDidCancel(_ coordinator: CaptureCoordinator)
}

final class CaptureCoordinator {
    weak var delegate: CaptureCoordinatorDelegate?

    private let overlayController = SelectionOverlayController()
    private let recognitionService = RecognitionService()
    private var permissionPolicy = ScreenCapturePermissionRequestPolicy()
    private var isCapturing = false

    private(set) var lastCapturedText: String?

    func beginCapture(mode: CaptureMode) {
        guard !isCapturing else {
            return
        }

        switch permissionPolicy.action(hasScreenCaptureAccess: ScreenCapturePermission.hasAccess()) {
        case .capture:
            break
        case .requestPermission:
            guard ScreenCapturePermission.requestAccess() else {
                delegate?.captureCoordinator(
                    self,
                    didFailWith: "OpenSniper needs Screen Recording permission before it can read pixels from the selected area. Enable it in System Settings, then quit and reopen the same OpenSniper app."
                )
                ScreenCapturePermission.openSettings()
                return
            }
        case .waitForRelaunch:
            delegate?.captureCoordinator(
                self,
                didFailWith: "OpenSniper still cannot read the screen. If Screen Recording is already enabled, quit and reopen the same OpenSniper app. If you switch between TestFlight and a local build, macOS treats them as different apps."
            )
            return
        }

        isCapturing = true
        overlayController.begin { [weak self] selection in
            guard let self else {
                return
            }

            guard let selection else {
                self.isCapturing = false
                self.delegate?.captureCoordinatorDidCancel(self)
                return
            }

            self.process(selection: selection, mode: mode)
        }
    }

    private func process(selection: ScreenSelection, mode: CaptureMode) {
        guard let image = selection.captureImage() else {
            isCapturing = false
            delegate?.captureCoordinator(self, didFailWith: "The selected screen area could not be captured.")
            return
        }

        recognitionService.recognize(mode: mode, image: image) { [weak self] result in
            guard let self else {
                return
            }

            self.isCapturing = false

            switch result {
            case .success(let text):
                self.lastCapturedText = text
                ClipboardWriter.copy(text)
                self.delegate?.captureCoordinator(self, didCopy: text, mode: mode)
            case .failure(let error):
                self.delegate?.captureCoordinator(self, didFailWith: error.localizedDescription)
            }
        }
    }
}
#endif
