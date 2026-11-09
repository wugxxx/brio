import Foundation
import XCTest
@testable import Brio

final class ShortcutConfigurationTests: XCTestCase {
    func testConfigurationStartsWithFiveEmptyActions() {
        var configuration = ShortcutConfiguration(workspace: ShortcutPreference(), actions: [])
        configuration.normalize()
        XCTAssertEqual(configuration.actions.count, 5)
        XCTAssertEqual(ShortcutConfiguration.actionLimit, 5)
    }

    func testDetectsWorkspaceAndSceneConflict() {
        let shortcut = ShortcutPreference()
        let configuration = ShortcutConfiguration(
            workspace: shortcut,
            actions: [SceneShortcut(sceneID: UUID(), shortcut: shortcut)]
        )
        XCTAssertTrue(configuration.hasConflicts)
    }

    func testRemovingSceneClearsItsAction() {
        let sceneID = UUID()
        var configuration = ShortcutConfiguration(
            workspace: ShortcutPreference(),
            actions: [SceneShortcut(sceneID: sceneID, shortcut: ShortcutPreference(keyCode: 18))]
        )
        configuration.removeScene(sceneID)
        XCTAssertNil(configuration.actions[0].sceneID)
        XCTAssertNil(configuration.actions[0].shortcut)
    }

    func testConfigurationPersistsSceneBindings() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let sceneID = UUID()
        let configuration = ShortcutConfiguration(
            workspace: ShortcutPreference(),
            actions: [SceneShortcut(sceneID: sceneID, shortcut: ShortcutPreference(keyCode: 18))]
        )
        let data = try JSONEncoder().encode(configuration)
        defaults.set(data, forKey: "shortcutConfiguration")
        let loaded = try JSONDecoder().decode(ShortcutConfiguration.self, from: try XCTUnwrap(defaults.data(forKey: "shortcutConfiguration")))
        XCTAssertEqual(loaded.actions.first?.sceneID, sceneID)
        XCTAssertEqual(loaded.actions.first?.shortcut?.keyCode, 18)
    }
}
