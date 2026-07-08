#if os(macOS)
import AppKit

protocol SelectionViewDelegate: AnyObject {
    func selectionView(_ view: SelectionView, didSelect rect: CGRect, on screen: NSScreen)
    func selectionViewDidCancel(_ view: SelectionView)
}

final class SelectionView: NSView {
    weak var delegate: SelectionViewDelegate?

    private let screen: NSScreen
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?

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
        let point = convert(event.locationInWindow, from: nil)
        startPoint = point
        currentPoint = point
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)

        guard let rect = selectionRect, rect.width >= 6, rect.height >= 6 else {
            delegate?.selectionViewDidCancel(self)
            return
        }

        delegate?.selectionView(self, didSelect: rect, on: screen)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            delegate?.selectionViewDidCancel(self)
        } else {
            super.keyDown(with: event)
        }
    }

    private var selectionRect: CGRect? {
        guard let startPoint, let currentPoint else {
            return nil
        }

        return CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        ).integral
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
