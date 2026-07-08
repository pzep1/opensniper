#if os(macOS)
import AppKit
import CoreGraphics
import OpenSniperCore

struct ScreenSelection {
    let screen: NSScreen
    let rectInScreenPoints: CGRect

    var displayID: CGDirectDisplayID? {
        let value = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]

        if let displayID = value as? CGDirectDisplayID {
            return displayID
        }

        if let number = value as? NSNumber {
            return CGDirectDisplayID(number.uint32Value)
        }

        return nil
    }

    func captureImage() -> CGImage? {
        guard let displayID else {
            return nil
        }

        guard let pixelRect = ScreenCaptureGeometry.displayPixelRect(
            selectionInBottomLeftPoints: PointRect(
                x: Double(rectInScreenPoints.minX),
                y: Double(rectInScreenPoints.minY),
                width: Double(rectInScreenPoints.width),
                height: Double(rectInScreenPoints.height)
            ),
            displayPointSize: PixelSize(
                width: Double(screen.frame.width),
                height: Double(screen.frame.height)
            ),
            displayPixelSize: PixelSize(
                width: Double(CGDisplayPixelsWide(displayID)),
                height: Double(CGDisplayPixelsHigh(displayID))
            )
        ) else {
            return nil
        }

        let captureRect = CGRect(
            x: CGFloat(pixelRect.x),
            y: CGFloat(pixelRect.y),
            width: CGFloat(pixelRect.width),
            height: CGFloat(pixelRect.height)
        )

        return CGDisplayCreateImageForRect(displayID, captureRect)
    }
}
#endif
