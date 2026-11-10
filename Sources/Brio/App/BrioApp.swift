import AppKit
import SwiftUI

@main
struct BrioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            Button("处理选中文本") { AppState.shared.openFromShortcut() }
            Button("打开工作台") { AppState.shared.openWorkspace() }
            Divider()
            Button("设置…") { delegate.openSettings() }
            Divider()
            Button("退出 Brio") { NSApplication.shared.terminate(nil) }
        } label: {
            Image(nsImage: MenuBarIcon.image)
                .accessibilityLabel("Brio")
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var panel: FloatingPanel?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configurePanel()
        AppState.shared.presentPanel = { [weak self] in self?.showPanel() }
        AppState.shared.dismissPanel = { [weak self] in self?.hidePanel() }
        AppState.shared.openSettings = { [weak self] in self?.openSettings() }
        AppState.shared.pinStateChanged = { [weak self] isPinned in
            self?.panel?.level = isPinned ? .floating : .normal
        }
        HotKeyManager.shared.onWorkspaceTrigger = { AppState.shared.openWorkspace() }
        HotKeyManager.shared.onSceneTrigger = { sceneID in
            AppState.shared.openFromShortcut(sceneID: sceneID)
        }
        HotKeyManager.shared.register(ShortcutConfiguration.load())
        if CommandLine.arguments.contains("--workspace") {
            DispatchQueue.main.async { AppState.shared.openWorkspace() }
        }
        if CommandLine.arguments.contains("--settings") {
            DispatchQueue.main.async { self.openSettings() }
        }
    }

    private func configurePanel() {
        let view = WorkspaceView().environmentObject(AppState.shared)
        let panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 632, height: 580), backing: .buffered, defer: false)
        panel.contentView = NSHostingView(rootView: view)
        panel.delegate = self
        panel.center()
        self.panel = panel
    }

    private func showPanel() {
        settingsWindow?.orderOut(nil)
        NSApp.activate(ignoringOtherApps: true)
        panel?.level = AppState.shared.isPinned ? .floating : .normal
        panel?.appearance = AppAppearance.current.nsAppearance
        panel?.center()
        panel?.makeKeyAndOrderFront(nil)
    }

    private func hidePanel() {
        if AppState.shared.isProcessing {
            AppState.shared.stop(announce: false)
        }
        AppState.shared.isPinned = false
        panel?.orderOut(nil)
    }

    func windowDidResignKey(_ notification: Notification) {
        guard !AppState.shared.isPinned,
              !AppState.shared.isProcessing,
              panel?.isVisible == true else { return }
        hidePanel()
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView().environmentObject(AppState.shared)
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 980, height: 700), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
            window.title = "Brio 设置"
            window.contentMinSize = NSSize(width: 900, height: 620)
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.toolbarStyle = .unifiedCompact
            window.toolbar = NSToolbar()
            window.contentView = NSHostingView(rootView: view)
            window.appearance = AppAppearance.current.nsAppearance
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.appearance = AppAppearance.current.nsAppearance
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

final class FloatingPanel: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless, .resizable], backing: backing, defer: flag)
        isFloatingPanel = true
        hidesOnDeactivate = false
        level = .normal
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        isMovableByWindowBackground = true
        minSize = NSSize(width: 492, height: 520)
    }

    override var canBecomeKey: Bool { true }
}
