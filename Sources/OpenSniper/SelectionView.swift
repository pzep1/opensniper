#if os(macOS)
import AppKit
import OpenSniperCore

protocol SelectionViewDelegate: AnyObject {
    func selectionView(_ view: SelectionView, didSelect rect: CGRect, on screen: NSScreen)
    func selectionViewDidCancel(_ view: SelectionView)
}

final class SelectionView: NSView {
    weak var delegate: SelectionViewDelegate?

    private let screen: NSScreen
    private var dragState = ScreenSelectionDragState()

    init(screen: NSScreen) {
        self.screen = screen
        super.init(frame: CGRect(origin: .zero, size: screen.frame.size))
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        context.setFillColor(NSColor.black.withAlphaComponent(0.22).cgColor)
        context.fill(bounds)

        guard let selectionRect else {
            drawHint(in: bounds)
            return
        }

        context.clear(selectionRect)
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(2)
        context.stroke(selectionRect)

        context.setStrokeColor(NSColor.black.withAlphaComponent(0.55).cgColor)
        context.setLineWidth(1)
        context.stroke(selectionRect.insetBy(dx: -1, dy: -1))
    }

    override func mouseDown(with event: NSEvent) {
        dragState.begin(at: screenPoint(from: event))
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        dragState.update(to: screenPoint(from: event))
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        switch dragState.finish(at: screenPoint(from: event)) {
        case .keepSelecting:
            needsDisplay = true
        case .finish(let rect):
            delegate?.selectionView(self, didSelect: cgRect(from: rect), on: screen)
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            delegate?.selectionViewDidCancel(self)
        } else {
            super.keyDown(with: event)
        }
    }

    private var selectionRect: CGRect? {
        guard let selectionRect = dragState.selectionRect else {
            return nil
        }

        return cgRect(from: selectionRect)
    }

    private func screenPoint(from event: NSEvent) -> ScreenPoint {
        let point = convert(event.locationInWindow, from: nil)
        return ScreenPoint(x: Double(point.x), y: Double(point.y))
    }

    private func cgRect(from rect: PointRect) -> CGRect {
        CGRect(
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
        )
    }

    private func drawHint(in rect: CGRect) {
        let text = "Drag to capture text. Press Esc to cancel."
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 16, weight: .medium)
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let size = attributedText.size()
        let origin = CGPoint(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2
        )

        attributedText.draw(at: origin)
    }
}
#endif
