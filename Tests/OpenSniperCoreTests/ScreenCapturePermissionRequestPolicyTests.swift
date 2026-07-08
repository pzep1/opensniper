import XCTest
@testable import OpenSniperCore

final class ScreenCapturePermissionRequestPolicyTests: XCTestCase {
    func testCapturesImmediatelyWhenAccessIsAlreadyGranted() {
        var policy = ScreenCapturePermissionRequestPolicy()

        XCTAssertEqual(policy.action(hasScreenCaptureAccess: true), .capture)
    }

    func testRequestsPermissionOnlyOnceWhileAccessIsMissing() {
        var policy = ScreenCapturePermissionRequestPolicy()

        XCTAssertEqual(policy.action(hasScreenCaptureAccess: false), .requestPermission)
        XCTAssertEqual(policy.action(hasScreenCaptureAccess: false), .waitForRelaunch)
        XCTAssertEqual(policy.action(hasScreenCaptureAccess: false), .waitForRelaunch)
    }

    func testCapturesWhenAccessBecomesAvailableAfterRequest() {
        var policy = ScreenCapturePermissionRequestPolicy()

        XCTAssertEqual(policy.action(hasScreenCaptureAccess: false), .requestPermission)
        XCTAssertEqual(policy.action(hasScreenCaptureAccess: true), .capture)
    }
}
