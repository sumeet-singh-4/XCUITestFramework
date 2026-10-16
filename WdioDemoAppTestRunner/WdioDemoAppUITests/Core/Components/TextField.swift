//
//  TextField.swift
//  XCUITestFramework
//
//  Reusable TextField component with common text input interactions
//

import Foundation
import XCTest

/// Reusable TextField component for common text field interactions
public class TextField {

    // MARK: - Properties

    private let element: XCUIElement
    private let identifier: String
    private let timeout: TimeInterval
    private let app: XCUIApplication

    // MARK: - Initialization

    public init(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        self.identifier = identifier
        self.app = app
        self.element = app.textFields[identifier]
        self.timeout = timeout
    }

    public init(element: XCUIElement, app: XCUIApplication, timeout: TimeInterval = 10) {
        self.element = element
        self.app = app
        self.identifier = element.identifier
        self.timeout = timeout
    }

    // MARK: - Existence

    public var exists: Bool {
        return element.exists
    }

    public func waitForExistence(timeout: TimeInterval? = nil) -> Bool {
        return element.waitForExistence(timeout: timeout ?? self.timeout)
    }

    // MARK: - State

    public var isEnabled: Bool {
        return element.isEnabled
    }

    public var value: String {
        return element.value as? String ?? ""
    }

    public var placeholderValue: String {
        return element.placeholderValue ?? ""
    }

    public var isEmpty: Bool {
        return value.isEmpty
    }

    // MARK: - Actions

    @discardableResult
    public func tap() -> TextField {
        guard waitForExistence() else {
            print("❌ TextField '\(identifier)' not found for tap")
            return self
        }
        print("✅ Tapping text field: \(identifier)")
        element.tap()
        return self
    }

    @discardableResult
    public func type(_ text: String) -> TextField {
        guard waitForExistence() else {
            print("❌ TextField '\(identifier)' not found for typing")
            return self
        }
        print("✅ Typing '\(text)' into text field: \(identifier)")
        element.tap()
        element.typeText(text)
        return self
    }

    @discardableResult
    public func clear() -> TextField {
        guard waitForExistence() else {
            print("❌ TextField '\(identifier)' not found for clearing")
            return self
        }
        print("✅ Clearing text field: \(identifier)")
        element.tap()

        // Get current value length
        let currentValue = value
        if !currentValue.isEmpty {
            // Delete all characters
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            element.typeText(deleteString)
        }
        return self
    }

    @discardableResult
    public func clearAndType(_ text: String) -> TextField {
        clear()
        type(text)
        return self
    }

    @discardableResult
    public func pasteText(_ text: String) -> TextField {
        guard waitForExistence() else {
            print("❌ TextField '\(identifier)' not found for pasting")
            return self
        }
        print("✅ Pasting text into text field: \(identifier)")
        element.tap()

        // Use UIPasteboard simulation
        UIPasteboard.general.string = text

        // Long press to show paste menu
        element.press(forDuration: 1.2)

        // Tap paste button
        if app.menuItems["Paste"].waitForExistence(timeout: 2) {
            app.menuItems["Paste"].tap()
        }
        return self
    }

    @discardableResult
    public func dismissKeyboard() -> TextField {
        if app.keyboards.element.exists {
            print("✅ Dismissing keyboard")
            app.keyboards.buttons["Done"].tap()
        }
        return self
    }

    @discardableResult
    public func pressReturn() -> TextField {
        print("✅ Pressing return key")
        app.keyboards.buttons["Return"].tap()
        return self
    }

    // MARK: - Verification

    @discardableResult
    public func verifyExists(timeout: TimeInterval? = nil) -> TextField {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "TextField '\(identifier)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyNotExists(timeout: TimeInterval? = nil) -> TextField {
        XCTAssertFalse(
            element.waitForExistence(timeout: timeout ?? 2),
            "TextField '\(identifier)' should not exist"
        )
        return self
    }

    @discardableResult
    public func verifyValue(_ expected: String) -> TextField {
        XCTAssertEqual(value, expected, "TextField '\(identifier)' value should be '\(expected)' but got '\(value)'")
        return self
    }

    @discardableResult
    public func verifyValueContains(_ substring: String) -> TextField {
        XCTAssertTrue(
            value.contains(substring),
            "TextField '\(identifier)' value '\(value)' should contain '\(substring)'"
        )
        return self
    }

    @discardableResult
    public func verifyPlaceholder(_ expected: String) -> TextField {
        XCTAssertEqual(
            placeholderValue,
            expected,
            "TextField '\(identifier)' placeholder should be '\(expected)'"
        )
        return self
    }

    @discardableResult
    public func verifyEmpty() -> TextField {
        XCTAssertTrue(isEmpty, "TextField '\(identifier)' should be empty but has value '\(value)'")
        return self
    }

    @discardableResult
    public func verifyNotEmpty() -> TextField {
        XCTAssertFalse(isEmpty, "TextField '\(identifier)' should not be empty")
        return self
    }

    @discardableResult
    public func verifyEnabled() -> TextField {
        XCTAssertTrue(isEnabled, "TextField '\(identifier)' should be enabled")
        return self
    }

    @discardableResult
    public func verifyDisabled() -> TextField {
        XCTAssertFalse(isEnabled, "TextField '\(identifier)' should be disabled")
        return self
    }

    // MARK: - Screenshot

    @discardableResult
    public func takeScreenshot(name: String? = nil) -> TextField {
        let screenshotName = name ?? "textfield_\(identifier)"
        let screenshot = element.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = screenshotName
        attachment.lifetime = .keepAlways
        XCTContext.runActivity(named: "Screenshot: \(screenshotName)") { activity in
            activity.add(attachment)
        }
        return self
    }
}
