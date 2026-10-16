//
//  Switch.swift
//  XCUITestFramework
//
//  Reusable Switch component for toggle controls
//

import Foundation
import XCTest

/// Reusable Switch component for toggle interactions
public class Switch {

    // MARK: - Properties

    private let element: XCUIElement
    private let identifier: String
    private let timeout: TimeInterval

    // MARK: - Initialization

    public init(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        self.identifier = identifier
        self.element = app.switches[identifier]
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

    // MARK: - State

    public var isOn: Bool {
        return element.value as? String == "1"
    }

    public var isOff: Bool {
        return !isOn
    }

    public var isEnabled: Bool {
        return element.isEnabled
    }

    public var label: String {
        return element.label
    }

    // MARK: - Actions

    @discardableResult
    public func tap() -> Switch {
        guard waitForExistence() else {
            print("❌ Switch '\(identifier)' not found for tap")
            return self
        }
        print("✅ Tapping switch: \(identifier)")
        element.tap()
        return self
    }

    @discardableResult
    public func turnOn() -> Switch {
        guard waitForExistence() else {
            print("❌ Switch '\(identifier)' not found")
            return self
        }

        if isOff {
            print("✅ Turning ON switch: \(identifier)")
            element.tap()
        } else {
            print("ℹ️ Switch '\(identifier)' is already ON")
        }
        return self
    }

    @discardableResult
    public func turnOff() -> Switch {
        guard waitForExistence() else {
            print("❌ Switch '\(identifier)' not found")
            return self
        }

        if isOn {
            print("✅ Turning OFF switch: \(identifier)")
            element.tap()
        } else {
            print("ℹ️ Switch '\(identifier)' is already OFF")
        }
        return self
    }

    @discardableResult
    public func toggle() -> Switch {
        return tap()
    }

    @discardableResult
    public func setState(_ shouldBeOn: Bool) -> Switch {
        return shouldBeOn ? turnOn() : turnOff()
    }

    // MARK: - Verification

    @discardableResult
    public func verifyExists(timeout: TimeInterval? = nil) -> Switch {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "Switch '\(identifier)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyNotExists(timeout: TimeInterval? = nil) -> Switch {
        XCTAssertFalse(
            element.waitForExistence(timeout: timeout ?? 2),
            "Switch '\(identifier)' should not exist"
        )
        return self
    }

    @discardableResult
    public func verifyOn() -> Switch {
        XCTAssertTrue(isOn, "Switch '\(identifier)' should be ON")
        return self
    }

    @discardableResult
    public func verifyOff() -> Switch {
        XCTAssertTrue(isOff, "Switch '\(identifier)' should be OFF")
        return self
    }

    @discardableResult
    public func verifyState(_ shouldBeOn: Bool) -> Switch {
        if shouldBeOn {
            return verifyOn()
        } else {
            return verifyOff()
        }
    }

    @discardableResult
    public func verifyEnabled() -> Switch {
        XCTAssertTrue(isEnabled, "Switch '\(identifier)' should be enabled")
        return self
    }

    @discardableResult
    public func verifyDisabled() -> Switch {
        XCTAssertFalse(isEnabled, "Switch '\(identifier)' should be disabled")
        return self
    }

    @discardableResult
    public func verifyLabel(_ expected: String) -> Switch {
        XCTAssertEqual(label, expected, "Switch '\(identifier)' label should be '\(expected)'")
        return self
    }

    // MARK: - Screenshot

    @discardableResult
    public func takeScreenshot(name: String? = nil) -> Switch {
        let screenshotName = name ?? "switch_\(identifier)"
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
