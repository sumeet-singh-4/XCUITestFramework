//
//  Button.swift
//  XCUITestFramework
//
//  Reusable Button component with common button interactions
//

import Foundation
import XCTest

/// Reusable Button component for common button interactions
public class Button {

    // MARK: - Properties

    private let element: XCUIElement
    private let identifier: String
    private let timeout: TimeInterval

    // MARK: - Initialization

    public init(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        self.identifier = identifier
        self.element = app.buttons[identifier]
        self.timeout = timeout
    }

    public init(element: XCUIElement, timeout: TimeInterval = 10) {
        self.element = element
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

    public func waitToDisappear(timeout: TimeInterval? = nil) -> Bool {
        return !element.waitForExistence(timeout: timeout ?? self.timeout)
    }

    // MARK: - State

    public var isEnabled: Bool {
        return element.isEnabled
    }

    public var isHittable: Bool {
        return element.isHittable
    }

    public var isSelected: Bool {
        return element.isSelected
    }

    public var label: String {
        return element.label
    }

    public var title: String {
        return element.title
    }

    // MARK: - Actions

    @discardableResult
    public func tap() -> Button {
        guard waitForExistence() else {
            print("❌ Button '\(identifier)' not found for tap")
            return self
        }
        print("✅ Tapping button: \(identifier)")
        element.tap()
        return self
    }

    @discardableResult
    public func doubleTap() -> Button {
        guard waitForExistence() else {
            print("❌ Button '\(identifier)' not found for double tap")
            return self
        }
        print("✅ Double tapping button: \(identifier)")
        element.doubleTap()
        return self
    }

    @discardableResult
    public func longPress(duration: TimeInterval = 1.0) -> Button {
        guard waitForExistence() else {
            print("❌ Button '\(identifier)' not found for long press")
            return self
        }
        print("✅ Long pressing button: \(identifier) for \(duration) seconds")
        element.press(forDuration: duration)
        return self
    }

    @discardableResult
    public func twoFingerTap() -> Button {
        guard waitForExistence() else {
            print("❌ Button '\(identifier)' not found for two finger tap")
            return self
        }
        print("✅ Two finger tapping button: \(identifier)")
        element.twoFingerTap()
        return self
    }

    @discardableResult
    public func forceTap() -> Button {
        guard waitForExistence() else {
            print("❌ Button '\(identifier)' not found for force tap")
            return self
        }
        print("✅ Force tapping button: \(identifier)")
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        return self
    }

    // MARK: - Verification

    @discardableResult
    public func verifyExists(timeout: TimeInterval? = nil) -> Button {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "Button '\(identifier)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyNotExists(timeout: TimeInterval? = nil) -> Button {
        XCTAssertFalse(
            element.waitForExistence(timeout: timeout ?? 2),
            "Button '\(identifier)' should not exist"
        )
        return self
    }

    @discardableResult
    public func verifyEnabled() -> Button {
        XCTAssertTrue(isEnabled, "Button '\(identifier)' should be enabled")
        return self
    }

    @discardableResult
    public func verifyDisabled() -> Button {
        XCTAssertFalse(isEnabled, "Button '\(identifier)' should be disabled")
        return self
    }

    @discardableResult
    public func verifySelected() -> Button {
        XCTAssertTrue(isSelected, "Button '\(identifier)' should be selected")
        return self
    }

    @discardableResult
    public func verifyNotSelected() -> Button {
        XCTAssertFalse(isSelected, "Button '\(identifier)' should not be selected")
        return self
    }

    @discardableResult
    public func verifyLabel(_ expected: String) -> Button {
        XCTAssertEqual(label, expected, "Button '\(identifier)' label should be '\(expected)'")
        return self
    }

    @discardableResult
    public func verifyTitle(_ expected: String) -> Button {
        XCTAssertEqual(title, expected, "Button '\(identifier)' title should be '\(expected)'")
        return self
    }

    // MARK: - Screenshot

    @discardableResult
    public func takeScreenshot(name: String? = nil) -> Button {
        let screenshotName = name ?? "button_\(identifier)"
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
