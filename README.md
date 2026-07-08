# OpenSniper

OpenSniper is an open-source macOS menu bar utility for capturing text from any visible screen area. It is inspired by the common OCR snipping workflow: press a shortcut, drag over an area, and paste the recognized text from the clipboard.

This project is not affiliated with TextSniper and does not reuse its name, assets, copy, or proprietary code.

## Features

- Menu bar app with no Dock icon.
- Global shortcut, defaulting to `Command+Shift+2`.
- Drag-to-select screen overlay.
- OCR through Apple's Vision framework.
- Copies recognized text to the clipboard.
- QR code and barcode capture through Vision.
- Text-to-speech for the last capture.
- Preferences for shortcut, OCR speed, OCR language hints, line joining, and auto-speech.

## Requirements

- macOS 13 Ventura or newer.
- Xcode command line tools.
- Screen Recording permission granted to the built app.

The implementation uses AppKit, Carbon global hotkeys, CoreGraphics screen capture, Vision OCR/barcode detection, NSPasteboard, and NSSpeechSynthesizer.

## Build

```bash
scripts/build-macos-app.sh
open dist/OpenSniper.app
```

The script builds the Swift package, creates `dist/OpenSniper.app`, and applies ad-hoc code signing so macOS can launch the app bundle.

For development without packaging:

```bash
swift run OpenSniper
```

Running as a bare command-line executable may not behave exactly like the app bundle for privacy permissions. Use the packaged `.app` for screen capture testing.

## Test

```bash
swift test
```

The current automated tests cover text post-processing and screen-capture geometry. AppKit, global shortcuts, screen capture permissions, and Vision recognition require manual macOS validation.

The repository also includes a macOS GitHub Actions workflow at `.github/workflows/macos.yml` that runs `swift test` and packages the app bundle on Apple Silicon and Intel macOS runners.

For host-aware checks, run:

```bash
scripts/check.sh
```

## When a Mac Is Required

A macOS computer is required now for the next verification step. The Linux workspace can store and review the source, but it cannot compile AppKit/Vision code or exercise the OS privacy prompts.

Use a Mac for:

- `swift test`, because the package declares a macOS platform and the app target imports AppKit, Vision, Carbon, and CoreGraphics.
- `scripts/build-macos-app.sh`, because it creates and signs a `.app` bundle.
- Runtime testing of Screen Recording permission, the global shortcut, overlay windows, OCR, barcode detection, clipboard writes, and speech.
- Display-geometry validation on Retina and multi-monitor setups.

See `docs/MACOS_TESTING.md` for the full pass/fail checklist.

## Manual macOS Validation Checklist

1. Build with `scripts/build-macos-app.sh`.
2. Launch `dist/OpenSniper.app`.
3. Grant Screen Recording permission when prompted, then quit and relaunch the app.
4. Confirm the menu bar icon appears and the app does not appear in the Dock.
5. Press `Command+Shift+2`; verify the selection overlay appears on each connected display.
6. Drag a rectangle around selectable-looking text in a browser or PDF; verify text is copied to the clipboard.
7. Paste into TextEdit or another editor and compare OCR quality.
8. Use the menu item `Capture QR or Barcode`; verify a QR/barcode payload is copied.
9. Open Preferences, change the shortcut, and verify the new shortcut works after closing Preferences.
10. Test with Retina and non-Retina displays if available; confirm the captured region matches the selection.

## Known First-Pass Limitations

- The selection must stay within one display.
- The app uses the current visible pixels, so protected video surfaces or DRM content may not be capturable.
- Language hints are passed directly to Vision; unsupported language tags may reduce accuracy or cause Vision errors on older macOS versions.
- Packaging is intentionally simple and uses ad-hoc signing. Release distribution needs a Developer ID certificate and notarization.
