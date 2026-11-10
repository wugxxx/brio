import SwiftUI

struct SettingsPalette {
    let isDark: Bool

    var canvas: Color { color(isDark ? 0x111318 : 0xF3F4F6) }
    var sidebar: Color { color(isDark ? 0x0D0F14 : 0xFFFFFF) }
    var surface: Color { color(isDark ? 0x1A1B21 : 0xFFFFFF) }
    var surfaceRaised: Color { color(isDark ? 0x1E1F25 : 0xFFFFFF) }
    var sunken: Color { color(isDark ? 0x0C0E13 : 0xE5E7EB) }
    var hover: Color { color(isDark ? 0x282A2F : 0xF9FAFB) }
    var textPrimary: Color { color(isDark ? 0xE2E2E9 : 0x111827) }
    var textSecondary: Color { color(isDark ? 0xC7C4D8 : 0x4B5563) }
    var textMuted: Color { color(isDark ? 0x918FA1 : 0x9CA3AF) }
    var accent: Color { color(isDark ? 0x4F46E5 : 0x0066FF) }
    var accentHover: Color { color(isDark ? 0x4338CA : 0x0050CB) }
    var accentText: Color { color(isDark ? 0xC3C0FF : 0x0050CB) }
    var accentSoft: Color { accent.opacity(isDark ? 0.18 : 0.09) }
    var success: Color { color(isDark ? 0x4EDEA3 : 0x10B981) }
    var signal: Color { color(isDark ? 0x38BDF8 : 0x4F46E5) }
    var warning: Color { color(isDark ? 0xFBBF24 : 0xB45309) }
    var error: Color { color(isDark ? 0xFFB4AB : 0xBA1A1A) }
    var errorSoft: Color { error.opacity(isDark ? 0.15 : 0.10) }
    var onAccent: Color { .white }
    var hairline: Color { Color.primary.opacity(isDark ? 0.08 : 0.08) }
    var border: Color { Color.primary.opacity(isDark ? 0.12 : 0.12) }
    var controlFill: Color { Color.white.opacity(isDark ? 0.05 : 0.72) }
    var controlBorder: Color { Color.white.opacity(isDark ? 0.08 : 0.10) }
    var scrim: Color { color(isDark ? 0x0D0F14 : 0xF3F4F6) }

    var pageGlow: RadialGradient {
        RadialGradient(
            colors: [accent.opacity(isDark ? 0.14 : 0.06), .clear],
            center: .topLeading,
            startRadius: 0,
            endRadius: 420
        )
    }

    private func color(_ hex: UInt32) -> Color {
        Color(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

private struct SettingsPaletteKey: EnvironmentKey {
    static let defaultValue = SettingsPalette(isDark: true)
}

extension EnvironmentValues {
    var settingsPalette: SettingsPalette {
        get { self[SettingsPaletteKey.self] }
        set { self[SettingsPaletteKey.self] = newValue }
    }
}

enum SettingsType {
    static func sectionTitle() -> Font { .system(size: 14, weight: .semibold) }
    static func rowTitle() -> Font { .system(size: 13, weight: .medium) }
    static let body = Font.system(size: 12.5)
    static let caption = Font.system(size: 11.5)
    static let micro = Font.system(size: 10.5, weight: .medium)
    static let monoMicro = Font.system(size: 10.5, design: .monospaced)
    static let mono = Font.system(size: 12, design: .monospaced)
}

struct SettingsSection<Content: View>: View {
    @Environment(\.settingsPalette) private var palette

    let symbol: String
    let title: String
    var meta: String?
    var tint: Color?
    private let content: Content

    init(
        symbol: String,
        title: String,
        meta: String? = nil,
        tint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.symbol = symbol
        self.title = title
        self.meta = meta
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint ?? palette.textSecondary)
                    .frame(width: 20)
                    .accessibilityHidden(true)
                Text(title)
                    .font(SettingsType.sectionTitle())
                    .tracking(-0.12)
                    .foregroundStyle(palette.textPrimary)
                Spacer(minLength: 12)
                if let meta {
                    Text(meta)
                        .font(SettingsType.monoMicro)
                        .foregroundStyle(palette.textMuted)
                        .textCase(.uppercase)
                        .tracking(0.35)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 15)
            .padding(.bottom, 12)

            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)

            VStack(spacing: 8) {
                content
            }
            .padding(12)
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
    }
}

struct SettingsRowLabel: View {
    @Environment(\.settingsPalette) private var palette

    let symbol: String
    let title: String
    var caption: String?
    var tint: Color?

    var body: some View {
        HStack(spacing: 10) {
            SettingsIconTile(symbol: symbol, tint: tint ?? palette.textSecondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SettingsType.rowTitle())
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(2)
                if let caption {
                    Text(caption)
                        .font(SettingsType.caption)
                        .foregroundStyle(palette.textMuted)
                        .lineLimit(2)
                }
            }
        }
    }
}

struct SettingsIconTile: View {
    @Environment(\.settingsPalette) private var palette

    let symbol: String
    var tint: Color
    var size: CGFloat = 30

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.46, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(palette.isDark ? 0.16 : 0.10), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(tint.opacity(palette.isDark ? 0.14 : 0.08), lineWidth: 1)
            )
            .accessibilityHidden(true)
    }
}

struct SettingsInsetRow<Accessory: View>: View {
    @Environment(\.settingsPalette) private var palette

    let symbol: String
    let title: String
    var caption: String?
    var tint: Color?
    var showsBackground = true
    private let accessory: Accessory

    init(
        symbol: String,
        title: String,
        caption: String? = nil,
        tint: Color? = nil,
        showsBackground: Bool = true,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.symbol = symbol
        self.title = title
        self.caption = caption
        self.tint = tint
        self.showsBackground = showsBackground
        self.accessory = accessory()
    }

    var body: some View {
        HStack(spacing: 14) {
            SettingsRowLabel(symbol: symbol, title: title, caption: caption, tint: tint)
            Spacer(minLength: 16)
            accessory
        }
        .padding(.horizontal, showsBackground ? 12 : 4)
        .padding(.vertical, showsBackground ? 10 : 7)
        .background(
            Group {
                if showsBackground {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(palette.sunken.opacity(palette.isDark ? 0.66 : 0.62))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(palette.hairline, lineWidth: 1)
                        )
                }
            }
        )
    }
}

extension SettingsInsetRow where Accessory == EmptyView {
    init(symbol: String, title: String, caption: String? = nil, tint: Color? = nil, showsBackground: Bool = true) {
        self.init(symbol: symbol, title: title, caption: caption, tint: tint, showsBackground: showsBackground) {
            EmptyView()
        }
    }
}

struct SettingsFormRow<Accessory: View>: View {
    @Environment(\.settingsPalette) private var palette

    let symbol: String
    let title: String
    var labelWidth: CGFloat = 128
    private let accessory: Accessory

    init(
        symbol: String,
        title: String,
        labelWidth: CGFloat = 128,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.symbol = symbol
        self.title = title
        self.labelWidth = labelWidth
        self.accessory = accessory()
    }

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textMuted)
                    .frame(width: 16)
                    .accessibilityHidden(true)
                Text(title)
                    .font(SettingsType.rowTitle())
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: labelWidth, alignment: .leading)
            accessory
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
    }
}

struct SettingsFieldShell<Content: View>: View {
    @Environment(\.settingsPalette) private var palette

    var isFocused = false
    private let content: Content

    init(isFocused: Bool = false, @ViewBuilder content: () -> Content) {
        self.isFocused = isFocused
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 8) { content }
            .padding(.horizontal, 11)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.sunken.opacity(palette.isDark ? 0.78 : 0.58))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(isFocused ? palette.accent.opacity(0.72) : palette.border, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(palette.accent.opacity(0.20), lineWidth: 3)
                    .padding(-2)
                    .opacity(isFocused ? 1 : 0)
            )
    }
}

struct SettingsTextField<Trailing: View>: View {
    @Environment(\.settingsPalette) private var palette
    @FocusState private var focused: Bool

    @Binding var text: String
    let prompt: String
    var leadingText: String?
    var monospaced = false
    private let trailing: Trailing

    init(
        text: Binding<String>,
        prompt: String,
        leadingText: String? = nil,
        monospaced: Bool = false,
        @ViewBuilder trailing: () -> Trailing
    ) {
        _text = text
        self.prompt = prompt
        self.leadingText = leadingText
        self.monospaced = monospaced
        self.trailing = trailing()
    }

    var body: some View {
        SettingsFieldShell(isFocused: focused) {
            if let leadingText {
                Text(leadingText)
                    .font(SettingsType.monoMicro)
                    .foregroundStyle(palette.textMuted)
                Rectangle()
                    .fill(palette.hairline)
                    .frame(width: 1, height: 16)
            }
            TextField("", text: $text, prompt: Text(prompt).foregroundColor(palette.textMuted))
                .textFieldStyle(.plain)
                .font(monospaced ? SettingsType.mono : SettingsType.body)
                .foregroundStyle(palette.textPrimary)
                .focused($focused)
                .accessibilityLabel(prompt)
            trailing
        }
    }
}

extension SettingsTextField where Trailing == EmptyView {
    init(text: Binding<String>, prompt: String, leadingText: String? = nil, monospaced: Bool = false) {
        self.init(text: text, prompt: prompt, leadingText: leadingText, monospaced: monospaced) {
            EmptyView()
        }
    }
}

struct SettingsSecretField<Trailing: View>: View {
    @Environment(\.settingsPalette) private var palette
    @FocusState private var focused: Bool

    @Binding var text: String
    @Binding var isRevealed: Bool
    let prompt: String
    private let trailing: Trailing

    init(
        text: Binding<String>,
        isRevealed: Binding<Bool>,
        prompt: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        _text = text
        _isRevealed = isRevealed
        self.prompt = prompt
        self.trailing = trailing()
    }

    var body: some View {
        SettingsFieldShell(isFocused: focused) {
            Group {
                if isRevealed {
                    TextField("", text: $text, prompt: Text(prompt).foregroundColor(palette.textMuted))
                        .accessibilityLabel("API Key")
                } else {
                    SecureField("", text: $text, prompt: Text(prompt).foregroundColor(palette.textMuted))
                        .accessibilityLabel("API Key")
                }
            }
            .textFieldStyle(.plain)
            .font(SettingsType.mono)
            .foregroundStyle(palette.textPrimary)
            .focused($focused)
            SettingsIconButton(
                symbol: isRevealed ? "eye.slash" : "eye",
                help: isRevealed ? "隐藏 API Key" : "显示 API Key"
            ) {
                isRevealed.toggle()
            }
            trailing
        }
    }
}

extension SettingsSecretField where Trailing == EmptyView {
    init(text: Binding<String>, isRevealed: Binding<Bool>, prompt: String) {
        self.init(text: text, isRevealed: isRevealed, prompt: prompt) { EmptyView() }
    }
}

struct SettingsTextEditor: View {
    @Environment(\.settingsPalette) private var palette
    @FocusState private var focused: Bool

    @Binding var text: String
    let prompt: String
    var minHeight: CGFloat = 116

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(prompt)
                    .font(SettingsType.body)
                    .foregroundStyle(palette.textMuted)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .font(SettingsType.body)
                .foregroundStyle(palette.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($focused)
                .padding(.horizontal, 7)
                .padding(.vertical, 5)
                .accessibilityLabel(prompt)
        }
        .frame(minHeight: minHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(palette.sunken.opacity(palette.isDark ? 0.78 : 0.58))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(focused ? palette.accent.opacity(0.72) : palette.border, lineWidth: 1)
        )
    }
}

struct SettingsSegmentOption<Value: Hashable> {
    let value: Value
    let title: String
    let symbol: String
}

struct SettingsSegmentedControl<Value: Hashable>: View {
    @Environment(\.settingsPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var thumb

    let options: [SettingsSegmentOption<Value>]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.value) { option in
                Button {
                    selection = option.value
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: option.symbol)
                            .font(.system(size: 12, weight: .semibold))
                        Text(option.title)
                            .font(SettingsType.body)
                            .lineLimit(1)
                    }
                    .foregroundStyle(selection == option.value ? palette.textPrimary : palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 29)
                    .contentShape(Rectangle())
                    .background {
                        if selection == option.value {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(palette.surfaceRaised)
                                .matchedGeometryEffect(id: "segment-thumb", in: thumb)
                                .shadow(color: Color.black.opacity(palette.isDark ? 0.30 : 0.10), radius: 2, y: 1)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == option.value ? .isSelected : [])
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(palette.sunken.opacity(palette.isDark ? 0.88 : 0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(palette.hairline, lineWidth: 1)
        )
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: selection)
    }
}

struct SettingsKbd: View {
    @Environment(\.settingsPalette) private var palette

    let text: String
    var active = false

    var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
            .foregroundStyle(active ? palette.textPrimary : palette.textSecondary)
            .padding(.horizontal, 7)
            .frame(minWidth: 24, minHeight: 22)
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
                    .strokeBorder(Color.white.opacity(palette.isDark ? 0.12 : 0.55), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(palette.isDark ? 0.32 : 0.08), radius: 1.5, y: 1)
    }
}

struct SettingsStatusPill: View {
    @Environment(\.settingsPalette) private var palette

    let text: String
    var color: Color?
    var showsDot = true

    var body: some View {
        let tint = color ?? palette.success
        HStack(spacing: 6) {
            if showsDot {
                Circle()
                    .fill(tint)
                    .frame(width: 6, height: 6)
                    .shadow(color: tint.opacity(0.55), radius: 3)
                    .accessibilityHidden(true)
            }
            Text(text)
                .font(SettingsType.micro)
                .foregroundStyle(tint)
                .lineLimit(1)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(tint.opacity(palette.isDark ? 0.10 : 0.08), in: Capsule())
        .overlay(Capsule().strokeBorder(tint.opacity(0.22), lineWidth: 1))
    }
}

struct SettingsNotice: View {
    @Environment(\.settingsPalette) private var palette

    let text: String
    var symbol = "info.circle"
    var tint: Color?

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint ?? palette.accentText)
                .padding(.top, 1)
                .accessibilityHidden(true)
            Text(text)
                .font(SettingsType.caption)
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill((tint ?? palette.accent).opacity(palette.isDark ? 0.07 : 0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder((tint ?? palette.accent).opacity(0.16), lineWidth: 1)
        )
    }
}

struct SettingsIconButton: View {
    @Environment(\.settingsPalette) private var palette
    @State private var hovering = false

    let symbol: String
    let help: String
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint ?? (hovering ? palette.textPrimary : palette.textMuted))
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(hovering ? palette.hover : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(help)
        .accessibilityLabel(help)
    }
}

struct SettingsPrimaryButtonStyle: ButtonStyle {
    @Environment(\.settingsPalette) private var palette
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .medium))
            .foregroundStyle(palette.onAccent.opacity(isEnabled ? 1 : 0.65))
            .padding(.horizontal, 14)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(configuration.isPressed ? palette.accentHover : palette.accent)
                    .opacity(isEnabled ? 1 : 0.48)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(palette.isDark ? 0.18 : 0.12), lineWidth: 1)
            )
            .shadow(color: palette.accent.opacity(isEnabled ? 0.24 : 0), radius: 8, y: 3)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

struct SettingsGhostButtonStyle: ButtonStyle {
    @Environment(\.settingsPalette) private var palette
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .medium))
            .foregroundStyle(palette.textPrimary.opacity(isEnabled ? 1 : 0.45))
            .padding(.horizontal, 13)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(configuration.isPressed ? palette.hover : palette.controlFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(palette.border, lineWidth: 1)
            )
    }
}

struct SettingsQuietButtonStyle: ButtonStyle {
    @Environment(\.settingsPalette) private var palette
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .medium))
            .foregroundStyle(palette.textSecondary.opacity(isEnabled ? 1 : 0.45))
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(configuration.isPressed ? palette.hover : .clear)
            )
    }
}

struct SettingsDestructiveButtonStyle: ButtonStyle {
    @Environment(\.settingsPalette) private var palette
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: .medium))
            .foregroundStyle(palette.error.opacity(isEnabled ? 1 : 0.45))
            .padding(.horizontal, 13)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.errorSoft.opacity(configuration.isPressed ? 1.4 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(palette.error.opacity(0.24), lineWidth: 1)
            )
    }
}

