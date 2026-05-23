import Cocoa
import Carbon.HIToolbox

// Global reference used by the Carbon callback (simple + reliable)
private var gAppDelegate: AppDelegate?

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyHandlerRef: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        gAppDelegate = self

        guard let window = NSApplication.shared.windows.first else { return }

        // Overlay window styling
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true

        // Always on top
        window.level = .floating

        // Show across Spaces + allow on fullscreen desktops
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.center()

        registerGlobalHotkey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let hotKeyHandlerRef { RemoveEventHandler(hotKeyHandlerRef) }
        gAppDelegate = nil
    }

    private func registerGlobalHotkey() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Install the C callback
        InstallEventHandler(
            GetApplicationEventTarget(),
            AppDelegate.hotKeyHandler,
            1,
            &eventType,
            nil,
            &hotKeyHandlerRef
        )

        // Cmd+Shift+Space
        let keyCode = UInt32(kVK_Space)
        let modifiers = UInt32(cmdKey | shiftKey)

        // This does NOT need to be var (fixes your warning)
        let hotKeyID = EventHotKeyID(signature: OSType(0x414F5652), id: 1) // "AOVR"

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    // C-style handler (cannot capture self)
    private static let hotKeyHandler: EventHandlerUPP = { (_, event, _) -> OSStatus in
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        if status == noErr, hotKeyID.id == 1 {
            DispatchQueue.main.async {
                gAppDelegate?.toggleClickThrough()
            }
        }
        return noErr
    }

    private func toggleClickThrough() {
        guard let window = NSApplication.shared.windows.first else { return }
        window.ignoresMouseEvents.toggle()

        // keep SwiftUI state in sync
        NotificationCenter.default.post(
            name: Notification.Name("ToggleClickThrough"),
            object: nil
        )
    }
}

