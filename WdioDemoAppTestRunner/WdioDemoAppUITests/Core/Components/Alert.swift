//
//  Alert.swift
//  XCUITestFramework
//
//  Reusable Alert component for handling system and app alerts
//

import Foundation
import XCTest

/// Reusable Alert component for handling alerts
public class Alert {

    // MARK: - Properties

    private let app: XCUIApplication
    private let timeout: TimeInterval

    private var springboardApp: XCUIApplication {
        return XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    // MARK: - Initialization

    public init(app: XCUIApplication, timeout: TimeInterval = 5) {
        self.app = app
        self.timeout = timeout
    }

    // MARK: - Existence

    public var exists: Bool {
        return app.alerts.element.exists || springboardApp.alerts.element.exists
    }

    public func waitForExistence(timeout: TimeInterval? = nil) -> Bool {
        let waitTime = timeout ?? self.timeout
        return app.alerts.element.waitForExistence(timeout: waitTime) ||
               springboardApp.alerts.element.waitForExistence(timeout: waitTime)
    }

    // MARK: - Properties

    public var title: String {
        if app.alerts.element.exists {
            return app.alerts.element.label
        } else if springboardApp.alerts.element.exists {
            return springboardApp.alerts.element.label
        }
        return ""
    }

    public var message: String {
        if app.alerts.element.exists {
            return app.alerts.element.staticTexts.element(boundBy: 1).label
        } else if springboardApp.alerts.element.exists {
            return springboardApp.alerts.element.staticTexts.element(boundBy: 1).label
        }
        return ""
    }

    // MARK: - Actions

    @discardableResult
    public func accept() -> Alert {
        guard waitForExistence() else {
            print("❌ Alert not found to accept")
            return self
        }
        print("✅ Accepting alert")

        // Try common acceptance buttons
        let acceptButtons = ["OK", "Allow", "Yes", "Continue", "Accept", "Confirm"]

        for buttonTitle in acceptButtons {
            if tapButton(buttonTitle) {
                return self
            }
        }

        // Fallback: tap first button
        if app.alerts.buttons.element(boundBy: 0).exists {
            app.alerts.buttons.element(boundBy: 0).tap()
        } else if springboardApp.alerts.buttons.element(boundBy: 0).exists {
            springboardApp.alerts.buttons.element(boundBy: 0).tap()
        }

        return self
    }

    @discardableResult
    public func dismiss() -> Alert {
        guard waitForExistence() else {
            print("❌ Alert not found to dismiss")
            return self
        }
        print("✅ Dismissing alert")

        // Try common dismissal buttons
        let dismissButtons = ["Cancel", "No", "Dismiss", "Close", "Don't Allow"]

        for buttonTitle in dismissButtons {
            if tapButton(buttonTitle) {
                return self
            }
        }

        // Fallback: tap last button
        if app.alerts.buttons.count > 0 {
            app.alerts.buttons.element(boundBy: app.alerts.buttons.count - 1).tap()
        } else if springboardApp.alerts.buttons.count > 0 {
            springboardApp.alerts.buttons.element(boundBy: springboardApp.alerts.buttons.count - 1).tap()
        }

        return self
    }

    @discardableResult
    public func tapButton(_ buttonTitle: String) -> Bool {
        if app.alerts.buttons[buttonTitle].exists {
            print("✅ Tapping alert button: \(buttonTitle)")
            app.alerts.buttons[buttonTitle].tap()
            return true
        } else if springboardApp.alerts.buttons[buttonTitle].exists {
            print("✅ Tapping springboard alert button: \(buttonTitle)")
            springboardApp.alerts.buttons[buttonTitle].tap()
            return true
        }
        return false
    }

    // MARK: - Permission Alerts

    @discardableResult
    public func allowPermission() -> Alert {
        guard waitForExistence(timeout: 3) else {
            return self
        }

        let allowButtons = [
            "Allow",
            "Allow Once",
            "Allow While Using App",
            "Always Allow",
            "OK"
        ]

        for button in allowButtons {
            if tapButton(button) {
                return self
            }
        }

        return self
    }

    @discardableResult
    public func denyPermission() -> Alert {
        guard waitForExistence(timeout: 3) else {
            return self
        }

        let denyButtons = [
            "Don't Allow",
            "Deny",
            "Not Now",
            "Cancel"
        ]

        for button in denyButtons {
            if tapButton(button) {
                return self
            }
        }

        return self
    }

    // MARK: - Verification

    @discardableResult
    public func verifyExists(timeout: TimeInterval? = nil) -> Alert {
        XCTAssertTrue(waitForExistence(timeout: timeout), "Alert should exist")
        return self
    }

    @discardableResult
    public func verifyNotExists(timeout: TimeInterval? = nil) -> Alert {
        XCTAssertFalse(
            app.alerts.element.waitForExistence(timeout: timeout ?? 2),
            "Alert should not exist"
        )
        return self
    }

    @discardableResult
    public func verifyTitle(_ expected: String) -> Alert {
        XCTAssertEqual(title, expected, "Alert title should be '\(expected)'")
        return self
    }

    @discardableResult
    public func verifyMessage(_ expected: String) -> Alert {
        XCTAssertEqual(message, expected, "Alert message should be '\(expected)'")
        return self
    }

    @discardableResult
    public func verifyButtonExists(_ buttonTitle: String) -> Alert {
        let exists = app.alerts.buttons[buttonTitle].exists ||
                     springboardApp.alerts.buttons[buttonTitle].exists
        XCTAssertTrue(exists, "Alert button '\(buttonTitle)' should exist")
        return self
    }

    // MARK: - Screenshot

    @discardableResult
    public func takeScreenshot(name: String = "alert") -> Alert {
        if app.alerts.element.exists {
            let screenshot = app.alerts.element.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = name
            attachment.lifetime = .keepAlways
            XCTContext.runActivity(named: "Screenshot: \(name)") { activity in
                activity.add(attachment)
            }
        }
        return self
    }
}
