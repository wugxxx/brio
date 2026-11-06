import AppKit
import Carbon.HIToolbox

struct ShortcutPreference: Codable, Equatable {
    var keyCode: UInt32 = 11
    var modifiers: UInt32 = UInt32(cmdKey | shiftKey)

    var display: String {
        var value = ""
        if modifiers & UInt32(controlKey) != 0 { value += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { value += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { value += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { value += "⌘" }
        value += KeyCodeNames.names[Int(keyCode)] ?? "?"
        return value
    }

    static func load() -> ShortcutPreference {
        guard let data = UserDefaults.standard.data(forKey: "shortcut"),
              let value = try? JSONDecoder().decode(ShortcutPreference.self, from: data) else { return ShortcutPreference() }
        return value
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "shortcut")
    }
}

enum KeyCodeNames {
    static let names = [0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0", 31: "O", 32: "U", 34: "I", 35: "P", 37: "L", 38: "J", 39: "'", 40: "K", 45: "N", 46: "M", 49: "Space"]
}

@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()
    var onTrigger: (() -> Void)?
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    func register(_ shortcut: ShortcutPreference) {
        unregister()
        let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, _ in
            Task { @MainActor in HotKeyManager.shared.onTrigger?() }
            return noErr
        }
        InstallEventHandler(GetEventDispatcherTarget(), callback, 1, [eventType], nil, &handler)
        let id = EventHotKeyID(signature: 0x4252494F, id: 1)
        RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers, id, GetEventDispatcherTarget(), 0, &hotKey)
    }

    func unregister() {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
        hotKey = nil
        handler = nil
    }
}
