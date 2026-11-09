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
}
