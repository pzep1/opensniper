#if os(macOS)
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
#else
print("OpenSniper is a macOS menu bar app. Build and run it on macOS 13 or newer.")
#endif
