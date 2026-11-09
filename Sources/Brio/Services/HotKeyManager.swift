import AppKit
import Carbon.HIToolbox

struct ShortcutPreference: Codable, Hashable {
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

struct SceneShortcut: Codable, Equatable {
    var sceneID: WritingScene.ID?
    var shortcut: ShortcutPreference?
}

struct ShortcutConfiguration: Codable, Equatable {
    static let actionLimit = 5

    var workspace = ShortcutPreference.load()
    var actions = Array(repeating: SceneShortcut(), count: actionLimit)

    var hasConflicts: Bool {
        let shortcuts = [workspace] + actions.compactMap { action in
            action.sceneID == nil ? nil : action.shortcut
        }
        return Set(shortcuts).count != shortcuts.count
    }

    static func load() -> ShortcutConfiguration {
        guard let data = UserDefaults.standard.data(forKey: "shortcutConfiguration"),
              var value = try? JSONDecoder().decode(ShortcutConfiguration.self, from: data) else {
            return ShortcutConfiguration()
        }
        value.normalize()
        return value
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "shortcutConfiguration")
    }

    mutating func removeScene(_ id: WritingScene.ID) {
        for index in actions.indices where actions[index].sceneID == id {
            actions[index] = SceneShortcut()
        }
    }

    mutating func normalize() {
        if actions.count > Self.actionLimit {
            actions = Array(actions.prefix(Self.actionLimit))
        }
        while actions.count < Self.actionLimit {
            actions.append(SceneShortcut())
        }
    }
}

struct ShortcutRegistrationFailure: Equatable {
    let status: OSStatus

    var message: String {
        switch status {
        case OSStatus(eventHotKeyExistsErr):
            "该快捷键已被其他应用占用，请换一个。"
        case OSStatus(eventHotKeyInvalidErr):
            "macOS 不接受这个组合键，请换一个。"
        default:
            "无法注册这个快捷键，请换一个组合键。"
        }
    }
}

enum KeyCodeNames {
    static let names = [0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0", 31: "O", 32: "U", 34: "I", 35: "P", 37: "L", 38: "J", 39: "'", 40: "K", 45: "N", 46: "M", 49: "Space"]
}

@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()
    var onWorkspaceTrigger: (() -> Void)?
    var onSceneTrigger: ((WritingScene.ID) -> Void)?
    private var hotKeys: [EventHotKeyRef] = []
    private var scenesByHotKeyID: [UInt32: WritingScene.ID] = [:]
    private var handler: EventHandlerRef?

    @discardableResult
    func register(_ configuration: ShortcutConfiguration) -> [UInt32: ShortcutRegistrationFailure] {
        unregister()
        let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, _ in
            var id = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &id)
            Task { @MainActor in
                if id.id == 0 {
                    HotKeyManager.shared.onWorkspaceTrigger?()
                } else if let sceneID = HotKeyManager.shared.scenesByHotKeyID[id.id] {
                    HotKeyManager.shared.onSceneTrigger?(sceneID)
                }
            }
            return noErr
        }
        InstallEventHandler(GetEventDispatcherTarget(), callback, 1, [eventType], nil, &handler)
        guard !configuration.hasConflicts else { return [:] }
        var failures: [UInt32: ShortcutRegistrationFailure] = [:]
        if let failure = register(configuration.workspace, id: 0) {
            failures[0] = failure
        }
        for (index, action) in configuration.actions.enumerated() {
            guard let sceneID = action.sceneID, let shortcut = action.shortcut else { continue }
            let hotKeyID = UInt32(index + 1)
            scenesByHotKeyID[hotKeyID] = sceneID
            if let failure = register(shortcut, id: hotKeyID) {
                failures[hotKeyID] = failure
                scenesByHotKeyID.removeValue(forKey: hotKeyID)
            }
        }
        return failures
    }

    private func register(_ shortcut: ShortcutPreference, id: UInt32) -> ShortcutRegistrationFailure? {
        let hotKeyID = EventHotKeyID(signature: 0x4252494F, id: id)
        var hotKey: EventHotKeyRef?
        let status = RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKey)
        guard status == noErr else { return ShortcutRegistrationFailure(status: status) }
        if let hotKey { hotKeys.append(hotKey) }
        return nil
    }

    func unregister() {
        for hotKey in hotKeys { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
        hotKeys = []
        scenesByHotKeyID = [:]
        handler = nil
    }
}
