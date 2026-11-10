import AppKit
import Foundation

enum WorkspaceOpenBehavior: String, CaseIterable, Identifiable {
    case preserve
    case clear
    case paste

    var id: Self { self }

    var title: String {
        switch self {
        case .preserve: "保留上次内容"
        case .clear: "清空并就绪"
        case .paste: "自动读取剪贴板"
        }
    }

    var symbol: String {
        switch self {
        case .preserve: "bookmark"
        case .clear: "delete.left"
        case .paste: "doc.on.clipboard"
        }
    }
}

struct WorkspacePreferences {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var preservesContent: Bool {
        defaults.object(forKey: "preserveWorkspaceContent") as? Bool ?? true
    }

    var openBehavior: WorkspaceOpenBehavior {
        if let rawValue = defaults.string(forKey: "workspaceOpenBehavior"),
           let behavior = WorkspaceOpenBehavior(rawValue: rawValue) {
            return behavior
        }
        return preservesContent ? .preserve : .clear
    }

    func saveOpenBehavior(_ behavior: WorkspaceOpenBehavior) {
        defaults.set(behavior.rawValue, forKey: "workspaceOpenBehavior")
        defaults.set(behavior != .clear, forKey: "preserveWorkspaceContent")
    }
}

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var scenes: [WritingScene]
    @Published var selectedScene: WritingScene
    @Published var sourceText = ""
    @Published var resultText = ""
    @Published var resultTitle = "生成结果"
    @Published var followUp = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var needsAccessibilityPermission = false
    @Published var source: SelectionSource = .manual
    @Published var statusMessage: String?
    @Published var isPinned = false {
        didSet { pinStateChanged?(isPinned) }
    }
    var presentPanel: (() -> Void)?
    var dismissPanel: (() -> Void)?
    var openSettings: (() -> Void)?
    var pinStateChanged: ((Bool) -> Void)?
    private let store = SceneStore()
    private var captureTask: Task<Void, Never>?
    private var generationTask: Task<Void, Never>?
    private var generationID = UUID()
    private var sourceApplication: NSRunningApplication?

    init() {
        let scenes = store.load()
        self.scenes = scenes
        selectedScene = scenes[0]
    }

    func openFromShortcut(sceneID: WritingScene.ID? = nil) {
        generationTask?.cancel()
        captureTask?.cancel()
        generationID = UUID()
        isProcessing = false
        needsAccessibilityPermission = false
        errorMessage = nil
        statusMessage = nil
        sourceText = ""
        resultText = ""
        resultTitle = "生成结果"
        followUp = ""
        source = .manual
        sourceApplication = NSWorkspace.shared.frontmostApplication
        if let sceneID, let scene = scenes.first(where: { $0.id == sceneID }) {
            selectedScene = scene
        }

        captureTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let selection = try await SelectionService.capture()
                try Task.checkCancellation()
                self.sourceText = selection.text
                self.source = selection.source
                self.presentPanel?()
                self.generate()
            } catch is CancellationError {
                return
            } catch {
                self.errorMessage = error.localizedDescription
                if let selectionError = error as? SelectionError,
                   case .accessibilityPermission = selectionError {
                    self.needsAccessibilityPermission = true
                }
                self.presentPanel?()
                self.announce("读取选区失败。\(error.localizedDescription)", priority: .high)
            }
        }
    }

    func openWorkspace() {
        captureTask?.cancel()
        statusMessage = nil
        switch WorkspacePreferences().openBehavior {
        case .preserve:
            break
        case .clear:
            clearWorkspace()
        case .paste:
            clearWorkspace()
            if let text = NSPasteboard.general.string(forType: .string),
               !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sourceText = text
                statusMessage = "已读取剪贴板"
            }
        }
        source = .manual
        errorMessage = nil
        needsAccessibilityPermission = false
        presentPanel?()
    }

    private func clearWorkspace() {
        generationTask?.cancel()
        generationID = UUID()
        isProcessing = false
        sourceText = ""
        resultText = ""
        resultTitle = "生成结果"
        followUp = ""
    }

    func select(_ scene: WritingScene) {
        selectedScene = scene
    }

    func generate() {
        guard !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "还没有可处理的文字。请输入，或选中文字后按场景快捷键。"
            statusMessage = nil
            announce(errorMessage ?? "还没有可处理的文字。", priority: .medium)
            return
        }
        let prompt = PromptBuilder.make(scene: selectedScene, text: sourceText, followUp: followUp, previousResult: resultText)
        resultTitle = selectedScene.isTranslation ? "翻译结果" : "生成结果"
        followUp = ""
        errorMessage = nil
        needsAccessibilityPermission = false
        statusMessage = nil
        isProcessing = true
        let provider = ProviderSettings().makeProvider()
        generationTask?.cancel()
        let runID = UUID()
        generationID = runID
        generationTask = Task {
            var pending = ""
            var accumulated = ""
            var lastFlush = Date()
            do {
                for try await chunk in provider.stream(prompt: prompt) {
                    guard !Task.isCancelled, generationID == runID else { return }
                    pending += chunk
                    let now = Date()
                    if pending.count >= 32 || now.timeIntervalSince(lastFlush) >= 0.05 {
                        accumulated += pending
                        resultText = accumulated
                        pending.removeAll(keepingCapacity: true)
                        lastFlush = now
                    }
                }
                guard generationID == runID else { return }
                if !pending.isEmpty {
                    accumulated += pending
                    resultText = accumulated
                }
                isProcessing = false
                if !resultText.isEmpty {
                    announce("生成完成。结果可以复制或替换。")
                }
            } catch {
                if !Task.isCancelled, generationID == runID {
                    if !pending.isEmpty {
                        accumulated += pending
                        resultText = accumulated
                    }
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    announce("生成失败。\(error.localizedDescription)", priority: .high)
                }
            }
        }
    }

    func stop(announce announces: Bool = true) {
        generationTask?.cancel()
        generationID = UUID()
        isProcessing = false
        if announces {
            statusMessage = "已停止生成"
            announce("已停止生成")
        }
    }

    func copyResult() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultText, forType: .string)
        statusMessage = "已复制到剪贴板"
        announce("已复制到剪贴板")
    }

    func togglePinned() {
        isPinned.toggle()
    }

    func replaceSelection() {
        guard source != .manual else {
            copyResult()
            return
        }
        dismissPanel?()
        Task {
            sourceApplication?.activate()
            try? await Task.sleep(for: .milliseconds(150))
            do {
                try SelectionService.replace(with: resultText, source: source)
                statusMessage = "已替换原文"
                announce("已替换原文")
            } catch {
                errorMessage = error.localizedDescription
                presentPanel?()
                announce("替换失败。\(error.localizedDescription)", priority: .high)
            }
        }
    }

    var isProviderConfigured: Bool {
        let settings = ProviderSettings()
        return !settings.baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !settings.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !settings.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }

    private func announce(_ message: String, priority: NSAccessibilityPriorityLevel = .medium) {
        NSAccessibility.post(
            element: NSApplication.shared,
            notification: .announcementRequested,
            userInfo: [
                .announcement: message,
                .priority: priority.rawValue
            ]
        )
    }

    func addScene(name: String, subtitle: String, instruction: String) {
        let scene = WritingScene(name: name, subtitle: subtitle.isEmpty ? "自定义场景" : subtitle, symbol: "slider.horizontal.3", instruction: instruction)
        scenes.append(scene)
        store.save(scenes)
    }

    func updateScene(id: WritingScene.ID, name: String, subtitle: String, instruction: String) {
        guard let index = scenes.firstIndex(where: { $0.id == id }) else { return }
        scenes[index].name = name
        scenes[index].subtitle = subtitle
        scenes[index].instruction = instruction
        if selectedScene.id == id {
            selectedScene = scenes[index]
        }
        store.save(scenes)
    }

    func deleteScene(id: WritingScene.ID) {
        guard let index = scenes.firstIndex(where: { $0.id == id }) else { return }
        scenes.remove(at: index)
        if scenes.isEmpty {
            scenes = WritingScene.builtIns
        }
        if selectedScene.id == id {
            selectedScene = scenes[min(index, scenes.count - 1)]
        }
        store.save(scenes)
        var shortcuts = ShortcutConfiguration.load()
        shortcuts.removeScene(id)
        shortcuts.save()
        HotKeyManager.shared.register(shortcuts)
    }
}
