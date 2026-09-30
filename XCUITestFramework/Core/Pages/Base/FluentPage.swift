import XCTest

/// Fluent page class that supports method chaining
/// All page objects that want fluent interface should extend this class
open class FluentPage: BasePage {

    // MARK: - Fluent Element Interaction Methods

    /// Tap on an element (fluent)
    @discardableResult
    public func tapFluent(_ element: XCUIElement, description: String = "") -> Self {
        _ = tap(element, description: description)
        return self
    }

    /// Type text into an element (fluent)
    @discardableResult
    public func typeTextFluent(_ element: XCUIElement, text: String, description: String = "") -> Self {
        _ = typeText(element, text: text, description: description)
        return self
    }

    /// Clear text from an element and type new text (fluent)
    @discardableResult
    public func clearAndTypeFluent(_ element: XCUIElement, text: String, description: String = "") -> Self {
        _ = clearAndType(element, text: text, description: description)
        return self
    }

    // MARK: - Fluent Wait Methods

    /// Wait for element to exist (fluent)
    @discardableResult
    public func waitForElementFluent(_ element: XCUIElement, timeout: TimeInterval? = nil, description: String = "") -> Self {
        _ = waitForElement(element, timeout: timeout, description: description)
        return self
    }

    /// Wait for element to disappear (fluent)
    @discardableResult
    public func waitForElementToDisappearFluent(_ element: XCUIElement, timeout: TimeInterval? = nil, description: String = "") -> Self {
        _ = waitForElementToDisappear(element, timeout: timeout, description: description)
        return self
    }

    /// Wait for element to be hittable (fluent)
    @discardableResult
    public func waitForElementToBeHittableFluent(_ element: XCUIElement, timeout: TimeInterval? = nil, description: String = "") -> Self {
        _ = waitForElementToBeHittable(element, timeout: timeout, description: description)
        return self
    }

    // MARK: - Fluent Gesture Methods

    /// Swipe up on the screen (fluent)
    @discardableResult
    public func swipeUpFluent() -> Self {
        swipeUp()
        return self
    }

    /// Swipe down on the screen (fluent)
    @discardableResult
    public func swipeDownFluent() -> Self {
        swipeDown()
        return self
    }

    /// Swipe left on the screen (fluent)
    @discardableResult
    public func swipeLeftFluent() -> Self {
        swipeLeft()
        return self
    }

    /// Swipe right on the screen (fluent)
    @discardableResult
    public func swipeRightFluent() -> Self {
        swipeRight()
        return self
    }

    /// Swipe on a specific element (fluent)
    @discardableResult
    public func swipeFluent(_ element: XCUIElement, direction: SwipeDirection, description: String = "") -> Self {
        swipe(element, direction: direction, description: description)
        return self
    }

    /// Long press on an element (fluent)
    @discardableResult
    public func longPressFluent(_ element: XCUIElement, duration: TimeInterval = 1.0, description: String = "") -> Self {
        longPress(element, duration: duration, description: description)
        return self
    }

    /// Scroll to element (fluent)
    @discardableResult
    public func scrollToElementFluent(_ element: XCUIElement, maxScrolls: Int = 10, description: String = "") -> Self {
        _ = scrollToElement(element, maxScrolls: maxScrolls, description: description)
        return self
    }

    // MARK: - Fluent Alert Handling

    /// Handle alert with button title (fluent)
    @discardableResult
    public func handleAlertFluent(buttonTitle: String, timeout: TimeInterval = 5.0) -> Self {
        _ = handleAlert(buttonTitle: buttonTitle, timeout: timeout)
        return self
    }

    // MARK: - Fluent Keyboard Methods

    /// Dismiss keyboard (fluent)
    @discardableResult
    public func dismissKeyboardFluent() -> Self {
        dismissKeyboard()
        return self
    }

    // MARK: - Fluent Verification Methods

    /// Verify element is displayed (fluent)
    @discardableResult
    public func verifyElementDisplayed(_ element: XCUIElement, description: String = "") -> Self {
        XCTAssertTrue(isDisplayed(element, description: description),
                     "Element should be displayed: \(description.isEmpty ? element.debugDescription : description)")
        return self
    }

    /// Verify element is not displayed (fluent)
    @discardableResult
    public func verifyElementNotDisplayed(_ element: XCUIElement, description: String = "") -> Self {
        XCTAssertFalse(isDisplayed(element, description: description),
                      "Element should not be displayed: \(description.isEmpty ? element.debugDescription : description)")
        return self
    }

    /// Verify element is enabled (fluent)
    @discardableResult
    public func verifyElementEnabled(_ element: XCUIElement, description: String = "") -> Self {
        XCTAssertTrue(isEnabled(element, description: description),
                     "Element should be enabled: \(description.isEmpty ? element.debugDescription : description)")
        return self
    }

    /// Verify element text equals expected (fluent)
    @discardableResult
    public func verifyText(_ element: XCUIElement, expectedText: String, description: String = "") -> Self {
        let actualText = getText(element, description: description)
        XCTAssertEqual(actualText, expectedText,
                      "Element text should be '\(expectedText)' but was '\(actualText)': \(description.isEmpty ? element.debugDescription : description)")
        return self
    }

    /// Verify element text contains expected (fluent)
    @discardableResult
    public func verifyTextContains(_ element: XCUIElement, expectedText: String, description: String = "") -> Self {
        let actualText = getText(element, description: description)
        XCTAssertTrue(actualText.contains(expectedText),
                     "Element text '\(actualText)' should contain '\(expectedText)': \(description.isEmpty ? element.debugDescription : description)")
        return self
    }

    // MARK: - Fluent Navigation Helper

    /// Wait and continue (useful for page transitions)
    @discardableResult
    public func waitAndContinue(seconds: TimeInterval) -> Self {
        Thread.sleep(forTimeInterval: seconds)
        return self
    }

    /// Log custom message (fluent)
    @discardableResult
    public func logInfoFluent(_ message: String) -> Self {
        logInfo(message)
        return self
    }
}
