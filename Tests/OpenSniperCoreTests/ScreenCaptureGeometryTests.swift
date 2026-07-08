import XCTest
@testable import OpenSniperCore

final class ScreenCaptureGeometryTests: XCTestCase {
    func testConvertsRetinaPointSelectionToDisplayPixels() {
        let rect = ScreenCaptureGeometry.displayPixelRect(
            selectionInBottomLeftPoints: PointRect(x: 10, y: 20, width: 100, height: 50),
            displayPointSize: PixelSize(width: 500, height: 300),
            displayPixelSize: PixelSize(width: 1000, height: 600)
        )

        XCTAssertEqual(rect, PointRect(x: 20, y: 460, width: 200, height: 100))
    }

    func testRejectsEmptySelections() {
        let rect = ScreenCaptureGeometry.displayPixelRect(
            selectionInBottomLeftPoints: PointRect(x: 0, y: 0, width: 0, height: 10),
            displayPointSize: PixelSize(width: 500, height: 300),
            displayPixelSize: PixelSize(width: 1000, height: 600)
        )

        XCTAssertNil(rect)
    }
}
