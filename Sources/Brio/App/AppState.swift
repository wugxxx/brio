import AppKit
import Foundation

struct WorkspacePreferences {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var preservesContent: Bool {
        defaults.object(forKey: "preserveWorkspaceContent") as? Bool ?? true
    }
}

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var scenes: [WritingScene]
    @Published var selectedScene: WritingScene
    @Published var sourceText = ""
    @Published var resultText = ""
    @Published var followUp = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var source: SelectionSource = .manual
    @Published var statusMessage: String?
    @Published var isPinned = false {
        didSet { pinStateChanged?(isPinned) }
    }
    var presentPanel: (() -> Void)?
    var dismissPanel: (() -> Void)?
    var pinStateChanged: ((Bool) -> Void)?
    private let store = SceneStore()
    private var generationTask: Task<Void, Never>?
    private var sourceApplication: NSRunningApplication?

    init() {
        let scenes = store.load()
        self.scenes = scenes
        selectedScene = scenes[0]
    }

    func openFromShortcut(sceneID: WritingScene.ID? = nil) {
        generationTask?.cancel()
        isProcessing = false
        sourceApplication = NSWorkspace.shared.frontmostApplication
        if let sceneID, let scene = scenes.first(where: { $0.id == sceneID }) {
            selectedScene = scene
        }
        do {
            let selection = try SelectionService.capture()
            sourceText = selection.text
            source = selection.source
            errorMessage = nil
            resultText = ""
            followUp = ""
            statusMessage = nil
            presentPanel?()
            generate()
        } catch {
            errorMessage = error.localizedDescription
            resultText = ""
            presentPanel?()
        }
    }

    func openWorkspace() {
        if !WorkspacePreferences().preservesContent {
            generationTask?.cancel()
            isProcessing = false
            sourceText = ""
            resultText = ""
            followUp = ""
            statusMessage = nil
        }
        source = .manual
        errorMessage = nil
        presentPanel?()
    }

    func select(_ scene: WritingScene) {
        selectedScene = scene
        guard !sourceText.isEmpty else { return }
        generate()
    }

    func generate() {
        guard !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "请先输入或选中一段文本。"
            return
        }
        let prompt = PromptBuilder.make(scene: selectedScene, text: sourceText, followUp: followUp, previousResult: resultText)
        followUp = ""
        resultText = ""
        errorMessage = nil
        statusMessage = nil
        isProcessing = true
        let provider = ProviderSettings().makeProvider()
        generationTask?.cancel()
        generationTask = Task {
            do {
                for try await chunk in provider.stream(prompt: prompt) {
                    guard !Task.isCancelled else { return }
                    resultText += chunk
                }
                isProcessing = false
            } catch {
                if !Task.isCancelled {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func stop() {
        generationTask?.cancel()
        isProcessing = false
    }

    func copyResult() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultText, forType: .string)
        statusMessage = "已复制到剪贴板"
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
            } catch {
                errorMessage = error.localizedDescription
                presentPanel?()
            }
        }
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
