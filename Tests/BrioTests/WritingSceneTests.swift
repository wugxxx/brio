import Foundation
import XCTest
@testable import Brio

final class WritingSceneTests: XCTestCase {
    func testBuiltInSceneIDsAreStable() {
        XCTAssertEqual(WritingScene.builtIns.map(\.id), WritingScene.builtIns.map(\.id))
        XCTAssertEqual(Set(WritingScene.builtIns.map(\.id)).count, WritingScene.builtIns.count)
    }

    func testInitialPrompt() {
        let scene = WritingScene(name: "精简", subtitle: "", symbol: "", instruction: "删除冗余")
        let prompt = PromptBuilder.make(scene: scene, text: "原始文本", followUp: "", previousResult: "")
        XCTAssertTrue(prompt.contains("删除冗余"))
        XCTAssertTrue(prompt.contains("原始文本"))
        XCTAssertFalse(prompt.contains("上一版结果"))
    }

    func testFollowUpPrompt() {
        let scene = WritingScene(name: "精简", subtitle: "", symbol: "", instruction: "删除冗余")
        let prompt = PromptBuilder.make(scene: scene, text: "原始文本", followUp: "再短一点", previousResult: "上一版")
        XCTAssertTrue(prompt.contains("再短一点"))
        XCTAssertTrue(prompt.contains("上一版"))
    }

    func testScenePersistence() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = SceneStore(defaults: defaults)
        let custom = WritingScene(name: "客服回复", subtitle: "", symbol: "", instruction: "礼貌简洁")
        store.save(WritingScene.builtIns + [custom])
        let loaded = store.load()
        XCTAssertEqual(loaded.count, WritingScene.builtIns.count + 1)
        XCTAssertEqual(loaded.last?.name, "客服回复")
    }

    func testBuiltInSceneEditsPersist() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = SceneStore(defaults: defaults)
        var scenes = store.load()
        scenes[0].name = "自然表达"
        scenes[0].instruction = "保留原意，自然表达"
        store.save(scenes)
        let loaded = store.load()
        XCTAssertEqual(loaded.first?.name, "自然表达")
        XCTAssertEqual(loaded.first?.instruction, "保留原意，自然表达")
    }

    func testSceneDeletionPersists() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = SceneStore(defaults: defaults)
        var scenes = store.load()
        let removedID = scenes.removeFirst().id
        store.save(scenes)
        let loaded = store.load()
        XCTAssertEqual(loaded.count, scenes.count)
        XCTAssertFalse(loaded.contains(where: { $0.id == removedID }))
    }

    func testBuiltInIDMigrationUpdatesShortcutBinding() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = SceneStore(defaults: defaults)
        var scenes = WritingScene.builtIns
        let oldID = UUID()
        scenes[0].id = oldID
        store.save(scenes)
        let shortcuts = ShortcutConfiguration(
            workspace: ShortcutPreference(),
            actions: [SceneShortcut(sceneID: oldID, shortcut: ShortcutPreference(keyCode: 18))]
        )
        defaults.set(try JSONEncoder().encode(shortcuts), forKey: "shortcutConfiguration")
        let loaded = store.load()
        let migratedShortcuts = try JSONDecoder().decode(
            ShortcutConfiguration.self,
            from: try XCTUnwrap(defaults.data(forKey: "shortcutConfiguration"))
        )
        XCTAssertEqual(loaded[0].id, WritingScene.builtIns[0].id)
        XCTAssertEqual(migratedShortcuts.actions[0].sceneID, WritingScene.builtIns[0].id)
    }
}
