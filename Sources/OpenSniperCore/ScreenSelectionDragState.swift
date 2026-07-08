public enum ScreenSelectionDragResult: Equatable {
    case keepSelecting
    case finish(PointRect)
}

public struct ScreenPoint: Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct ScreenSelectionDragState {
    private let minimumSelectionSize: Double
    private var startPoint: ScreenPoint?
    private var currentPoint: ScreenPoint?

    public init(minimumSelectionSize: Double = 6) {
        self.minimumSelectionSize = minimumSelectionSize
    }

    public var selectionRect: PointRect? {
        guard let startPoint, let currentPoint else {
            return nil
        }

        return PointRect(
            x: min(startPoint.x, currentPoint.x).rounded(.down),
            y: min(startPoint.y, currentPoint.y).rounded(.down),
            width: abs(currentPoint.x - startPoint.x).rounded(.up),
            height: abs(currentPoint.y - startPoint.y).rounded(.up)
        )
    }

    public mutating func begin(at point: ScreenPoint) {
        startPoint = point
        currentPoint = point
    }

    public mutating func update(to point: ScreenPoint) {
        currentPoint = point
    }

    public mutating func finish(at point: ScreenPoint) -> ScreenSelectionDragResult {
        currentPoint = point

        guard let selectionRect,
              selectionRect.width >= minimumSelectionSize,
              selectionRect.height >= minimumSelectionSize
        else {
            reset()
            return .keepSelecting
        }

        return .finish(selectionRect)
    }

    public mutating func reset() {
        startPoint = nil
        currentPoint = nil
    }
}
