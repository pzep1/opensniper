#if os(macOS)
import AppKit
import CoreGraphics

enum ScreenCapturePermission {
    static func hasAccess() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    @discardableResult
    static func requestAccess() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    static func openSettings() {
        let urlString: String

        if #available(macOS 13.0, *) {
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        } else {
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy"
        }

        guard let url = URL(string: urlString) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
#endif
