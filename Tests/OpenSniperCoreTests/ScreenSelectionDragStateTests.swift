import XCTest
@testable import OpenSniperCore

final class ScreenSelectionDragStateTests: XCTestCase {
    func testFinishesWhenDragMeetsMinimumSize() {
        var dragState = ScreenSelectionDragState(minimumSelectionSize: 6)

        dragState.begin(at: ScreenPoint(x: 20, y: 30))
        dragState.update(to: ScreenPoint(x: 80, y: 90))

        XCTAssertEqual(
            dragState.finish(at: ScreenPoint(x: 80, y: 90)),
            .finish(PointRect(x: 20, y: 30, width: 60, height: 60))
        )
    }

    func testKeepsSelectingWhenDragIsTooSmall() {
        var dragState = ScreenSelectionDragState(minimumSelectionSize: 6)

        dragState.begin(at: ScreenPoint(x: 20, y: 30))
        dragState.update(to: ScreenPoint(x: 23, y: 34))

        XCTAssertEqual(dragState.finish(at: ScreenPoint(x: 23, y: 34)), .keepSelecting)
        XCTAssertNil(dragState.selectionRect)
    }

    func testAllowsAnotherDragAfterTinyDrag() {
        var dragState = ScreenSelectionDragState(minimumSelectionSize: 6)

        dragState.begin(at: ScreenPoint(x: 20, y: 30))
        XCTAssertEqual(dragState.finish(at: ScreenPoint(x: 21, y: 31)), .keepSelecting)

        dragState.begin(at: ScreenPoint(x: 40, y: 50))
        XCTAssertEqual(
            dragState.finish(at: ScreenPoint(x: 90, y: 100)),
            .finish(PointRect(x: 40, y: 50, width: 50, height: 50))
        )
    }
}
