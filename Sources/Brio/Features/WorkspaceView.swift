import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.5)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    sourceSection
                    sceneSection
                    resultSection
                }
                .padding(24)
            }
            if state.isProcessing || !state.resultText.isEmpty {
                footer
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(minWidth: 480, minHeight: 480)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.18), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(6)
        .animation(.easeInOut(duration: 0.2), value: state.isProcessing || !state.resultText.isEmpty)
        .onExitCommand { state.dismissPanel?() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.tint)
            Text("Brio")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Text("让表达恰如其分")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            if state.isProcessing {
                Button("停止", systemImage: "stop.circle", action: state.stop)
                    .labelStyle(.iconOnly)
                    .help("停止生成")
            }
            Button(state.isPinned ? "取消固定" : "固定窗口", systemImage: state.isPinned ? "pin.fill" : "pin", action: state.togglePinned)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .foregroundStyle(state.isPinned ? Color.accentColor : Color.secondary)
                .help(state.isPinned ? "取消固定，点击其他位置时自动关闭" : "固定窗口，点击其他位置时保持显示")
            Button("关闭", systemImage: "xmark") { state.dismissPanel?() }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 17)
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("原文", systemImage: "text.quote").font(.headline)
                Spacer()
                Text(sourceLabel).font(.caption).foregroundStyle(.secondary)
            }
            TextEditor(text: $state.sourceText)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 72, maxHeight: 120)
                .padding(10)
                .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.08)))
        }
    }

    private var sceneSection: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(state.scenes) { scene in
                    Button {
                        state.select(scene)
                    } label: {
                        Label(scene.name, systemImage: scene.symbol)
                    }
                }
            } label: {
                Label(state.selectedScene.name, systemImage: state.selectedScene.symbol)
                    .font(.system(size: 14, weight: .medium))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
            Text(state.selectedScene.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer(minLength: 0)
            Button {
                if state.isProcessing {
                    state.stop()
                } else {
                    state.generate()
                }
            } label: {
                Label(
                    state.isProcessing ? "停止" : (state.selectedScene.name == "中英互译" ? "开始翻译" : "开始润色"),
                    systemImage: state.isProcessing ? "stop.fill" : "arrow.right"
                )
                .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(state.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .keyboardShortcut(.return, modifiers: .command)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if !state.resultText.isEmpty || state.isProcessing {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("优化结果", systemImage: "checkmark.seal").font(.headline)
                    Spacer()
                    if state.isProcessing {
                        ProgressView().controlSize(.small)
                        Text("正在生成…").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Text(state.resultText)
                    .font(.body)
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.accentColor.opacity(0.055), in: RoundedRectangle(cornerRadius: 10))
                HStack {
                    Button("复制结果", systemImage: "doc.on.doc", action: state.copyResult)
                    Button(state.source == .manual ? "复制并关闭" : "替换原文", systemImage: state.source == .manual ? "doc.on.doc" : "arrow.triangle.2.circlepath") {
                        if state.source == .manual {
                            state.copyResult()
                            state.dismissPanel?()
                        } else {
                            state.replaceSelection()
                        }
                    }
                    Spacer()
                    Button("重新生成", systemImage: "arrow.clockwise", action: state.generate).labelStyle(.iconOnly)
                }
                .disabled(state.isProcessing)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            if let error = state.errorMessage {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.caption).foregroundStyle(.orange).frame(maxWidth: .infinity, alignment: .leading)
            } else if let status = state.statusMessage {
                Label(status, systemImage: "checkmark.circle")
                    .font(.caption).foregroundStyle(.green).frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: 10) {
                Image(systemName: "text.bubble").foregroundStyle(.secondary)
                TextField("继续调整，例如：再自然一点，缩短一半", text: $state.followUp)
                    .textFieldStyle(.plain)
                    .onSubmit(state.generate)
                Button("生成", systemImage: "arrow.up.circle.fill", action: state.generate)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .disabled(state.sourceText.isEmpty || state.isProcessing)
                    .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial)
    }

    private var sourceLabel: String {
        switch state.source {
        case .accessibility: "来自当前选区"
        case .pasteboard: "通过剪贴板读取"
        case .manual: "可直接编辑"
        }
    }
}
