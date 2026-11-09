import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.5)
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xl) {
                    sourceSection
                    sceneSection
                    resultSection
                }
                .padding(Space.xl)
            }
            dock
        }
        .frame(minWidth: 480, minHeight: 480)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.panel).stroke(Tone.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
        .padding(6)
        .onExitCommand { state.dismissPanel?() }
    }

    private var header: some View {
        HStack(spacing: Space.md) {
            BrioAppIcon(size: 24)
            Text("Brio")
                .font(.system(.title2, design: .rounded).weight(.semibold))
            Text("让表达恰如其分")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            Button(state.isPinned ? "取消固定" : "固定窗口", systemImage: state.isPinned ? "pin.fill" : "pin", action: state.togglePinned)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .foregroundStyle(state.isPinned ? Color.accentColor : Color.secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
                .help(state.isPinned ? "取消固定，点击其他位置时自动关闭" : "固定窗口，点击其他位置时保持显示")
            Button(state.isProcessing ? "停止并关闭" : "关闭", systemImage: "xmark") { state.dismissPanel?() }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
                .help(state.isProcessing ? "停止生成并关闭窗口" : "关闭窗口")
        }
        .padding(.horizontal, Space.xl)
        .padding(.vertical, Space.lg)
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack {
                Label("原文", systemImage: "text.quote").font(.headline)
                Spacer()
                Text(sourceLabel).font(.caption).foregroundStyle(.secondary)
            }
            TextField("粘贴或输入要处理的文字…", text: $state.sourceText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body)
                .lineLimit(3...6)
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
                .padding(10)
                .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.card))
                .overlay(RoundedRectangle(cornerRadius: Radius.card).stroke(Tone.hairline))
        }
    }

    private var sceneSection: some View {
        HStack(spacing: Space.md) {
            Menu {
                ForEach(state.scenes) { scene in
                    Button {
                        state.select(scene)
                    } label: {
                        Text(scene.name)
                    }
                }
            } label: {
                Text(state.selectedScene.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 180, alignment: .leading)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .padding(.trailing, Space.lg)
            .disabled(state.isProcessing)
            .help(state.selectedScene.name)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.well))
            .overlay(alignment: .trailing) {
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, Space.md)
                    .allowsHitTesting(false)
            }
            Text(state.selectedScene.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(state.selectedScene.subtitle)
            Spacer(minLength: 0)
            Button {
                if state.isProcessing {
                    state.stop()
                } else {
                    state.generate()
                }
            } label: {
                Text(state.isProcessing ? "停止" : (state.selectedScene.isTranslation ? "开始翻译" : "开始生成"))
                    .font(.body.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .disabled(!state.isProcessing && !hasSourceText)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if !state.resultText.isEmpty || state.isProcessing {
            VStack(alignment: .leading, spacing: Space.md) {
                HStack {
                    Label(state.resultTitle, systemImage: "checkmark.seal").font(.headline)
                    Spacer()
                    if state.isProcessing {
                        ProgressView().controlSize(.small)
                        Text("正在生成…").font(.caption).foregroundStyle(.secondary)
                    }
                }
                if !state.resultText.isEmpty {
                    Text(state.resultText)
                        .font(.body)
                        .lineSpacing(5)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Space.lg)
                        .background(Tone.accentWash, in: RoundedRectangle(cornerRadius: Radius.card))
                }
            }
        }
    }

    private var dock: some View {
        VStack(spacing: Space.md) {
            if let error = state.errorMessage {
                feedbackRow(error)
            } else if let status = state.statusMessage {
                statusRow(status)
            }

            if !state.resultText.isEmpty {
                HStack(spacing: Space.sm) {
                    Button("复制结果", action: state.copyResult)
                    Button(state.source == .manual ? "复制并关闭" : "替换原文") {
                        if state.source == .manual {
                            state.copyResult()
                            state.dismissPanel?()
                        } else {
                            state.replaceSelection()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("重新生成", systemImage: "arrow.clockwise", action: state.generate)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                        .help("重新生成")
                    Spacer()
                }
                .disabled(state.isProcessing)
            }

            HStack(spacing: Space.sm) {
                Image(systemName: "text.bubble")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                TextField(followUpPrompt, text: $state.followUp)
                    .textFieldStyle(.plain)
                    .accessibilityLabel("继续调整")
                    .disabled(!hasResult || state.isProcessing)
                    .onSubmit {
                        if canSubmitFollowUp { state.generate() }
                    }
                Button("应用调整", systemImage: "arrow.up", action: state.generate)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(canSubmitFollowUp ? Color.accentColor : Color.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
                    .disabled(!canSubmitFollowUp)
                    .help("按调整要求生成")
            }
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .background(Tone.fill, in: RoundedRectangle(cornerRadius: Radius.dock))
        }
        .padding(.horizontal, Space.xl)
        .padding(.vertical, Space.lg)
        .background(.bar)
    }

    private func feedbackRow(_ error: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color(nsColor: .systemRed))
                .accessibilityHidden(true)
            Text(error)
                .font(.caption)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("错误：\(error)")
            Spacer(minLength: Space.sm)
            if !state.isProviderConfigured {
                Button("打开设置") { state.openSettings?() }
                    .controlSize(.small)
            }
            if state.needsAccessibilityPermission {
                Button("打开系统设置") { state.openAccessibilitySettings() }
                    .controlSize(.small)
            }
            if hasSourceText {
                Button("重试") { state.generate() }
                    .controlSize(.small)
            }
        }
    }

    private func statusRow(_ status: String) -> some View {
        HStack(spacing: Space.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(nsColor: .systemGreen))
                .accessibilityHidden(true)
            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(status)
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

    private var canSubmitFollowUp: Bool {
        hasResult && !state.followUp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !state.isProcessing
    }
}
