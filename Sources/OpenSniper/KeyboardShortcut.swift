#if os(macOS)
import AppKit
import Carbon.HIToolbox

struct KeyboardShortcut: Codable, Equatable {
    var keyCode: UInt32
    var modifierRawValue: UInt

    static let defaultShortcut = KeyboardShortcut(
        keyCode: UInt32(kVK_ANSI_3),
        modifiers: [.control]
    )

    init(keyCode: UInt32, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifierRawValue = modifiers.intersection(.deviceIndependentFlagsMask).rawValue
    }

    var modifiers: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: modifierRawValue)
    }

    var carbonModifiers: UInt32 {
        var carbonFlags: UInt32 = 0

        if modifiers.contains(.command) {
            carbonFlags |= UInt32(cmdKey)
        }
        if modifiers.contains(.option) {
            carbonFlags |= UInt32(optionKey)
        }
        if modifiers.contains(.control) {
            carbonFlags |= UInt32(controlKey)
        }
        if modifiers.contains(.shift) {
            carbonFlags |= UInt32(shiftKey)
        }

        return carbonFlags
    }

    var displayString: String {
        modifierDisplay + keyDisplay
    }

    private var modifierDisplay: String {
        var parts: [String] = []

        if modifiers.contains(.control) {
            parts.append("^")
        }
        if modifiers.contains(.option) {
            parts.append("Option")
        }
        if modifiers.contains(.shift) {
            parts.append("Shift")
        }
        if modifiers.contains(.command) {
            parts.append("Command")
        }

        return parts.isEmpty ? "" : parts.joined(separator: "+") + "+"
    }

    private var keyDisplay: String {
        KeyboardShortcut.keyNames[keyCode] ?? "Key \(keyCode)"
    }

    private static let keyNames: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "A",
        UInt32(kVK_ANSI_B): "B",
        UInt32(kVK_ANSI_C): "C",
        UInt32(kVK_ANSI_D): "D",
        UInt32(kVK_ANSI_E): "E",
        UInt32(kVK_ANSI_F): "F",
        UInt32(kVK_ANSI_G): "G",
        UInt32(kVK_ANSI_H): "H",
        UInt32(kVK_ANSI_I): "I",
        UInt32(kVK_ANSI_J): "J",
        UInt32(kVK_ANSI_K): "K",
        UInt32(kVK_ANSI_L): "L",
        UInt32(kVK_ANSI_M): "M",
        UInt32(kVK_ANSI_N): "N",
        UInt32(kVK_ANSI_O): "O",
        UInt32(kVK_ANSI_P): "P",
        UInt32(kVK_ANSI_Q): "Q",
        UInt32(kVK_ANSI_R): "R",
        UInt32(kVK_ANSI_S): "S",
        UInt32(kVK_ANSI_T): "T",
        UInt32(kVK_ANSI_U): "U",
        UInt32(kVK_ANSI_V): "V",
        UInt32(kVK_ANSI_W): "W",
        UInt32(kVK_ANSI_X): "X",
        UInt32(kVK_ANSI_Y): "Y",
        UInt32(kVK_ANSI_Z): "Z",
        UInt32(kVK_ANSI_0): "0",
        UInt32(kVK_ANSI_1): "1",
        UInt32(kVK_ANSI_2): "2",
        UInt32(kVK_ANSI_3): "3",
        UInt32(kVK_ANSI_4): "4",
        UInt32(kVK_ANSI_5): "5",
        UInt32(kVK_ANSI_6): "6",
        UInt32(kVK_ANSI_7): "7",
        UInt32(kVK_ANSI_8): "8",
        UInt32(kVK_ANSI_9): "9",
        UInt32(kVK_Space): "Space",
        UInt32(kVK_Escape): "Escape",
        UInt32(kVK_Return): "Return",
        UInt32(kVK_Tab): "Tab"
    ]
}
#endif
