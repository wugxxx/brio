import SwiftUI
import AppKit
import Carbon.HIToolbox
import ApplicationServices
import Foundation

enum SettingsTab: String, CaseIterable, Identifiable, Hashable {
    case general
    case provider
    case shortcuts
    case scenes

    var id: Self { self }

    var navTitle: String {
        switch self {
        case .general: "通用"
        case .provider: "AI 服务"
        case .shortcuts: "快捷键"
        case .scenes: "场景设定"
        }
    }

    var symbol: String {
        switch self {
        case .general: "gearshape"
        case .provider: "network"
        case .shortcuts: "keyboard"
        case .scenes: "square.grid.2x2"
        }
    }

    var shortcutKey: KeyEquivalent {
        switch self {
        case .scenes: "2"
        case .shortcuts: "3"
        case .provider: "4"
        case .general: "5"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue
    private let sceneInstructionLimit = 2000

    @State private var tab: SettingsTab = .general
    @State private var baseURL = ""
    @State private var model = ""
    @State private var apiKey = ""
    @State private var showsAPIKey = false
    @State private var providerSaved = false
    @State private var providerSaveResetTask: Task<Void, Never>?
    @State private var shortcuts = ShortcutConfiguration.load()
    @State private var sceneName = ""
    @State private var sceneSubtitle = ""
    @State private var sceneInstruction = ""
    @State private var editingSceneID: WritingScene.ID?
    @State private var pendingSceneDeletion: WritingScene?
    @State private var shortcutFailures: [UInt32: ShortcutRegistrationFailure] = [:]
    @State private var accessibilityGranted = AXIsProcessTrusted()
    @State private var openBehavior: WorkspaceOpenBehavior = .preserve

    private var selectedAppearance: AppAppearance {
        AppAppearance(rawValue: appearance) ?? .system
    }

    private var effectiveScheme: ColorScheme {
        selectedAppearance.colorScheme ?? colorScheme
    }

    private var palette: SettingsPalette {
        SettingsPalette(isDark: effectiveScheme == .dark)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            mainPanel
        }
        .background(palette.canvas)
        .environment(\.settingsPalette, palette)
        .environment(\.colorScheme, effectiveScheme)
        .preferredColorScheme(selectedAppearance.colorScheme)
        .frame(minWidth: 900, idealWidth: 980, minHeight: 620, idealHeight: 700)
        .onAppear(perform: loadState)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            accessibilityGranted = AXIsProcessTrusted()
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
                shortcuts = ShortcutConfiguration.load()
                shortcutFailures = HotKeyManager.shared.register(shortcuts)
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

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            brand
                .padding(.horizontal, 14)
                .padding(.top, 48)
                .padding(.bottom, 24)

            Text("首选项")
                .font(SettingsType.micro)
                .tracking(0.9)
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
                .padding(.horizontal, 18)
                .padding(.bottom, 8)

            VStack(spacing: 3) {
                ForEach([SettingsTab.general, .provider, .shortcuts, .scenes]) { item in
                    SettingsNavRow(
                        symbol: item.symbol,
                        title: item.navTitle,
                        selected: tab == item,
                        tint: tab == item ? palette.accentText : palette.textSecondary
                    ) {
                        tab = item
                    }
                    .keyboardShortcut(item.shortcutKey, modifiers: .command)
                }
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 24)

            SettingsThemeControl(
                appearance: selectedAppearance,
                isDark: effectiveScheme == .dark,
                toggle: toggleAppearance,
                select: { appearance = $0.rawValue }
            )
            .padding(.horizontal, 10)
            .padding(.bottom, 16)
        }
        .frame(width: 220)
        .frame(maxHeight: .infinity)
        .background(
            ZStack {
                palette.sidebar
                LinearGradient(
                    colors: [
                        palette.accent.opacity(palette.isDark ? 0.045 : 0.025),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(palette.hairline)
                .frame(width: 1)
        }
    }

    private var brand: some View {
        HStack(spacing: 10) {
            BrioAppIcon(size: 34)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Brio")
                        .font(.system(size: 17, weight: .semibold))
                        .tracking(-0.2)
                        .foregroundStyle(palette.textPrimary)
                    Text("v\(appVersion)")
                        .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.accentText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(palette.accentSoft, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .strokeBorder(palette.accent.opacity(0.24), lineWidth: 1)
                        )
                }
                Text("让表达恰如其分")
                    .font(.system(size: 11))
                    .foregroundStyle(palette.textMuted)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var mainPanel: some View {
        VStack(spacing: 0) {
            ScrollView {
                pageContent
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 26)
                    .frame(maxWidth: 980, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.automatic)
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                palette.canvas
                palette.pageGlow
            }
        )
    }

    @ViewBuilder
    private var pageContent: some View {
        switch tab {
        case .general: generalSettings
        case .provider: providerSettings
        case .shortcuts: shortcutSettings
        case .scenes: sceneSettings
        }
    }

    private var generalSettings: some View {
        VStack(spacing: 18) {
            SettingsSection(
                symbol: "checkmark.shield",
                title: "系统权限与辅助功能",
                meta: "本机权限",
                tint: palette.accentText
            ) {
                SettingsInsetRow(
                    symbol: "accessibility",
                    title: "辅助功能权限 (Accessibility API)",
                    tint: palette.accentText
                ) {
                    HStack(spacing: 8) {
                        SettingsStatusPill(
                            text: accessibilityGranted ? "已授权" : "未授权",
                            color: accessibilityGranted ? palette.success : palette.warning,
                            showsDot: false
                        )
                        Button(accessibilityGranted ? "系统设置" : "去授权") {
                            if accessibilityGranted {
                                state.openAccessibilitySettings()
                            } else {
                                AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
                            }
                        }
                        .buttonStyle(SettingsGhostButtonStyle())
                    }
                }
            }

            SettingsSection(
                symbol: "slider.horizontal.3",
                title: "交互行为与偏好",
                meta: "打开行为",
                tint: palette.signal
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        SettingsIconTile(symbol: "clock.arrow.circlepath", tint: palette.textSecondary)
                        Text("再次打开工作台时")
                            .font(SettingsType.rowTitle())
                            .foregroundStyle(palette.textPrimary)
                        Spacer(minLength: 12)
                        Text("呼出输入界面时的默认状态")
                            .font(SettingsType.caption)
                            .foregroundStyle(palette.textMuted)
                    }

                    SettingsSegmentedControl(
                        options: WorkspaceOpenBehavior.allCases.map {
                            SettingsSegmentOption(value: $0, title: $0.title, symbol: $0.symbol)
                        },
                        selection: openBehaviorBinding
                    )
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(palette.sunken.opacity(palette.isDark ? 0.66 : 0.62))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(palette.hairline, lineWidth: 1)
                )
            }
        }
    }

    private var openBehaviorBinding: Binding<WorkspaceOpenBehavior> {
        Binding(
            get: { openBehavior },
            set: { value in
                openBehavior = value
                WorkspacePreferences().saveOpenBehavior(value)
            }
        )
    }

    private var providerSettings: some View {
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.accentText)
                    .frame(width: 20)
                    .accessibilityHidden(true)
                Text("模型端点设置")
                    .font(SettingsType.sectionTitle())
                    .tracking(-0.12)
                    .foregroundStyle(palette.textPrimary)
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 15)
            .padding(.bottom, 12)

            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)

            VStack(spacing: 8) {
                SettingsFormRow(symbol: "globe", title: "服务商类型") {
                    SettingsFieldShell {
                        Text("OpenAI 兼容")
                            .font(SettingsType.body)
                            .foregroundStyle(palette.textPrimary)
                        Spacer(minLength: 8)
                        Text("Chat Completions")
                            .font(SettingsType.monoMicro)
                            .foregroundStyle(palette.textMuted)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(palette.controlFill, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(palette.border, lineWidth: 1)
                            )
                    }
                }

                SettingsFormRow(symbol: "link", title: "Base URL") {
                    SettingsTextField(
                        text: $baseURL,
                        prompt: "https://api.openai.com/v1",
                        leadingText: "POST",
                        monospaced: true
                    )
                }

                SettingsFormRow(symbol: "key", title: "API Key") {
                    SettingsSecretField(
                        text: $apiKey,
                        isRevealed: $showsAPIKey,
                        prompt: "输入密钥或 Token"
                    )
                }

                SettingsFormRow(symbol: "cpu", title: "模型名称 (Model)") {
                    SettingsTextField(
                        text: $model,
                        prompt: "如 deepseek-chat、gpt-4o",
                        monospaced: true
                    )
                }
            }
            .padding(12)

            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)
                .padding(.horizontal, 16)

            HStack(spacing: 10) {
                Spacer(minLength: 12)

                if providerSaved {
                    Label("已保存", systemImage: "checkmark.circle.fill")
                        .font(SettingsType.caption)
                        .foregroundStyle(palette.success)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

                Button("取消") {
                    loadProviderSettings()
                    providerSaved = false
                }
                .buttonStyle(SettingsGhostButtonStyle())

                Button {
                    saveProviderSettings()
                } label: {
                    Label("保存设置", systemImage: "checkmark")
                }
                .buttonStyle(SettingsPrimaryButtonStyle())
                .disabled(
                    baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.surface.opacity(palette.isDark ? 0.92 : 1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(palette.isDark ? 0.22 : 0.04), radius: 12, y: 5)
        .onChange(of: baseURL) { _, _ in providerDidChange() }
        .onChange(of: model) { _, _ in providerDidChange() }
        .onChange(of: apiKey) { _, _ in providerDidChange() }
    }

    private var shortcutSettings: some View {
        VStack(spacing: 18) {
            SettingsSection(
                symbol: "keyboard",
                title: "全局唤起",
                tint: palette.accentText
            ) {
                HStack(spacing: 12) {
                    SettingsRowLabel(
                        symbol: "macwindow",
                        title: "打开工作台",
                        caption: "快速唤出主输入悬浮框",
                        tint: palette.accentText
                    )
                    Spacer(minLength: 16)
                    ShortcutRecorder(shortcut: workspaceShortcutBinding, style: .keycap)
                    SettingsIconButton(
                        symbol: "arrow.counterclockwise",
                        help: "恢复系统推荐快捷键"
                    ) {
                        shortcuts.workspace = ShortcutPreference()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(palette.sunken.opacity(palette.isDark ? 0.66 : 0.62))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(palette.hairline, lineWidth: 1)
                )

                if let failure = shortcutFailures[0] {
                    ShortcutFailureLabel(failure: failure)
                        .padding(.horizontal, 8)
                }
            }

            SettingsSection(
                symbol: "square.grid.2x2",
                title: "场景快捷操作",
                meta: "已启用 \(enabledShortcutCount) / \(ShortcutConfiguration.actionLimit) 个槽位",
                tint: palette.signal
            ) {
                ForEach(0..<ShortcutConfiguration.actionLimit, id: \.self) { index in
                    sceneShortcutRow(index: index)
                    if index < ShortcutConfiguration.actionLimit - 1 {
                        Rectangle()
                            .fill(palette.hairline)
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                    }
                }
            }

            if shortcuts.hasConflicts {
                SettingsNotice(
                    text: "快捷键存在重复，尚未保存。请修改冲突的按键后再离开设置。",
                    symbol: "exclamationmark.triangle.fill",
                    tint: palette.warning
                )
            }

            SettingsNotice(
                text: "最多配置 \(ShortcutConfiguration.actionLimit) 个。在任意应用中选中文字后按下场景快捷键，将读取划选文字并调用对应场景生成；只有同时选择场景和快捷键时才会生效。",
                symbol: "info.circle",
                tint: palette.signal
            )
        }
        .onChange(of: shortcuts) { _, value in
            guard !value.hasConflicts else { return }
            saveShortcuts()
        }
    }

    private func sceneShortcutRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 11) {
                Text("\(index + 1)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(palette.textMuted)
                    .frame(width: 20, height: 20)

                Menu {
                    Button("未绑定场景") {
                        shortcuts.actions[index].sceneID = nil
                    }
                    Divider()
                    ForEach(state.scenes) { scene in
                        Button(scene.name) {
                            shortcuts.actions[index].sceneID = scene.id
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(sceneName(for: shortcuts.actions[index].sceneID) ?? "未绑定场景")
                            .font(SettingsType.body)
                            .foregroundStyle(
                                shortcuts.actions[index].sceneID == nil ? palette.textMuted : palette.textPrimary
                            )
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(palette.textMuted)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(palette.sunken.opacity(palette.isDark ? 0.78 : 0.58))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(palette.border, lineWidth: 1)
                    )
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 220, alignment: .leading)

                Spacer(minLength: 8)

                ShortcutRecorder(shortcut: shortcutBinding(for: index), style: .keycap)

                if shortcuts.actions[index].shortcut != nil || shortcuts.actions[index].sceneID != nil {
                    SettingsIconButton(
                        symbol: "xmark",
                        help: "清除映射"
                    ) {
                        shortcuts.actions[index] = SceneShortcut()
                    }
                } else {
                    Color.clear
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.surface.opacity(palette.isDark ? 0.18 : 0.42))
            )

            if let failure = shortcutFailures[UInt32(index + 1)] {
                ShortcutFailureLabel(failure: failure)
                    .padding(.leading, 31)
            }
        }
    }

    private var sceneSettings: some View {
        VStack(spacing: 18) {
            sceneEditor

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("已有场景")
                        .font(SettingsType.sectionTitle())
                        .foregroundStyle(palette.textPrimary)
                    Text("\(state.scenes.count)")
                        .font(SettingsType.monoMicro)
                        .foregroundStyle(palette.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(palette.controlFill, in: Capsule())
                        .overlay(Capsule().strokeBorder(palette.border, lineWidth: 1))
                    Spacer()
                    Text("点击卡片可快速载入编辑")
                        .font(SettingsType.caption)
                        .foregroundStyle(palette.textMuted)
                }
                .padding(.horizontal, 2)

                if state.scenes.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(palette.textMuted)
                        Text("还没有自定义场景")
                            .font(SettingsType.body)
                            .foregroundStyle(palette.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 34)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.surface.opacity(palette.isDark ? 0.72 : 0.84))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(palette.hairline, lineWidth: 1)
                    )
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 190), spacing: 10)],
                        spacing: 10
                    ) {
                        ForEach(state.scenes) { scene in
                            SceneCard(
                                scene: scene,
                                selected: editingSceneID == scene.id,
                                shortcut: shortcutLabel(for: scene.id)
                            ) {
                                selectSceneForEditing(scene)
                            }
                        }
                    }
                }
            }
        }
    }

    private var sceneEditor: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                SettingsFormRow(symbol: "tag", title: "场景名称", labelWidth: 106) {
                    SettingsTextField(text: $sceneName, prompt: "给场景起一个简洁的名字")
                }

                SettingsFormRow(symbol: "text.bubble", title: "简短说明", labelWidth: 106) {
                    SettingsTextField(text: $sceneSubtitle, prompt: "在呼出浮窗中展示的辅助提示")
                }

                HStack(alignment: .top, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(palette.textMuted)
                            .frame(width: 16)
                            .padding(.top, 10)
                            .accessibilityHidden(true)
                        Text("场景规则")
                            .font(SettingsType.rowTitle())
                            .foregroundStyle(palette.textSecondary)
                            .padding(.top, 9)
                    }
                    .frame(width: 106, alignment: .leading)

                    VStack(alignment: .leading, spacing: 7) {
                        SettingsTextEditor(
                            text: $sceneInstruction,
                            prompt: "输入此场景的模型指令…",
                            minHeight: 118
                        )
                        HStack(spacing: 8) {
                            Text("场景规则会直接作为模型指令。")
                                .font(SettingsType.caption)
                                .foregroundStyle(palette.textMuted)
                            Spacer()
                            Text("\(sceneInstruction.count) / \(sceneInstructionLimit) 字")
                                .font(.system(size: 10.5, design: .monospaced))
                                .monospacedDigit()
                                .foregroundStyle(
                                    sceneInstruction.count > sceneInstructionLimit
                                        ? palette.warning
                                        : palette.textMuted
                                )
                        }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 5)
            }
            .padding(16)

            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)
                .padding(.horizontal, 16)

            HStack(spacing: 10) {
                Spacer(minLength: 12)

                if editingSceneID != nil {
                    Button {
                        guard let editingSceneID,
                              let scene = state.scenes.first(where: { $0.id == editingSceneID }) else { return }
                        pendingSceneDeletion = scene
                    } label: {
                        Label("删除场景", systemImage: "trash")
                    }
                    .buttonStyle(SettingsDestructiveButtonStyle())
                }

                Button("取消") {
                    resetSceneForm()
                }
                .buttonStyle(SettingsGhostButtonStyle())
                .disabled(sceneName.isEmpty && sceneSubtitle.isEmpty && sceneInstruction.isEmpty && editingSceneID == nil)

                Button {
                    saveScene()
                } label: {
                    Label(editingSceneID == nil ? "添加场景" : "保存修改", systemImage: "checkmark")
                }
                .buttonStyle(SettingsPrimaryButtonStyle())
                .disabled(
                    sceneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    sceneInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    sceneInstruction.count > sceneInstructionLimit
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.surface.opacity(palette.isDark ? 0.94 : 1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(palette.isDark ? 0.20 : 0.04), radius: 12, y: 5)
    }

    private var enabledShortcutCount: Int {
        shortcuts.actions.filter { $0.sceneID != nil && $0.shortcut != nil }.count
    }

    private func loadState() {
        loadProviderSettings()
        let loaded = ShortcutConfiguration.load()
        shortcuts = loaded
        shortcutFailures = HotKeyManager.shared.register(loaded)
        openBehavior = WorkspacePreferences().openBehavior
        accessibilityGranted = AXIsProcessTrusted()
    }

    private func loadProviderSettings() {
        let settings = ProviderSettings()
        baseURL = settings.baseURL
        model = settings.model
        apiKey = settings.apiKey
        showsAPIKey = false
    }

    private func providerDidChange() {
        providerSaveResetTask?.cancel()
        providerSaved = false
    }

    private func saveProviderSettings() {
        let settings = ProviderSettings()
        settings.save(baseURL: baseURL, model: model)
        settings.saveAPIKey(apiKey)
        providerSaved = true
        providerSaveResetTask?.cancel()
        providerSaveResetTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.4))
            guard !Task.isCancelled else { return }
            providerSaved = false
        }
    }

    private func saveShortcuts() {
        guard !shortcuts.hasConflicts else { return }
        shortcuts.save()
        shortcutFailures = HotKeyManager.shared.register(shortcuts)
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

    private func sceneName(for id: WritingScene.ID?) -> String? {
        guard let id, let scene = state.scenes.first(where: { $0.id == id }) else { return nil }
        return scene.name
    }

    private func shortcutLabel(for id: WritingScene.ID) -> String? {
        shortcuts.actions.first(where: { $0.sceneID == id })?.shortcut?.display
    }

    private func saveScene() {
        if let editingSceneID {
            state.updateScene(
                id: editingSceneID,
                name: sceneName,
                subtitle: sceneSubtitle,
                instruction: sceneInstruction
            )
        } else {
            state.addScene(name: sceneName, subtitle: sceneSubtitle, instruction: sceneInstruction)
        }
        resetSceneForm()
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

    private func toggleAppearance() {
        appearance = (effectiveScheme == .dark ? AppAppearance.light : .dark).rawValue
    }
}

private struct SettingsThemeControl: View {
    @Environment(\.settingsPalette) private var palette
    @State private var hovering = false

    let appearance: AppAppearance
    let isDark: Bool
    let toggle: () -> Void
    let select: (AppAppearance) -> Void

    private var detail: String {
        switch appearance {
        case .system: "跟随系统 · \(isDark ? "深色" : "浅色")"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)
                .padding(.horizontal, 2)

            Button(action: toggle) {
                HStack(spacing: 10) {
                    SettingsIconTile(
                        symbol: isDark ? "moon.stars.fill" : "sun.max.fill",
                        tint: isDark ? palette.accentText : palette.warning,
                        size: 28
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("外观")
                            .font(SettingsType.rowTitle())
                            .foregroundStyle(palette.textPrimary)
                        Text(detail)
                            .font(SettingsType.micro)
                            .foregroundStyle(palette.textMuted)
                    }
                    Spacer(minLength: 8)
                    SettingsThemeSwitch(isOn: isDark)
                }
                .padding(.horizontal, 8)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hovering ? palette.hover.opacity(palette.isDark ? 0.82 : 1) : .clear)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
            .help("切换到\(isDark ? "浅色" : "深色")模式，右键可选择跟随系统")
            .accessibilityLabel("外观")
            .accessibilityValue(detail)
            .accessibilityHint("切换到\(isDark ? "浅色" : "深色")模式")
            .contextMenu {
                ForEach(AppAppearance.allCases, id: \.self) { option in
                    Button {
                        select(option)
                    } label: {
                        Label(
                            option.title,
                            systemImage: appearance == option ? "checkmark" : option.symbol
                        )
                    }
                }
            }
        }
    }
}

private struct SettingsThemeSwitch: View {
    @Environment(\.settingsPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? palette.accent : palette.controlFill)
            Circle()
                .fill(isOn ? palette.onAccent : palette.textMuted)
                .frame(width: 14, height: 14)
                .padding(2)
        }
        .frame(width: 30, height: 18)
        .overlay(
            Capsule()
                .strokeBorder(isOn ? palette.accent.opacity(0.7) : palette.border, lineWidth: 1)
        )
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: isOn)
        .accessibilityHidden(true)
    }
}

private struct SettingsNavRow: View {
    @Environment(\.settingsPalette) private var palette
    @State private var hovering = false

    let symbol: String
    let title: String
    let selected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selected ? palette.accentText : (hovering ? palette.textPrimary : tint))
                    .frame(width: 17)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.system(size: 12.5, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? palette.textPrimary : (hovering ? palette.textPrimary : palette.textSecondary))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: 34)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        selected
                            ? palette.accentSoft
                            : (hovering ? palette.hover.opacity(palette.isDark ? 0.82 : 1) : .clear)
                    )
            )
            .overlay(alignment: .leading) {
                if selected {
                    Capsule()
                        .fill(palette.accent)
                        .frame(width: 2, height: 17)
                        .offset(x: -1)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct SceneCard: View {
    @Environment(\.settingsPalette) private var palette
    @State private var hovering = false

    let scene: WritingScene
    let selected: Bool
    let shortcut: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(selected ? palette.accent : palette.textMuted.opacity(0.45))
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                    Text(scene.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 6)
                    if let shortcut {
                        SettingsKbd(text: shortcut)
                    } else {
                        Text("未绑定")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(palette.textMuted)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(palette.controlFill, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .strokeBorder(palette.controlBorder, lineWidth: 1)
                            )
                    }
                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(palette.accentText)
                    }
                }

                Text(scene.subtitle.isEmpty ? "自定义场景" : scene.subtitle)
                    .font(SettingsType.caption)
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 82, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        selected
                            ? palette.accentSoft
                            : palette.surface.opacity(hovering ? (palette.isDark ? 0.88 : 1) : (palette.isDark ? 0.58 : 0.82))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        selected ? palette.accent.opacity(0.62) : (hovering ? palette.border : palette.hairline),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .accessibilityLabel("编辑场景：\(scene.name)")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .help(scene.name)
    }
}

private struct ShortcutFailureLabel: View {
    @Environment(\.settingsPalette) private var palette

    let failure: ShortcutRegistrationFailure

    var body: some View {
        Label(failure.message, systemImage: "exclamationmark.triangle.fill")
            .font(SettingsType.caption)
            .foregroundStyle(palette.warning)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private enum ShortcutRecorderStyle {
    case keycap
    case field
}

private struct ShortcutRecorder: View {
    @Environment(\.settingsPalette) private var palette
    @Binding var shortcut: ShortcutPreference?
    var style: ShortcutRecorderStyle = .field
    @State private var monitor: Any?
    @State private var isRecording = false

    var body: some View {
        Button {
            isRecording = true
        } label: {
            switch style {
            case .keycap:
                HStack(spacing: 5) {
                    if shortcut == nil {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    Text(shortcut?.display ?? "设置")
                }
                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(shortcut == nil ? palette.textMuted : palette.textPrimary)
                .padding(.horizontal, 7)
                .frame(minWidth: 38, minHeight: 24)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(palette.isDark ? 0.11 : 1),
                                    Color.white.opacity(palette.isDark ? 0.035 : 0.82)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(
                            isRecording
                                ? palette.accent.opacity(0.8)
                                : (palette.isDark ? Color.white.opacity(0.12) : palette.border),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(palette.isDark ? 0.32 : 0.08), radius: 1.5, y: 1)
            case .field:
                HStack(spacing: 7) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(palette.textMuted)
                    Text(shortcut?.display ?? "未设置")
                        .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(shortcut == nil ? palette.textMuted : palette.textPrimary)
                }
                .padding(.horizontal, 10)
                .frame(minWidth: 128, minHeight: 34)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(palette.controlFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(isRecording ? palette.accent.opacity(0.8) : palette.border, lineWidth: 1)
                )
            }
        }
        .buttonStyle(.plain)
        .help("点击后按下包含 Command 或 Control 的组合键")
        .accessibilityLabel("快捷键")
        .accessibilityValue(shortcut?.display ?? "未设置")
        .accessibilityHint("点击后录制新的快捷键，按 Escape 取消")
        .popover(isPresented: $isRecording, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                Text("按下新的快捷键")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("组合键需要包含 ⌘ 或 ⌃。按 Esc 取消。")
                    .font(SettingsType.caption)
                    .foregroundStyle(palette.textSecondary)
                HStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .foregroundStyle(palette.accentText)
                        .accessibilityHidden(true)
                    Text("等待按键…")
                        .font(SettingsType.body)
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Button("取消") { isRecording = false }
                        .buttonStyle(SettingsQuietButtonStyle())
                }
            }
            .padding(16)
            .frame(width: 260)
            .background(palette.surface)
            .onAppear(perform: startRecording)
            .onDisappear(perform: stopRecording)
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                isRecording = false
            }
        }
    }

    private func startRecording() {
        stopMonitoring()
        HotKeyManager.shared.unregister()
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
        stopMonitoring()
        HotKeyManager.shared.register(ShortcutConfiguration.load())
    }

    private func stopMonitoring() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
