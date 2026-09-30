import XCTest

/// Base page class with common interactions and wait utilities
/// All page objects should extend this class
open class BasePage {

    // MARK: - Properties

    public let app: XCUIApplication
    public let timeout: TimeInterval

    // MARK: - Initialization

    public init(app: XCUIApplication, timeout: TimeInterval = 10.0) {
        self.app = app
        self.timeout = timeout
    }

    // MARK: - Element Interaction Methods

    /// Tap on an element
    @discardableResult
    public func tap(_ element: XCUIElement, description: String = "") -> Bool {
        waitForElement(element, description: description)
        if element.exists && element.isHittable {
            element.tap()
            logAction("Tapped on element: \(description.isEmpty ? element.debugDescription : description)")
            return true
        }
        logError("Failed to tap element: \(description.isEmpty ? element.debugDescription : description)")
        return false
    }

    /// Type text into an element
    @discardableResult
    public func typeText(_ element: XCUIElement, text: String, description: String = "") -> Bool {
        waitForElement(element, description: description)
        if element.exists && element.isHittable {
            element.tap()
            element.typeText(text)
            logAction("Typed '\(text)' into element: \(description.isEmpty ? element.debugDescription : description)")
            return true
        }
        logError("Failed to type text into element: \(description.isEmpty ? element.debugDescription : description)")
        return false
    }

    /// Clear text from an element and type new text
    @discardableResult
    public func clearAndType(_ element: XCUIElement, text: String, description: String = "") -> Bool {
        waitForElement(element, description: description)
        if element.exists && element.isHittable {
            element.tap()

            // Clear existing text
            if let currentValue = element.value as? String, !currentValue.isEmpty {
                let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
                element.typeText(deleteString)
            }

            element.typeText(text)
            logAction("Cleared and typed '\(text)' into element: \(description.isEmpty ? element.debugDescription : description)")
            return true
        }
        logError("Failed to clear and type text into element: \(description.isEmpty ? element.debugDescription : description)")
        return false
    }

    /// Get text from an element
    public func getText(_ element: XCUIElement, description: String = "") -> String {
        waitForElement(element, description: description)
        if element.exists {
            let text = element.label
            logAction("Retrieved text '\(text)' from element: \(description.isEmpty ? element.debugDescription : description)")
            return text
        }
        logError("Failed to get text from element: \(description.isEmpty ? element.debugDescription : description)")
        return ""
    }

    /// Get value from an element
    public func getValue(_ element: XCUIElement, description: String = "") -> String {
        waitForElement(element, description: description)
        if element.exists, let value = element.value as? String {
            logAction("Retrieved value '\(value)' from element: \(description.isEmpty ? element.debugDescription : description)")
            return value
        }
        logError("Failed to get value from element: \(description.isEmpty ? element.debugDescription : description)")
        return ""
    }

    /// Check if element is displayed
    public func isDisplayed(_ element: XCUIElement, description: String = "") -> Bool {
        let displayed = element.exists
        logAction("Element \(description.isEmpty ? element.debugDescription : description) displayed: \(displayed)")
        return displayed
    }

    /// Check if element is enabled
    public func isEnabled(_ element: XCUIElement, description: String = "") -> Bool {
        let enabled = element.isEnabled
        logAction("Element \(description.isEmpty ? element.debugDescription : description) enabled: \(enabled)")
        return enabled
    }

    // MARK: - Wait Methods

    /// Wait for element to exist
    @discardableResult
    public func waitForElement(_ element: XCUIElement, timeout: TimeInterval? = nil, description: String = "") -> Bool {
        let waitTime = timeout ?? self.timeout
        let exists = element.waitForExistence(timeout: waitTime)
        if !exists {
            logError("Element not found within \(waitTime)s: \(description.isEmpty ? element.debugDescription : description)")
        }
        return exists
    }

    /// Wait for element to disappear
    @discardableResult
    public func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval? = nil, description: String = "") -> Bool {
        let waitTime = timeout ?? self.timeout
        let startTime = Date()

        while element.exists {
            if Date().timeIntervalSince(startTime) > waitTime {
                logError("Element still exists after \(waitTime)s: \(description.isEmpty ? element.debugDescription : description)")
                return false
            }
            Thread.sleep(forTimeInterval: 0.5)
        }

        logAction("Element disappeared: \(description.isEmpty ? element.debugDescription : description)")
        return true
    }

    /// Wait for element to be hittable
    @discardableResult
    public func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval? = nil, description: String = "") -> Bool {
        let waitTime = timeout ?? self.timeout
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: waitTime)

        if result != .completed {
            logError("Element not hittable within \(waitTime)s: \(description.isEmpty ? element.debugDescription : description)")
            return false
        }

        return true
    }

    // MARK: - Gesture Methods

    /// Swipe up on the screen
    public func swipeUp() {
        app.swipeUp()
        logAction("Swiped up")
    }

    /// Swipe down on the screen
    public func swipeDown() {
        app.swipeDown()
        logAction("Swiped down")
    }

    /// Swipe left on the screen
    public func swipeLeft() {
        app.swipeLeft()
        logAction("Swiped left")
    }

    /// Swipe right on the screen
    public func swipeRight() {
        app.swipeRight()
        logAction("Swiped right")
    }

    /// Swipe on a specific element
    public func swipe(_ element: XCUIElement, direction: SwipeDirection, description: String = "") {
        waitForElement(element, description: description)

        switch direction {
        case .up:
            element.swipeUp()
        case .down:
            element.swipeDown()
        case .left:
            element.swipeLeft()
        case .right:
            element.swipeRight()
        }

        logAction("Swiped \(direction.rawValue) on element: \(description.isEmpty ? element.debugDescription : description)")
    }

    /// Long press on an element
    public func longPress(_ element: XCUIElement, duration: TimeInterval = 1.0, description: String = "") {
        waitForElement(element, description: description)
        element.press(forDuration: duration)
        logAction("Long pressed element for \(duration)s: \(description.isEmpty ? element.debugDescription : description)")
    }

    /// Scroll to element
    @discardableResult
    public func scrollToElement(_ element: XCUIElement, maxScrolls: Int = 10, description: String = "") -> Bool {
        var scrollCount = 0

        while !element.isHittable && scrollCount < maxScrolls {
            app.swipeUp()
            scrollCount += 1
            Thread.sleep(forTimeInterval: 0.5)
        }

        if element.isHittable {
            logAction("Scrolled to element: \(description.isEmpty ? element.debugDescription : description)")
            return true
        } else {
            logError("Failed to scroll to element after \(maxScrolls) attempts: \(description.isEmpty ? element.debugDescription : description)")
            return false
        }
    }

    // MARK: - Alert Handling

    /// Handle alert with button title
    @discardableResult
    public func handleAlert(buttonTitle: String, timeout: TimeInterval = 5.0) -> Bool {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch

        if alert.waitForExistence(timeout: timeout) {
            let button = alert.buttons[buttonTitle]
            if button.exists {
                button.tap()
                logAction("Handled alert by tapping '\(buttonTitle)'")
                return true
            }
        }

        logError("Failed to handle alert with button '\(buttonTitle)'")
        return false
    }

    // MARK: - Keyboard Methods

    /// Dismiss keyboard
    public func dismissKeyboard() {
        if app.keyboards.firstMatch.exists {
            app.keyboards.buttons["Done"].tap()
            logAction("Dismissed keyboard")
        }
    }

    /// Check if keyboard is visible
    public func isKeyboardVisible() -> Bool {
        return app.keyboards.firstMatch.exists
    }

    // MARK: - Logging Methods

    private func logAction(_ message: String) {
        print("✅ [ACTION] \(message)")
    }

    private func logError(_ message: String) {
        print("❌ [ERROR] \(message)")
    }

    public func logInfo(_ message: String) {
        print("ℹ️ [INFO] \(message)")
    }
}

// MARK: - Swipe Direction Enum

public enum SwipeDirection: String {
    case up = "up"
    case down = "down"
    case left = "left"
    case right = "right"
}
