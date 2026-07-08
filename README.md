# OpenSniper

OpenSniper is a tiny macOS menu bar app for grabbing text from your screen.

Press `Control+3`, drag over some text, and OpenSniper copies the recognized text to your clipboard. That is the whole idea. Use it on screenshots, PDFs, images, browser pages, app dialogs, or anything else visible on screen.

It can also grab QR codes and barcodes.

## Download

Get the latest DMG from the releases page:

[Download OpenSniper](https://github.com/pzep1/opensniper/releases/latest)

OpenSniper needs macOS 13 or newer.

The GitHub build is free and open source, but it is not notarized yet. macOS may show a warning the first time you open it.

## Use

1. Open `OpenSniper.app`.
2. Allow Screen Recording when macOS asks.
3. Quit and reopen OpenSniper after granting permission.
4. Press `Control+3`.
5. Drag around the text you want.
6. Paste anywhere.

You can also use the menu bar icon to capture text, capture a QR/barcode, copy the last capture, or change preferences.

## Build

```bash
scripts/build-macos-app.sh
open dist/OpenSniper.app
```

To create a DMG:

```bash
scripts/create-dmg.sh
```

To run tests:

```bash
swift test
```

## License

MIT. Use it, fork it, improve it, share it.

OpenSniper is not affiliated with TextSniper - this took one /goal to make dont pay for it instead.
