//
//  Label.swift
//  XCUITestFramework
//
//  Reusable Label component for text verification
//

import Foundation
import XCTest

/// Reusable Label component for static text interactions
public class Label {

    // MARK: - Properties

    private let element: XCUIElement
    private let identifier: String
    private let timeout: TimeInterval

    // MARK: - Initialization

    public init(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        self.identifier = identifier
        self.element = app.staticTexts[identifier]
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

    public var text: String {
        return element.label
    }

    public var value: String {
        return element.value as? String ?? ""
    }

    public var isEnabled: Bool {
        return element.isEnabled
    }

    // MARK: - Actions

    @discardableResult
    public func tap() -> Label {
        guard waitForExistence() else {
            print("❌ Label '\(identifier)' not found for tap")
            return self
        }
        print("✅ Tapping label: \(identifier)")
        element.tap()
        return self
    }

    // MARK: - Verification

    @discardableResult
    public func verifyExists(timeout: TimeInterval? = nil) -> Label {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "Label '\(identifier)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyNotExists(timeout: TimeInterval? = nil) -> Label {
        XCTAssertFalse(
            element.waitForExistence(timeout: timeout ?? 2),
            "Label '\(identifier)' should not exist"
        )
        return self
    }

    @discardableResult
    public func verifyText(_ expected: String) -> Label {
        XCTAssertEqual(text, expected, "Label '\(identifier)' text should be '\(expected)' but got '\(text)'")
        return self
    }

    @discardableResult
    public func verifyTextContains(_ substring: String) -> Label {
        XCTAssertTrue(
            text.contains(substring),
            "Label '\(identifier)' text '\(text)' should contain '\(substring)'"
        )
        return self
    }

    @discardableResult
    public func verifyTextStartsWith(_ prefix: String) -> Label {
        XCTAssertTrue(
            text.hasPrefix(prefix),
            "Label '\(identifier)' text '\(text)' should start with '\(prefix)'"
        )
        return self
    }

    @discardableResult
    public func verifyTextEndsWith(_ suffix: String) -> Label {
        XCTAssertTrue(
            text.hasSuffix(suffix),
            "Label '\(identifier)' text '\(text)' should end with '\(suffix)'"
        )
        return self
    }

    @discardableResult
    public func verifyTextMatches(regex: String) -> Label {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        XCTAssertTrue(
            predicate.evaluate(with: text),
            "Label '\(identifier)' text '\(text)' should match regex '\(regex)'"
        )
        return self
    }

    @discardableResult
    public func verifyValue(_ expected: String) -> Label {
        XCTAssertEqual(value, expected, "Label '\(identifier)' value should be '\(expected)'")
        return self
    }

    // MARK: - Screenshot

    @discardableResult
    public func takeScreenshot(name: String? = nil) -> Label {
        let screenshotName = name ?? "label_\(identifier)"
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
