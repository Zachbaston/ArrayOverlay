# Setup & Permissions Guide

This guide covers everything you need to **build, sign, run, and (optionally) share** ArrayOverlay, and explains the macOS permissions/capabilities involved. If you just cloned the repo and hit a signing error or the app won't launch, start here.

---

## 1. Prerequisites

| Need | Version |
|------|---------|
| macOS | 15.7 or later |
| Xcode | 16 or later (created with 26.2) |
| Apple ID | Any free Apple ID works — a paid Developer Program membership is **not** required to build and run locally |

---

## 2. Open the project

```bash
open ArrayOverlay.xcodeproj
```

---

## 3. Code signing — the one thing you *must* configure

The project ships with **Automatic** signing and **no Development Team** baked in (on purpose — so it doesn't carry anyone's Apple Team ID). On your machine you set your own. This is the step most people mean when they say "I had to do something to get it to build."

1. In Xcode's left sidebar, select the blue **ArrayOverlay** project at the top.
2. Select the **ArrayOverlay** *target* → **Signing & Capabilities** tab.
3. Under **Signing**:
   - Make sure **Automatically manage signing** is checked.
   - Set **Team** to your Apple ID. If your Apple ID isn't listed, click **Add an Account…** and sign in with any Apple ID.
   - If you have no Developer account at all, choose your **Personal Team** — Xcode will "Sign to Run Locally," which is enough to run the app on your own Mac.

> Xcode auto-generates the bundle identifier signing from `com.arrayoverlay.ArrayOverlay`. You can change the bundle ID to your own reverse-DNS (e.g. `com.yourname.ArrayOverlay`) if your team requires a unique one.

---

## 4. Capabilities — what's already configured (and why)

These are set in the project; you don't need to add them, but here's what they do and why the app needs them:

| Capability / Setting | Value | Why it's needed |
|---|---|---|
| **App Sandbox** | **On** | The app runs in Apple's sandbox — no access to your files, network, or system beyond what's explicitly granted. This is what makes it safe. |
| **User Selected File → Read Only** | **On** | This is the entitlement that lets the **Add Roof** open panel and **drag-and-drop** actually *read* the image you pick. Without it, a sandboxed app would be blocked from opening the file and the image silently wouldn't load. |
| **App Groups** | **Off** | Not used by this app. (It was enabled in an early version; it's now off because it required a provisioning profile and caused signing failures for people building with a free/personal team.) |
| **Network** | **Off** | The app makes no connections. Nothing leaves your machine. |

If you ever see the **Add Roof** button or drag-and-drop do nothing, confirm **Signing & Capabilities → App Sandbox → File Access → User Selected File** is set to **Read Only** (or higher).

---

## 5. Build & run

Press **▶ Run** (**⌘R**). A translucent, always-on-top overlay window appears in the center of your screen.

---

## 6. Runtime permissions — good news: there are none to grant

This is worth being explicit about, because overlay/hotkey apps *often* demand scary permissions and this one does **not**:

- **The ⌘⇧Space global hotkey does NOT require Accessibility permission.** It's registered through Carbon's `RegisterEventHotKey`, which is a normal system hotkey registration — macOS will **not** prompt you to add the app under *System Settings → Privacy & Security → Accessibility*, and you don't need to.
- **No Screen Recording permission** is needed — the app only displays an image *you* load; it never reads or captures the screen.
- **No Input Monitoring permission** is needed.

In other words, after signing and running, the app should "just work" with **zero** entries in System Settings → Privacy & Security.

### If the ⌘⇧Space hotkey doesn't fire
It's almost always a **shortcut conflict**, not a permission:
- Another app (or a macOS system shortcut) may already own **⌘⇧Space**. Check **System Settings → Keyboard → Keyboard Shortcuts…** and quit/reconfigure the conflicting app.
- To use a different combo, change it in `ArrayOverlay/AppDelegate.swift` in `registerGlobalHotkey()` — `kVK_Space` is the key and `cmdKey | shiftKey` are the modifiers.

---

## 7. Sharing a *built* app with someone else (Gatekeeper)

Building from source on your own machine (above) needs no extra steps. But if you hand someone a compiled **ArrayOverlay.app** that **isn't notarized by Apple**, macOS Gatekeeper will block it on first launch ("ArrayOverlay can't be opened because Apple cannot check it for malicious software").

The recipient can open it one of two ways:

- **Right-click the app → Open → Open** (confirms the override once), **or**
- **System Settings → Privacy & Security** → scroll down → click **Open Anyway**.

If macOS quarantines it more aggressively, the recipient can clear the quarantine flag:

```bash
xattr -dr com.apple.quarantine /path/to/ArrayOverlay.app
```

> For frictionless distribution you'd need to sign with a **Developer ID** certificate and **notarize** the app with Apple — that requires a paid Apple Developer Program membership and is out of scope for local/open-source builds.

---

## 8. Troubleshooting

| Symptom | Fix |
|---|---|
| "Signing for ArrayOverlay requires a development team" | Section 3 — pick a Team in Signing & Capabilities. |
| Build fails mentioning **App Groups** / provisioning profile | Make sure App Groups is **off** (it is in this repo). Clean build folder: **Product → Clean Build Folder** (⇧⌘K). |
| **Add Roof** / drag-drop does nothing | Confirm **App Sandbox → User Selected File → Read Only** is enabled (Section 4). |
| **⌘⇧Space** does nothing | Shortcut conflict — see Section 6. |
| The window won't go away / stays on top | That's by design (always-on-top). Quit the app from the menu bar or **⌘Q**. |
| Recipient of a built `.app` sees "can't be opened" | Gatekeeper — Section 7. |
