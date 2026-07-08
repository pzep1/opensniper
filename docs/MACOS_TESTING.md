# macOS Testing

OpenSniper needs a Mac for the first real verification pass. Source review and shell checks can run on Linux, but compile-time coverage of AppKit/Vision code and runtime coverage of screen capture cannot.

## What CI Can Cover

The GitHub Actions workflow in `.github/workflows/macos.yml` should cover:

- `swift test`
- app bundle packaging with `scripts/build-macos-app.sh`
- compile coverage on Apple Silicon via `macos-15`
- compile coverage on Intel via `macos-15-intel`

CI cannot validate interactive Screen Recording permission prompts, global shortcut delivery, overlay window behavior, clipboard writes into user apps, speech output, or real OCR quality against visible content.

## Required Interactive Mac Pass

Run these commands on a Mac with Xcode command line tools installed:

```bash
scripts/check.sh
open dist/OpenSniper.app
```

Use a fresh build from `dist/OpenSniper.app`, not `swift run`, for privacy-permission testing.

## Pass/Fail Checklist

| Area | Steps | Expected result |
| --- | --- | --- |
| Launch | Open `dist/OpenSniper.app`. | A menu bar item appears and no Dock icon appears. |
| Permission | Choose `Capture Text` or press `Command+Shift+2` before permission is granted. | macOS prompts for Screen Recording permission or OpenSniper opens the correct System Settings pane. |
| Relaunch | Grant Screen Recording permission, quit OpenSniper, and launch it again. | Capture can start without another permission error. |
| Shortcut | Press `Command+Shift+2`. | A crosshair-style full-screen overlay appears. |
| Cancel | Press `Esc` while the overlay is visible. | Overlay disappears and no clipboard write occurs. |
| OCR | Drag around visible text in Safari, TextEdit, Preview, or a PDF. | Recognized text is copied to the clipboard and can be pasted into another app. |
| Barcode | Choose `Capture QR or Barcode` and drag around a visible QR code. | The decoded payload is copied to the clipboard. |
| Last capture | Use `Copy Last Capture` after a successful OCR pass. | The same text is copied again. |
| Speech | Use `Speak Last Capture`. | macOS speaks the last recognized text. |
| Preferences | Open Preferences, change the shortcut, close Preferences, and press the new shortcut. | The old shortcut stops triggering capture and the new shortcut starts it. |
| Retina display | Capture a small text region on a Retina display. | The captured region matches the selected rectangle. |
| Multiple displays | Start capture with at least two displays connected and capture on each display. | Overlay appears on each display and the selected display captures correctly. |

## Known Follow-Up Areas

- Add signed and notarized release packaging before distributing outside developer/test machines.
- Add a persistent history view only if users need more than the last capture.
- Add a richer language picker after confirming Vision language support on the supported macOS range.
