public struct PointRect: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var maxY: Double {
        y + height
    }
}

public struct PixelSize: Equatable, Sendable {
    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public enum ScreenCaptureGeometry {
    public static func displayPixelRect(
        selectionInBottomLeftPoints selection: PointRect,
        displayPointSize: PixelSize,
        displayPixelSize: PixelSize
    ) -> PointRect? {
        guard selection.width > 0,
              selection.height > 0,
              displayPointSize.width > 0,
              displayPointSize.height > 0,
              displayPixelSize.width > 0,
              displayPixelSize.height > 0
        else {
            return nil
        }

        let scaleX = displayPixelSize.width / displayPointSize.width
        let scaleY = displayPixelSize.height / displayPointSize.height

        return PointRect(
            x: (selection.x * scaleX).rounded(.down),
            y: ((displayPointSize.height - selection.maxY) * scaleY).rounded(.down),
            width: (selection.width * scaleX).rounded(.up),
            height: (selection.height * scaleY).rounded(.up)
        )
    }
}
