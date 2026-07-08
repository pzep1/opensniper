#if os(macOS)
import AppKit
import Carbon.HIToolbox

enum HotKeyError: LocalizedError {
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .registrationFailed(let status):
            return "Carbon returned status \(status)."
        }
    }
}

final class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var action: (() -> Void)?

    deinit {
        unregister()
    }

    func register(shortcut: KeyboardShortcut, action: @escaping () -> Void) throws {
        unregister()
        self.action = action

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else {
                    return noErr
                }

                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.action?()
                }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        guard handlerStatus == noErr else {
            throw HotKeyError.registrationFailed(handlerStatus)
        }

        let hotKeyID = EventHotKeyID(
            signature: fourCharacterCode("OSNP"),
            id: 1
        )

        let registrationStatus = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard registrationStatus == noErr else {
            unregister()
            throw HotKeyError.registrationFailed(registrationStatus)
        }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private func fourCharacterCode(_ string: String) -> OSType {
        var result: UInt32 = 0

        for scalar in string.utf8.prefix(4) {
            result = (result << 8) + UInt32(scalar)
        }

        return OSType(result)
    }
}
#endif
