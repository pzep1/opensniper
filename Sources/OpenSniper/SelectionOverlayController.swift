#if os(macOS)
import AppKit

final class SelectionOverlayController {
    private var windows: [NSWindow] = []
    private var completion: ((ScreenSelection?) -> Void)?

    func begin(completion: @escaping (ScreenSelection?) -> Void) {
        self.completion = completion
        NSApp.activate(ignoringOtherApps: true)

        windows = NSScreen.screens.map { screen in
            let view = SelectionView(screen: screen)
            view.delegate = self

            let window = SelectionWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.contentView = view
            window.backgroundColor = .clear
            window.isOpaque = false
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.ignoresMouseEvents = false
            window.acceptsMouseMovedEvents = true
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(view)

            return window
        }

        NSCursor.crosshair.set()
    }

    private func finish(with selection: ScreenSelection?) {
        NSCursor.arrow.set()
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()

        let completion = self.completion
        self.completion = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            completion?(selection)
        }
    }
}

private final class SelectionWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}

extension SelectionOverlayController: SelectionViewDelegate {
    func selectionView(_ view: SelectionView, didSelect rect: CGRect, on screen: NSScreen) {
        finish(with: ScreenSelection(screen: screen, rectInScreenPoints: rect))
    }

    func selectionViewDidCancel(_ view: SelectionView) {
        finish(with: nil)
    }
}
#endif
