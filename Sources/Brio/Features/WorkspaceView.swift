import AppKit
import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue
    @FocusState private var sourceFocused: Bool
    @FocusState private var followUpFocused: Bool
    @State private var showsSceneMenu = false

    private let panelShape = RoundedRectangle(cornerRadius: 16, style: .continuous)

    private var selectedAppearance: AppAppearance {
        AppAppearance(rawValue: appearance) ?? .system
    }

    private var effectiveScheme: ColorScheme {
        selectedAppearance.colorScheme ?? systemColorScheme
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            footer
        }
        .frame(minWidth: 480, idealWidth: 620, minHeight: 480)
        .background(PanelSurface())
        .clipShape(panelShape)
        .overlay(
            panelShape.strokeBorder(
                LinearGradient(
                    colors: [
                        Palette.panelEdgeTop,
                        Palette.panelEdgeMiddle,
                        Palette.panelEdgeBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1
            )
        )
        .padding(6)
        .environment(\.colorScheme, effectiveScheme)
        .preferredColorScheme(selectedAppearance.colorScheme)
        .onExitCommand { state.dismissPanel?() }
    }

    private var header: some View {
        HStack(spacing: 10) {
            BrioAppIcon(size: 28)
                .shadow(color: Palette.logoShadow, radius: 2, y: 1)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Brio")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(Palette.slate100)
                Text("让表达恰如其分")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.slate400)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 8)
            WindowControlButton(
                systemName: state.isPinned ? "pin.fill" : "pin",
                help: state.isPinned ? "取消固定，点击其他位置时自动关闭" : "固定窗口，点击其他位置时保持显示",
                tint: state.isPinned ? Palette.blue400 : Palette.slate400,
                hoverTint: state.isPinned ? Palette.blue300 : Palette.slate200,
                rotation: state.isPinned ? 0 : -45,
                action: state.togglePinned
            )
            WindowControlButton(
                systemName: "xmark",
                help: state.isProcessing ? "停止生成并关闭窗口" : "关闭窗口",
                hoverTint: Palette.rose300,
                hoverBackground: Palette.rose500.opacity(0.18),
                action: { state.dismissPanel?() }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Palette.headerWash)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Palette.hairline)
                .frame(height: 1)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sourceSection
                modeBar
                resultSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.automatic)
        .scrollBounceBehavior(.basedOnSize)
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.slate400)
                    .accessibilityHidden(true)
                Text("原文")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.slate300)
                Spacer(minLength: 8)
                Circle()
                    .fill(sourceStatusColor)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(sourceLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.slate400)
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)

            sourceField
        }
    }

    private var sourceField: some View {
        sourceTextField
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Palette.obsidian900.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        sourceFocused ? Palette.blue500.opacity(0.65) : Palette.fieldBorder,
                        lineWidth: 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Palette.blue500.opacity(0.20), lineWidth: 3)
                    .padding(-2)
                    .opacity(sourceFocused ? 1 : 0)
            )
            .shadow(color: Palette.fieldShadow, radius: 2, y: 1)
            .animation(.easeOut(duration: 0.15), value: sourceFocused)
    }

    private var sourceTextField: some View {
        TextField(
            "",
            text: $state.sourceText,
            prompt: Text("在此输入或粘贴需要润色或翻译的文本…").foregroundColor(Palette.slate500),
            axis: .vertical
        )
        .textFieldStyle(.plain)
        .font(.system(size: 13))
        .lineSpacing(5)
        .foregroundStyle(Palette.slate200)
        .lineLimit(4...7)
        .frame(minHeight: 86, alignment: .topLeading)
        .focused($sourceFocused)
        .accessibilityLabel("原文")
        .help("按 Enter 开始生成，Shift + Enter 换行")
        .onKeyPress(keys: [.return], phases: .down) { press in
            guard press.modifiers.isEmpty else { return .ignored }
            if hasSourceText && !state.isProcessing {
                state.generate()
            }
            return .handled
        }
        .disabled(state.isProcessing)
    }

    private var modeBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                sceneMenu
                Text(state.selectedScene.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.slate400)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .help(state.selectedScene.subtitle)
            }
            Spacer(minLength: 4)
            PrimaryActionButton(
                title: primaryActionTitle,
                keycap: state.isProcessing ? nil : "⌘⏎",
                action: primaryAction
            )
            .disabled(!state.isProcessing && !hasSourceText)
        }
        .padding(.vertical, 2)
    }

    private var sceneMenu: some View {
        Button {
            showsSceneMenu.toggle()
        } label: {
            HStack(spacing: 8) {
                Text(state.selectedScene.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Palette.slate400)
            }
            .foregroundStyle(Palette.slate200)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Palette.obsidian800.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Palette.fieldBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(state.isProcessing)
        .help(state.selectedScene.name)
        .accessibilityLabel("场景：\(state.selectedScene.name)")
        .popover(isPresented: $showsSceneMenu, arrowEdge: .bottom) {
            scenePicker
        }
    }

    private var scenePicker: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(state.scenes) { scene in
                SceneMenuRow(
                    scene: scene,
                    isSelected: scene.id == state.selectedScene.id
                ) {
                    state.select(scene)
                    showsSceneMenu = false
                }
            }
        }
        .padding(6)
        .frame(width: 164)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.obsidian850)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Palette.border, lineWidth: 1)
        )
        .preferredColorScheme(selectedAppearance.colorScheme)
    }

    @ViewBuilder
    private var resultSection: some View {
        if !state.resultText.isEmpty || state.isProcessing {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.blue400)
                        .accessibilityHidden(true)
                    Text(state.resultTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Palette.slate300)
                    Spacer(minLength: 8)
                    Text(state.isProcessing ? "生成中" : "已生成")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(Palette.slate400)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Palette.fill)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .strokeBorder(Palette.hairline, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 2)

                resultText
                    .font(.system(size: 13))
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Palette.obsidian900.opacity(0.92))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Palette.fieldBorder, lineWidth: 1)
                    )
                    .shadow(color: Palette.fieldShadow, radius: 2, y: 1)
            }
        }
    }

    @ViewBuilder
    private var resultText: some View {
        if state.isProcessing && !reduceMotion {
            TimelineView(.periodic(from: .now, by: 0.55)) { context in
                let isVisible = Int(context.date.timeIntervalSinceReferenceDate / 0.55).isMultiple(of: 2)
                animatedResultText(caretVisible: isVisible)
            }
        } else {
            animatedResultText(caretVisible: state.isProcessing)
        }
    }

    private func animatedResultText(caretVisible: Bool) -> Text {
        let body = state.resultText.isEmpty ? "正在生成" : state.resultText
        let bodyColor = state.resultText.isEmpty ? Palette.slate500 : Palette.slate200
        var text = Text(body).foregroundColor(bodyColor)
        if state.isProcessing {
            text = text
                + Text(" ▍").foregroundColor(caretVisible ? Palette.blue500 : Color.clear)
        }
        return text
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if let error = state.errorMessage {
                feedbackRow(error)
            } else if let status = state.statusMessage {
                statusRow(status)
            }

            if !state.resultText.isEmpty {
                HStack(spacing: 8) {
                    FooterActionButton(
                        title: "复制结果",
                        keycap: "⌘C",
                        variant: .secondary,
                        action: state.copyResult
                    )
                    FooterActionButton(
                        title: state.source == .manual ? "复制并关闭" : "替换原文",
                        variant: .primary,
                        action: closeAction
                    )
                    Spacer(minLength: 4)
                    IconActionButton(
                        systemName: "arrow.clockwise",
                        help: "重新生成",
                        showsBorderOnHover: true,
                        action: state.generate
                    )
                }
                .disabled(state.isProcessing)
            }

            followUpField
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Palette.obsidian900.opacity(0.62))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Palette.hairline)
                .frame(height: 1)
        }
    }

    private var followUpField: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left")
                .font(.system(size: 14))
                .foregroundStyle(Palette.slate500)
                .accessibilityHidden(true)
            TextField(
                "",
                text: $state.followUp,
                prompt: Text(followUpPrompt).foregroundColor(Palette.slate500)
            )
            .textFieldStyle(.plain)
            .font(.system(size: 12.5))
            .foregroundStyle(Palette.slate200)
            .focused($followUpFocused)
            .accessibilityLabel("继续调整")
            .disabled(!hasResult || state.isProcessing)
            .onSubmit {
                if canSubmitFollowUp { state.generate() }
            }
            IconActionButton(
                systemName: "arrow.up",
                help: "按调整要求生成",
                tint: canSubmitFollowUp ? Palette.blue400 : Palette.slate500,
                hoverTint: Palette.slate100,
                action: state.generate
            )
            .disabled(!canSubmitFollowUp)
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Palette.obsidian950.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    followUpFocused ? Palette.blue500.opacity(0.50) : Palette.fieldBorder,
                    lineWidth: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Palette.blue500.opacity(0.18), lineWidth: 3)
                .padding(-2)
                .opacity(followUpFocused ? 1 : 0)
        )
        .animation(.easeOut(duration: 0.15), value: followUpFocused)
    }

    private func feedbackRow(_ error: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(Palette.red)
                .accessibilityHidden(true)
            Text(error)
                .font(.system(size: 11))
                .foregroundStyle(Palette.slate200)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("错误：\(error)")
            Spacer(minLength: 4)
            if !state.isProviderConfigured {
                InlineButton(title: "打开设置") { state.openSettings?() }
            }
            if state.needsAccessibilityPermission {
                InlineButton(title: "系统设置") { state.openAccessibilitySettings() }
            }
            if hasSourceText {
                InlineButton(title: "重试") { state.generate() }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Palette.red.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Palette.red.opacity(0.20), lineWidth: 1)
        )
    }

    private func statusRow(_ status: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Palette.emerald500)
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)
            Text(status)
                .font(.system(size: 11))
                .foregroundStyle(Palette.slate400)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(status)
    }

    private var primaryActionTitle: String {
        if state.isProcessing { return "停止" }
        return state.selectedScene.isTranslation ? "开始翻译" : "开始生成"
    }

    private func primaryAction() {
        if state.isProcessing {
            state.stop()
        } else {
            state.generate()
        }
    }

    private func closeAction() {
        if state.source == .manual {
            state.copyResult()
            state.dismissPanel?()
        } else {
            state.replaceSelection()
        }
    }

    private var hasResult: Bool {
        !state.resultText.isEmpty
    }

    private var hasSourceText: Bool {
        !state.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var followUpPrompt: String {
        if state.isProcessing { return "正在生成…" }
        if !hasResult { return "生成结果后可继续调整" }
        return "继续调整，例如：再自然一点，缩短一半"
    }

    private var sourceLabel: String {
        if state.isProcessing { return "生成中，暂不可编辑" }
        return switch state.source {
        case .accessibility: "来自当前选区"
        case .pasteboard: "通过剪贴板读取"
        case .manual: "可直接编辑"
        }
    }

    private var sourceStatusColor: Color {
        state.isProcessing ? Palette.blue500 : Palette.emerald500.opacity(0.72)
    }

    private var canSubmitFollowUp: Bool {
        hasResult
            && !state.followUp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !state.isProcessing
    }
}

// MARK: - Chrome

private struct WindowControlButton: View {
    let systemName: String
    let help: String
    var tint: Color = Palette.slate400
    var hoverTint: Color = Palette.slate200
    var hoverBackground: Color = Palette.controlHover
    var rotation: Double = 0
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .regular))
                .rotationEffect(.degrees(rotation))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(hovering ? hoverTint : tint)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(hovering ? hoverBackground : Color.clear)
        )
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .help(help)
        .accessibilityLabel(help)
    }
}

private struct SceneMenuRow: View {
    let scene: WritingScene
    let isSelected: Bool
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(scene.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Palette.slate100 : Palette.slate300)
                    .lineLimit(1)
                Spacer(minLength: 6)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Palette.blue400)
                }
            }
            .padding(.horizontal, 9)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(rowBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.10), value: hovering)
    }

    private var rowBackground: Color {
        if isSelected {
            return Palette.blue600.opacity(hovering ? 0.26 : 0.18)
        }
        return Palette.controlHover.opacity(hovering ? 1 : 0)
    }
}

private struct PrimaryActionButton: View {
    let title: String
    let keycap: String?
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                if let keycap {
                    KeyCap(text: keycap, tone: .primary)
                }
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(hovering && isEnabled ? Palette.blue500 : Palette.blue600)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Palette.blue400.opacity(0.30), lineWidth: 1)
            )
            .shadow(
                color: Palette.blue600.opacity(isEnabled ? 0.34 : 0),
                radius: 12,
                y: 0
            )
        }
        .buttonStyle(PressableButtonStyle())
        .keyboardShortcut(.return, modifiers: .command)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

private struct FooterActionButton: View {
    enum Variant {
        case primary
        case secondary
    }

    let title: String
    var keycap: String?
    let variant: Variant
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12, weight: variant == .primary ? .medium : .regular))
                if let keycap {
                    KeyCap(text: keycap, tone: variant == .primary ? .primary : .secondary)
                }
            }
            .foregroundStyle(variant == .primary ? Color.white : (hovering ? Palette.slate100 : Palette.slate300))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .shadow(
                color: variant == .primary ? Palette.buttonShadow : .clear,
                radius: 1,
                y: 1
            )
        }
        .buttonStyle(PressableButtonStyle())
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var background: Color {
        switch variant {
        case .primary:
            hovering && isEnabled ? Palette.blue500 : Palette.blue600
        case .secondary:
            hovering && isEnabled ? Palette.controlFillHover : Palette.controlFill
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary:
            Palette.blue400.opacity(0.30)
        case .secondary:
            Palette.controlBorder
        }
    }
}

private struct IconActionButton: View {
    let systemName: String
    let help: String
    var tint: Color = Palette.slate400
    var hoverTint: Color = Palette.slate200
    var showsBorderOnHover = false
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .foregroundStyle(hovering && isEnabled ? hoverTint : tint)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(hovering && isEnabled ? Palette.controlFillHover : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(
                    showsBorderOnHover && hovering && isEnabled
                        ? Palette.controlBorder
                        : Color.clear,
                    lineWidth: 1
                )
        )
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .opacity(isEnabled ? 1 : 0.4)
        .help(help)
        .accessibilityLabel(help)
    }
}

private struct InlineButton: View {
    let title: String
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(hovering ? Palette.slate100 : Palette.slate300)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(hovering ? Palette.controlFillHover : Palette.controlFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(Palette.controlBorder, lineWidth: 1)
                )
        }
        .buttonStyle(PressableButtonStyle())
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
    }
}

private struct KeyCap: View {
    enum Tone {
        case primary
        case secondary
    }

    let text: String
    let tone: Tone

    var body: some View {
        Text(text)
            .font(.system(size: 10, design: .monospaced))
            .foregroundStyle(tone == .primary ? Palette.blue100 : Palette.slate400)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(tone == .primary ? Palette.blue700.opacity(0.82) : Palette.keycapFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(
                        tone == .primary ? Palette.blue400.opacity(0.20) : Palette.hairline,
                        lineWidth: 1
                    )
            )
            .accessibilityHidden(true)
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.84 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

// MARK: - Surface

private struct PanelSurface: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            VisualEffectView(isDark: colorScheme == .dark)
            LinearGradient(
                colors: [
                    Palette.obsidian850.opacity(0.90),
                    Palette.obsidian900.opacity(0.93),
                    Palette.obsidian950.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct VisualEffectView: NSViewRepresentable {
    let isDark: Bool

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        configure(view)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        configure(nsView)
    }

    private func configure(_ nsView: NSVisualEffectView) {
        nsView.material = isDark ? .hudWindow : .popover
        nsView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    }
}

// MARK: - Palette

private enum Palette {
    static let obsidian950 = Color.adaptive(light: 0xF2F4F8, dark: 0x090A0F)
    static let obsidian900 = Color.adaptive(light: 0xFFFFFF, dark: 0x0E1117)
    static let obsidian850 = Color.adaptive(light: 0xFBFCFE, dark: 0x131722)
    static let obsidian800 = Color.adaptive(light: 0xF5F7FA, dark: 0x181E2B)

    static let blue700 = Color(hex: 0x1D4ED8)
    static let blue600 = Color(hex: 0x2563EB)
    static let blue500 = Color(hex: 0x3B82F6)
    static let blue400 = Color.adaptive(light: 0x2563EB, dark: 0x60A5FA)
    static let blue300 = Color.adaptive(light: 0x1D4ED8, dark: 0x93C5FD)
    static let blue100 = Color(hex: 0xDBEAFE)

    static let slate100 = Color.adaptive(light: 0x0F172A, dark: 0xF1F5F9)
    static let slate200 = Color.adaptive(light: 0x1E293B, dark: 0xE2E8F0)
    static let slate300 = Color.adaptive(light: 0x334155, dark: 0xCBD5E1)
    static let slate400 = Color.adaptive(light: 0x64748B, dark: 0x94A3B8)
    static let slate500 = Color.adaptive(light: 0x94A3B8, dark: 0x64748B)

    static let emerald500 = Color.adaptive(light: 0x059669, dark: 0x10B981)
    static let rose300 = Color.adaptive(light: 0xE11D48, dark: 0xFDA4AF)
    static let rose500 = Color.adaptive(light: 0xE11D48, dark: 0xF43F5E)
    static let red = Color.adaptive(light: 0xDC2626, dark: 0xF87171)

    static let panelEdgeTop = Color.neutral(light: 0.14, dark: 0.17)
    static let panelEdgeMiddle = Color.neutral(light: 0.06, dark: 0.06)
    static let panelEdgeBottom = Color.neutral(light: 0.10, dark: 0.10)
    static let headerWash = Color.neutral(light: 0.018, dark: 0.02)
    static let hairline = Color.neutral(light: 0.07, dark: 0.07)
    static let fieldBorder = Color.neutral(light: 0.10, dark: 0.08)
    static let border = Color.neutral(light: 0.10, dark: 0.09)
    static let fill = Color.neutral(light: 0.045, dark: 0.05)
    static let controlFill = Color.neutral(light: 0.045, dark: 0.06)
    static let controlFillHover = Color.neutral(light: 0.08, dark: 0.10)
    static let controlBorder = Color.neutral(light: 0.08, dark: 0.08)
    static let controlHover = Color.neutral(light: 0.05, dark: 0.07)
    static let keycapFill = Color.neutral(light: 0.05, dark: 0.28)

    static let logoShadow = Color.shadow(light: 0.12, dark: 0.30)
    static let fieldShadow = Color.shadow(light: 0.06, dark: 0.22)
    static let buttonShadow = Color.shadow(light: 0.10, dark: 0.18)
}

private extension Color {
    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(
            nsColor: NSColor(name: nil) { appearance in
                NSColor(hex: isDarkAppearance(appearance) ? dark : light)
            }
        )
    }

    static func neutral(light: CGFloat, dark: CGFloat) -> Color {
        Color(
            nsColor: NSColor(name: nil) { appearance in
                let isDark = isDarkAppearance(appearance)
                return (isDark ? NSColor.white : NSColor.black)
                    .withAlphaComponent(isDark ? dark : light)
            }
        )
    }

    static func shadow(light: CGFloat, dark: CGFloat) -> Color {
        Color(
            nsColor: NSColor(name: nil) { appearance in
                NSColor.black.withAlphaComponent(isDarkAppearance(appearance) ? dark : light)
            }
        )
    }

    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

private extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

private func isDarkAppearance(_ appearance: NSAppearance) -> Bool {
    appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
}
