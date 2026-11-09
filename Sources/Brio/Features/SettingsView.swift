import SwiftUI
import AppKit
import Carbon.HIToolbox
import ApplicationServices

private enum SettingsTab: String, CaseIterable, Identifiable, Hashable {
    case general = "通用"
    case provider = "AI 服务"
    case shortcuts = "快捷键"
    case scenes = "场景"
    var id: Self { self }
    var symbol: String {
        switch self {
        case .general: "gearshape"
        case .provider: "server.rack"
        case .shortcuts: "keyboard"
        case .scenes: "square.grid.2x2"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @State private var tab: SettingsTab = .general
    @State private var baseURL = ""
    @State private var model = ""
    @State private var apiKey = ""
    @State private var showsAPIKey = false
    @State private var shortcuts = ShortcutConfiguration.load()
    @State private var sceneName = ""
    @State private var sceneSubtitle = ""
    @State private var sceneInstruction = ""
    @State private var editingSceneID: WritingScene.ID?
    @State private var pendingSceneDeletion: WritingScene?
    @State private var shortcutFailures: [UInt32: ShortcutRegistrationFailure] = [:]
    @State private var saved = false
    @State private var accessibilityGranted = AXIsProcessTrusted()
    @AppStorage("preserveWorkspaceContent") private var preserveWorkspaceContent = true

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            ScrollView {
                content.padding(26).frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 700, idealWidth: 760, minHeight: 480, idealHeight: 540)
        .onAppear {
            let settings = ProviderSettings()
            baseURL = settings.baseURL
            model = settings.model
            apiKey = settings.apiKey
            shortcutFailures = HotKeyManager.shared.register(shortcuts)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            accessibilityGranted = AXIsProcessTrusted()
        }
        .onChange(of: shortcuts) { _, value in
            guard !value.hasConflicts else {
                shortcutFailures = [:]
                return
            }
            value.save()
            shortcutFailures = HotKeyManager.shared.register(value)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                BrioAppIcon(size: 26)
                Text("Brio").font(.system(.title2, design: .rounded).weight(.semibold))
            }
            .padding(.horizontal, 18).padding(.top, 42).padding(.bottom, 24)
            List(selection: $tab) {
                ForEach(SettingsTab.allCases) { item in
                    Label(item.rawValue, systemImage: item.symbol)
                        .font(.body)
                        .tag(item)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .frame(maxHeight: .infinity)
            Text("让表达恰如其分").font(.caption).foregroundStyle(.secondary)
                .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 22)
        }
        .frame(minWidth: 180, idealWidth: 190, maxWidth: 200)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.55))
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .general: generalSettings
        case .provider: providerSettings
        case .shortcuts: shortcutSettings
        case .scenes: sceneSettings
        }
    }

    private var generalSettings: some View {
        SettingsCard {
            SettingsRow(symbol: "accessibility", title: accessibilityGranted ? "辅助功能权限已授权" : "需要辅助功能权限") {
                if accessibilityGranted {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else {
                    Button("去授权") { AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary) }
                        .buttonStyle(.bordered).controlSize(.small)
                }
            }
            SettingsDivider()
            SettingsRow(symbol: "text.document", title: "再次打开工作台") {
                Picker("再次打开工作台", selection: $preserveWorkspaceContent) {
                    Text("保留上次内容").tag(true)
                    Text("清空内容").tag(false)
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .fixedSize()
            }
            SettingsDivider()
            SettingsRow(symbol: "lock.shield", title: "本地配置") {
                Text("仅保存在此 Mac").font(.callout).foregroundStyle(.secondary)
            }
        } footer: {
            Text("工作台内容包含原文、生成结果和后续调整；所选场景始终保留。文本仅在生成时发送给你配置的 AI 服务。")
        }
    }

    private var providerSettings: some View {
        SettingsCard {
            SettingsRow(symbol: "network", title: "服务商") {
                Text("OpenAI 兼容").font(.callout).foregroundStyle(.secondary)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.field))
            }
            SettingsDivider()
            SettingsRow(symbol: "link", title: "Base URL") {
                SettingsTextField(label: "Base URL", text: $baseURL, prompt: "https://api.openai.com/v1")
            }
            SettingsDivider()
            SettingsRow(symbol: "key", title: "API Key") {
                HStack(spacing: 4) {
                    Group {
                        if showsAPIKey {
                            TextField("", text: $apiKey, prompt: Text("sk-..."))
                                .accessibilityLabel("API Key")
                        } else {
                            SecureField("", text: $apiKey)
                                .accessibilityLabel("API Key")
                        }
                    }
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.field))
                    .overlay(RoundedRectangle(cornerRadius: Radius.field).stroke(Tone.hairline))
                    Button(showsAPIKey ? "隐藏 Key" : "显示 Key", systemImage: showsAPIKey ? "eye.slash" : "eye") { showsAPIKey.toggle() }
                        .labelStyle(.iconOnly).buttonStyle(.borderless).foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                        .help(showsAPIKey ? "隐藏 API Key" : "显示 API Key")
                }
                .frame(minWidth: 240, maxWidth: 360)
            }
            SettingsDivider()
            SettingsRow(symbol: "cpu", title: "模型") {
                SettingsTextField(label: "模型", text: $model, prompt: "模型 ID")
            }
            SettingsDivider()
            HStack {
                if saved {
                    HStack(spacing: Space.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(nsColor: .systemGreen))
                            .accessibilityHidden(true)
                        Text("已保存")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("设置已保存")
                }
                Spacer()
                Button("保存设置") {
                    let settings = ProviderSettings()
                    settings.save(baseURL: baseURL, model: model)
                    settings.saveAPIKey(apiKey)
                    saved = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(baseURL.trimmingCharacters(in: .whitespaces).isEmpty || model.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(14)
        } footer: {
            Text("端点需支持 POST {base}/chat/completions 和流式输出。API Key 保存在本机应用设置中。")
        }
        .onChange(of: baseURL) { saved = false }
        .onChange(of: model) { saved = false }
        .onChange(of: apiKey) { saved = false }
    }

    private var shortcutSettings: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsCard {
                SettingsRow(symbol: "macwindow", title: "打开工作台") {
                    VStack(alignment: .trailing, spacing: 6) {
                        ShortcutRecorder(shortcut: workspaceShortcutBinding)
                        if let failure = shortcutFailures[0] {
                            ShortcutFailureLabel(failure: failure)
                        }
                    }
                }
            } footer: {
                Text("只打开工作台，不读取选区或自动生成；是否清空内容可在“通用”中设置。")
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("场景快捷操作").font(.headline)
                SettingsCard {
                    ForEach(0..<ShortcutConfiguration.actionLimit, id: \.self) { index in
                        if index > 0 { SettingsDivider() }
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 18)
                                Picker("场景", selection: sceneBinding(for: index)) {
                                    Text("未绑定场景").tag(WritingScene.ID?.none)
                                    ForEach(state.scenes) { scene in
                                        Text(scene.name).tag(WritingScene.ID?.some(scene.id))
                                    }
                                }
                                .labelsHidden()
                                .frame(minWidth: 150, maxWidth: 190)
                                ShortcutRecorder(shortcut: shortcutBinding(for: index))
                                Spacer()
                                if shortcuts.actions[index].shortcut != nil || shortcuts.actions[index].sceneID != nil {
                                    Button("清除", systemImage: "xmark.circle.fill") {
                                        shortcuts.actions[index] = SceneShortcut()
                                    }
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.borderless)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24, height: 24)
                                    .contentShape(Rectangle())
                                }
                            }
                            if let failure = shortcutFailures[UInt32(index + 1)] {
                                ShortcutFailureLabel(failure: failure)
                                    .padding(.leading, 30)
                            }
                        }
                        .padding(.horizontal, Space.md)
                        .padding(.vertical, Space.sm)
                    }
                } footer: {
                    Text("最多配置 5 个。选中文字后按下场景快捷键，将直接读取选区并使用对应场景生成。只有同时选择场景和快捷键时才会生效。")
                }
            }
            if shortcuts.hasConflicts {
                HStack(spacing: Space.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color(nsColor: .systemOrange))
                        .accessibilityHidden(true)
                    Text("快捷键存在重复，请修改后才能保存并生效。")
                        .font(.callout)
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func sceneBinding(for index: Int) -> Binding<WritingScene.ID?> {
        Binding(
            get: { shortcuts.actions[index].sceneID },
            set: { shortcuts.actions[index].sceneID = $0 }
        )
    }

    private func shortcutBinding(for index: Int) -> Binding<ShortcutPreference?> {
        Binding(
            get: { shortcuts.actions[index].shortcut },
            set: { shortcuts.actions[index].shortcut = $0 }
        )
    }

    private var workspaceShortcutBinding: Binding<ShortcutPreference?> {
        Binding(
            get: { shortcuts.workspace },
            set: { if let shortcut = $0 { shortcuts.workspace = shortcut } }
        )
    }

    private var sceneSettings: some View {
        VStack(alignment: .leading, spacing: 22) {
            SettingsCard {
                SettingsRow(symbol: "tag", title: "场景名称") {
                    SettingsTextField(label: "场景名称", text: $sceneName, prompt: "例如：客服回复")
                }
                SettingsDivider()
                SettingsRow(symbol: "text.bubble", title: "简短说明") {
                    SettingsTextField(label: "简短说明", text: $sceneSubtitle, prompt: "礼貌、清晰、简洁")
                }
                SettingsDivider()
                SettingsRow(symbol: "slider.horizontal.3", title: "场景规则") {
                    TextField("描述希望模型如何优化文本", text: $sceneInstruction, axis: .vertical)
                        .textFieldStyle(.plain)
                        .accessibilityLabel("场景规则")
                        .lineLimit(4...6)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.field))
                        .overlay(RoundedRectangle(cornerRadius: Radius.field).stroke(Tone.hairline))
                        .frame(minWidth: 240, maxWidth: 360)
                }
                SettingsDivider()
                HStack {
                    Spacer()
                    if editingSceneID != nil {
                        Button("取消") { resetSceneForm() }
                        Button("删除场景", role: .destructive) {
                            guard let editingSceneID,
                                  let scene = state.scenes.first(where: { $0.id == editingSceneID }) else { return }
                            pendingSceneDeletion = scene
                        }
                        .foregroundStyle(.red)
                    }
                    Button(editingSceneID == nil ? "添加场景" : "保存修改") {
                        if let editingSceneID {
                            state.updateScene(id: editingSceneID, name: sceneName, subtitle: sceneSubtitle, instruction: sceneInstruction)
                        } else {
                            state.addScene(name: sceneName, subtitle: sceneSubtitle, instruction: sceneInstruction)
                        }
                        resetSceneForm()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sceneName.trimmingCharacters(in: .whitespaces).isEmpty || sceneInstruction.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(14)
            } footer: {
                Text(editingSceneID == nil ? "将常用的写作要求保存为场景，即可在工作台中一键使用。" : "正在编辑场景，保存后会同步更新工作台。")
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("已有场景").font(.headline)
                SettingsCard {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8) {
                        ForEach(state.scenes) { scene in
                            Button {
                                selectSceneForEditing(scene)
                            } label: {
                                Text(scene.name)
                                    .font(.body)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, Space.sm)
                                    .background(
                                        editingSceneID == scene.id ? Tone.accentSoft : Tone.wash,
                                        in: RoundedRectangle(cornerRadius: Radius.well)
                                    )
                                    .overlay {
                                        if editingSceneID == scene.id {
                                            RoundedRectangle(cornerRadius: Radius.well).stroke(Tone.accentBorder)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(editingSceneID == scene.id ? Color.accentColor : Color.primary)
                            .accessibilityLabel("编辑场景：\(scene.name)")
                            .accessibilityAddTraits(editingSceneID == scene.id ? .isSelected : [])
                            .help(scene.name)
                        }
                    }
                    .padding(10)
                }
                Text("点击场景即可回填上方表单并修改。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
        }
        .alert(
            "删除场景？",
            isPresented: Binding(
                get: { pendingSceneDeletion != nil },
                set: { if !$0 { pendingSceneDeletion = nil } }
            ),
            presenting: pendingSceneDeletion
        ) { scene in
            Button("删除「\(scene.name)」", role: .destructive) {
                state.deleteScene(id: scene.id)
                pendingSceneDeletion = nil
                resetSceneForm()
            }
            Button("取消", role: .cancel) {
                pendingSceneDeletion = nil
            }
        } message: { _ in
            Text("场景规则和关联快捷键都会被清除，且无法撤销。")
        }
    }

    private func selectSceneForEditing(_ scene: WritingScene) {
        editingSceneID = scene.id
        sceneName = scene.name
        sceneSubtitle = scene.subtitle
        sceneInstruction = scene.instruction
    }

    private func resetSceneForm() {
        editingSceneID = nil
        sceneName = ""
        sceneSubtitle = ""
        sceneInstruction = ""
    }
}

private struct SettingsCard<Content: View, Footer: View>: View {
    @ViewBuilder let content: Content
    @ViewBuilder let footer: Footer
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(spacing: 0) { content }
                .background(Tone.wash, in: RoundedRectangle(cornerRadius: Radius.card))
                .overlay(RoundedRectangle(cornerRadius: Radius.card).stroke(Tone.hairline))
            footer.font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
        }
    }
}

private extension SettingsCard where Footer == EmptyView {
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.footer = EmptyView()
    }
}

private struct SettingsRow<Accessory: View>: View {
    let symbol: String
    let title: String
    @ViewBuilder let accessory: Accessory
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 22)
                .accessibilityHidden(true)
            Text(title)
                .font(.body)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 16)
            accessory
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}

private struct ShortcutFailureLabel: View {
    let failure: ShortcutRegistrationFailure

    var body: some View {
        Label(failure.message, systemImage: "exclamationmark.triangle.fill")
            .font(.caption)
            .foregroundStyle(Color(nsColor: .systemOrange))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 230, alignment: .leading)
    }
}

private struct SettingsDivider: View {
    var body: some View { Divider().padding(.leading, 48) }
}

private struct SettingsTextField: View {
    let label: String
    @Binding var text: String
    let prompt: String
    var body: some View {
        TextField("", text: $text, prompt: Text(prompt)).textFieldStyle(.plain)
            .accessibilityLabel(label)
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.field))
            .overlay(RoundedRectangle(cornerRadius: Radius.field).stroke(Tone.hairline))
            .frame(minWidth: 240, maxWidth: 360)
    }
}

private struct ShortcutRecorder: View {
    @Binding var shortcut: ShortcutPreference?
    @State private var monitor: Any?
    @State private var isRecording = false

    var body: some View {
        Button(shortcut?.display ?? "未设置") { isRecording = true }
            .monospaced().frame(minWidth: 132, idealWidth: 150, maxWidth: 170).padding(.vertical, 7)
            .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.field))
            .overlay(RoundedRectangle(cornerRadius: Radius.field).stroke(Tone.hairline))
            .help("点击后按下包含 Command 或 Control 的组合键")
            .accessibilityLabel("快捷键")
            .accessibilityValue(shortcut?.display ?? "未设置")
            .accessibilityHint("点击后录制新的快捷键，按 Escape 取消")
            .popover(isPresented: $isRecording, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("按下新的快捷键").font(.headline)
                    Text("组合键需要包含 ⌘ 或 ⌃。按 Esc 取消。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: Space.sm) {
                        Image(systemName: "keyboard")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        Text("等待按键…")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("取消") { isRecording = false }
                            .controlSize(.small)
                    }
                }
                .padding(16)
                .frame(width: 250)
                .onAppear(perform: startRecording)
                .onDisappear(perform: stopRecording)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                    isRecording = false
                }
            }
    }

    private func startRecording() {
        stopRecording()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                isRecording = false
                return nil
            }
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard modifiers.contains(.command) || modifiers.contains(.control) else { return nil }
            var value: UInt32 = 0
            if modifiers.contains(.command) { value |= UInt32(cmdKey) }
            if modifiers.contains(.shift) { value |= UInt32(shiftKey) }
            if modifiers.contains(.option) { value |= UInt32(optionKey) }
            if modifiers.contains(.control) { value |= UInt32(controlKey) }
            shortcut = ShortcutPreference(keyCode: UInt32(event.keyCode), modifiers: value)
            isRecording = false
            return nil
        }
    }

    private func stopRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
