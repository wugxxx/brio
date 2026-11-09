import SwiftUI
import Carbon.HIToolbox
import ApplicationServices

private enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "通用"
    case provider = "AI 服务"
    case shortcuts = "快捷键"
    case scenes = "场景"
    var id: Self { self }
    var symbol: String {
        switch self {
        case .general: "gearshape"
        case .provider: "sparkles"
        case .shortcuts: "keyboard"
        case .scenes: "square.grid.2x2"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @State private var tab: SettingsTab = .general
    @State private var hoveredTab: SettingsTab?
    @State private var baseURL = ""
    @State private var model = ""
    @State private var apiKey = ""
    @State private var showsAPIKey = false
    @State private var shortcut = ShortcutPreference.load()
    @State private var sceneName = ""
    @State private var sceneSubtitle = ""
    @State private var sceneInstruction = ""
    @State private var editingSceneID: WritingScene.ID?
    @State private var saved = false
    @State private var accessibilityGranted = AXIsProcessTrusted()

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            ScrollView {
                content.padding(26).frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 760, height: 540)
        .onAppear {
            let settings = ProviderSettings()
            baseURL = settings.baseURL
            model = settings.model
            apiKey = settings.apiKey
        }
        .onChange(of: shortcut) { _, value in
            value.save()
            HotKeyManager.shared.register(value)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 9) {
                Image(systemName: "sparkles").font(.system(size: 18, weight: .semibold)).foregroundStyle(.tint)
                Text("Brio").font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 18).padding(.top, 42).padding(.bottom, 24)
            ForEach(SettingsTab.allCases) { item in
                Button { tab = item } label: {
                    Label(item.rawValue, systemImage: item.symbol)
                        .font(.system(size: 14, weight: tab == item ? .medium : .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .background(
                            tab == item
                                ? Color.primary.opacity(0.075)
                                : Color.primary.opacity(hoveredTab == item ? 0.045 : 0),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .onHover { hovering in
                    if hovering {
                        hoveredTab = item
                    } else if hoveredTab == item {
                        hoveredTab = nil
                    }
                }
                .foregroundStyle(tab == item ? Color.primary : Color.secondary)
                .padding(.horizontal, 10)
            }
            Spacer()
            Text("让表达恰如其分").font(.caption).foregroundStyle(.tertiary)
                .padding(.horizontal, 24).padding(.bottom, 22)
        }
        .frame(width: 190)
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
            SettingsRow(symbol: "lock.shield", title: "本地配置") {
                Text("仅保存在此 Mac").font(.callout).foregroundStyle(.secondary)
            }
        } footer: {
            Text("文本仅在生成时发送给你配置的 AI 服务。读取和替换选区需要辅助功能权限。")
        }
    }

    private var providerSettings: some View {
        SettingsCard {
            SettingsRow(symbol: "network", title: "服务商") {
                Text("OpenAI 兼容").font(.callout).foregroundStyle(.secondary)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
            }
            SettingsDivider()
            SettingsRow(symbol: "link", title: "Base URL") { SettingsTextField(text: $baseURL, prompt: "https://api.openai.com/v1") }
            SettingsDivider()
            SettingsRow(symbol: "key", title: "API Key") {
                HStack(spacing: 4) {
                    Group {
                        if showsAPIKey { TextField("", text: $apiKey, prompt: Text("sk-...")) }
                        else { SecureField("", text: $apiKey) }
                    }
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.08)))
                    Button(showsAPIKey ? "隐藏 Key" : "显示 Key", systemImage: showsAPIKey ? "eye.slash" : "eye") { showsAPIKey.toggle() }
                        .labelStyle(.iconOnly).buttonStyle(.borderless).foregroundStyle(.secondary)
                        .frame(width: 28)
                }
                .frame(width: 310)
            }
            SettingsDivider()
            SettingsRow(symbol: "cpu", title: "模型") { SettingsTextField(text: $model, prompt: "模型 ID") }
            SettingsDivider()
            HStack {
                if saved { Label("已保存", systemImage: "checkmark.circle.fill").font(.callout).foregroundStyle(.green) }
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
        SettingsCard {
            SettingsRow(symbol: "text.badge.checkmark", title: "润色选中文本") { ShortcutRecorder(shortcut: $shortcut) }
        } footer: {
            Text("选中文字后，在任意应用中按下快捷键即可唤起 Brio。点击快捷键按钮后，按下新的组合键即可修改。")
        }
    }

    private var sceneSettings: some View {
        VStack(alignment: .leading, spacing: 22) {
            SettingsCard {
                SettingsRow(symbol: "tag", title: "场景名称") { SettingsTextField(text: $sceneName, prompt: "例如：客服回复") }
                SettingsDivider()
                SettingsRow(symbol: "text.bubble", title: "简短说明") { SettingsTextField(text: $sceneSubtitle, prompt: "礼貌、清晰、简洁") }
                SettingsDivider()
                SettingsRow(symbol: "slider.horizontal.3", title: "场景规则") {
                    TextField("描述希望模型如何优化文本", text: $sceneInstruction, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(4...6)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.08)))
                        .frame(width: 310)
                }
                SettingsDivider()
                HStack {
                    Spacer()
                    if editingSceneID != nil {
                        Button("取消") { resetSceneForm() }
                        Button("删除场景", role: .destructive) {
                            guard let editingSceneID else { return }
                            state.deleteScene(id: editingSceneID)
                            resetSceneForm()
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
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        editingSceneID == scene.id ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.025),
                                        in: RoundedRectangle(cornerRadius: 7)
                                    )
                                    .overlay {
                                        if editingSceneID == scene.id {
                                            RoundedRectangle(cornerRadius: 7).stroke(Color.accentColor.opacity(0.35))
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(editingSceneID == scene.id ? Color.accentColor : Color.primary)
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
                .background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.055)))
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
            Image(systemName: symbol).font(.system(size: 16)).foregroundStyle(.secondary).frame(width: 22)
            Text(title).font(.system(size: 14))
            Spacer(minLength: 16)
            accessory
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}

private struct SettingsDivider: View {
    var body: some View { Divider().padding(.leading, 48) }
}

private struct SettingsTextField: View {
    @Binding var text: String
    let prompt: String
    var body: some View {
        TextField("", text: $text, prompt: Text(prompt)).textFieldStyle(.plain)
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.08)))
            .frame(width: 310)
    }
}

private struct ShortcutRecorder: View {
    @Binding var shortcut: ShortcutPreference
    @State private var monitor: Any?
    @State private var recording = false
    var body: some View {
        Button(recording ? "按下组合键…" : shortcut.display) {
            recording = true
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                guard modifiers.contains(.command) || modifiers.contains(.control) else { return nil }
                var value: UInt32 = 0
                if modifiers.contains(.command) { value |= UInt32(cmdKey) }
                if modifiers.contains(.shift) { value |= UInt32(shiftKey) }
                if modifiers.contains(.option) { value |= UInt32(optionKey) }
                if modifiers.contains(.control) { value |= UInt32(controlKey) }
                shortcut = ShortcutPreference(keyCode: UInt32(event.keyCode), modifiers: value)
                stop()
                return nil
            }
        }
        .monospaced().frame(width: 150).padding(.vertical, 7)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.08)))
        .onDisappear(perform: stop)
    }
    private func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        recording = false
    }
}
