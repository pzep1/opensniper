public enum ScreenCapturePermissionAction: Equatable {
    case capture
    case requestPermission
    case waitForRelaunch
}

public struct ScreenCapturePermissionRequestPolicy {
    private var hasRequestedPermission = false

    public init() {}

    public mutating func action(hasScreenCaptureAccess: Bool) -> ScreenCapturePermissionAction {
        if hasScreenCaptureAccess {
            return .capture
        }

        if hasRequestedPermission {
            return .waitForRelaunch
        }

        hasRequestedPermission = true
        return .requestPermission
    }
}
