import Foundation
import XCTest
@testable import Brio

final class WorkspacePreferencesTests: XCTestCase {
    func testPreservesContentByDefault() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        XCTAssertTrue(WorkspacePreferences(defaults: defaults).preservesContent)
    }

    func testClearContentPreferencePersists() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(false, forKey: "preserveWorkspaceContent")
        XCTAssertFalse(WorkspacePreferences(defaults: defaults).preservesContent)
    }

    func testOpenBehaviorMigratesLegacyPreference() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(false, forKey: "preserveWorkspaceContent")
        XCTAssertEqual(WorkspacePreferences(defaults: defaults).openBehavior, .clear)
    }

    func testExplicitOpenBehaviorWinsOverLegacyPreference() throws {
        let suiteName = "BrioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(false, forKey: "preserveWorkspaceContent")
        defaults.set(WorkspaceOpenBehavior.paste.rawValue, forKey: "workspaceOpenBehavior")
        XCTAssertEqual(WorkspacePreferences(defaults: defaults).openBehavior, .paste)
    }
}
