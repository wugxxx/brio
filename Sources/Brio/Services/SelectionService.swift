import AppKit
import ApplicationServices

enum SelectionSource {
    case accessibility
    case pasteboard
    case manual
}

struct SelectionResult {
    let text: String
    let source: SelectionSource
}

enum SelectionError: LocalizedError {
    case empty
    case unsupported
    case accessibilityPermission

    var errorDescription: String? {
        switch self {
        case .empty: "没有检测到选中文本，也可以直接在工作台中输入。"
        case .unsupported: "当前应用不支持直接替换，请复制结果后手动粘贴。"
        case .accessibilityPermission: "Brio 尚未获得辅助功能权限。请在系统设置中允许当前版本的 Brio，然后重新打开应用。"
        }
    }
}

@MainActor
enum SelectionService {
    static func capture() throws -> SelectionResult {
        guard AXIsProcessTrusted() else {
            AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
            throw SelectionError.accessibilityPermission
        }
        let system = AXUIElementCreateSystemWide()
        var focused: CFTypeRef?
        if AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focused) == .success,
           let focused {
            let element = focused as! AXUIElement
            var selected: CFTypeRef?
            if AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selected) == .success,
               let text = selected as? String, !text.isEmpty {
                return SelectionResult(text: text, source: .accessibility)
            }
        }
        let pasteboard = NSPasteboard.general
        let oldItems = pasteboard.pasteboardItems?.map { item in
            item.types.compactMap { type in
                item.data(forType: type).map { (type.rawValue, $0) }
            }
        } ?? []
        let source = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: true)
        let up = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: false)
        down?.flags = .maskCommand
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.15)
        let text = pasteboard.string(forType: .string)
        restore(oldItems, to: pasteboard)
        guard let text, !text.isEmpty else { throw SelectionError.empty }
        return SelectionResult(text: text, source: .pasteboard)
    }

    static func replace(with text: String, source: SelectionSource) throws {
        switch source {
        case .accessibility:
            let system = AXUIElementCreateSystemWide()
            var focused: CFTypeRef?
            guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focused) == .success,
                  let focused else { throw SelectionError.unsupported }
            let result = AXUIElementSetAttributeValue(focused as! AXUIElement, kAXSelectedTextAttribute as CFString, text as CFTypeRef)
            guard result == .success else { throw SelectionError.unsupported }
        case .pasteboard:
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            let source = CGEventSource(stateID: .hidSystemState)
            let down = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
            let up = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
            down?.flags = .maskCommand
            up?.flags = .maskCommand
            down?.post(tap: .cghidEventTap)
            up?.post(tap: .cghidEventTap)
        case .manual:
            throw SelectionError.unsupported
        }
    }

    private static func restore(_ items: [[(String, Data)]], to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        for itemData in items {
            let item = NSPasteboardItem()
            for (type, data) in itemData {
                item.setData(data, forType: NSPasteboard.PasteboardType(type))
            }
            pasteboard.writeObjects([item])
        }
    }
}
