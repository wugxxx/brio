import AppKit
import SwiftUI

enum AppAppearance: String, CaseIterable {
    case system
    case light
    case dark

    static let storageKey = "settingsAppearance"

    static var current: AppAppearance {
        AppAppearance(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .system
    }

    var title: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var nsAppearance: NSAppearance? {
        switch self {
        case .system: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
    }
}

struct WindowAppearanceConfigurator: NSViewRepresentable {
    let appearance: AppAppearance

    func makeNSView(context: Context) -> AppearanceView {
        let view = AppearanceView()
        view.appearanceValue = appearance
        return view
    }

    func updateNSView(_ nsView: AppearanceView, context: Context) {
        nsView.appearanceValue = appearance
        nsView.apply()
    }

    final class AppearanceView: NSView {
        var appearanceValue = AppAppearance.system

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }

        func apply() {
            window?.appearance = appearanceValue.nsAppearance
        }
    }
}
