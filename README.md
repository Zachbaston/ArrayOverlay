<p align="center">
  <img src="docs/logo.png" alt="ArrayOverlay icon" width="160" height="160">
</p>

<h1 align="center">ArrayOverlay</h1>

A lightweight macOS utility that floats a **transparent, always-on-top image overlay** over everything else on your screen. Load an image, position/scale/rotate it, dial in the opacity, and toggle a **click-through** mode so you can keep working in the apps underneath while the image stays pinned on top.

It was built for overlaying roof / array imagery (e.g. sketching or aligning a solar panel layout against a real view), but it works as a general-purpose reference-image overlay for design comparisons, tracing, pixel-peeping, alignment, and presentations.

## Features

- **Always-on-top overlay** — floats above all windows and follows you across Spaces and full-screen apps.
- **Load any image** — via the **Add Roof** button (open panel) or by **drag-and-drop** (PNG, JPEG, TIFF, BMP, HEIC).
- **Direct manipulation** — drag to move, pinch to scale, two-finger rotate.
- **Opacity control** — slider from 15% to 95%.
- **Click-through toggle** — press **⌘⇧Space** (Command-Shift-Space) anywhere to switch between:
  - **ADJUST** — the overlay captures your mouse so you can move/scale/rotate it.
  - **CLICK-THROUGH** — mouse events pass straight through to the apps below; the image just floats there.
- **Reset** — snap position, scale, rotation, and opacity back to defaults.

## Requirements

- macOS 15.7 or later
- Xcode 16 or later (project was created with Xcode 26.2)
- Swift 5

## Build & Run

```bash
git clone <your-repo-url>
cd ArrayOverlay
open ArrayOverlay.xcodeproj
```

Then in Xcode press **▶ Run** (⌘R). The first build requires a one-time signing setup — see **[SETUP.md](SETUP.md)** for the exact steps and an explanation of the macOS permissions/capabilities involved.

## Usage

1. Launch the app — a translucent overlay window appears, centered.
2. Click **Add Roof** (or drag an image file onto the window) to load your image.
3. **Drag** to reposition, **pinch** to scale, **rotate** with two fingers. Use the **Opacity** slider to taste.
4. Press **⌘⇧Space** to flip into **CLICK-THROUGH** mode — now your clicks go to whatever is behind the overlay. Press it again to go back to **ADJUST**.
5. **Reset** returns everything to defaults.

## Privacy

ArrayOverlay runs **fully sandboxed**, makes **no network connections**, and stores **no data**. It only reads the image file *you* explicitly choose (open panel or drag-and-drop) for the current session. Nothing is saved or transmitted.

## Credits

Built by **Zach Baston** and **Biz Cannon**.

## License

[MIT](LICENSE) © 2026 Zach Baston and Biz Cannon
