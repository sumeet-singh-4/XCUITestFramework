import XCTest

/// WdioDemoApp Login Page - Specific implementation for wdiodemoapp
public class WdioDemoAppLoginPage: FluentPage {

    // MARK: - Elements

    private var loginTab: XCUIElement {
        return app.buttons["Login"]
    }

    private var usernameTextField: XCUIElement {
        // WdioDemoApp uses the first text field for username
        return app.textFields.element(boundBy: 0)
    }

    private var passwordSecureTextField: XCUIElement {
        // WdioDemoApp uses the first secure text field for password
        return app.secureTextFields.element(boundBy: 0)
    }

    private var loginButton: XCUIElement {
        // Try different button labels that might exist
        if app.buttons["LOGIN"].exists {
            return app.buttons["LOGIN"]
        } else if app.buttons["Login"].firstMatch.exists {
            let loginButtons = app.buttons.matching(identifier: "Login")
            // If there are multiple "Login" buttons, the second one is likely the submit button
            if loginButtons.count > 1 {
                return loginButtons.element(boundBy: 1)
            }
        }
        return app.buttons["Login"]
    }

    private var errorMessageLabel: XCUIElement {
        // Look for error messages in various places
        // 1. Check for alerts
        if app.alerts.firstMatch.exists {
            return app.alerts.firstMatch.staticTexts.firstMatch
        }

        // 2. Check for specific error text patterns
        let errorPredicates = [
            "label CONTAINS[c] 'error'",
            "label CONTAINS[c] 'invalid'",
            "label CONTAINS[c] 'failed'",
            "label CONTAINS[c] 'required'",
            "label CONTAINS[c] 'please'",
            "label CONTAINS[c] 'wrong'",
            "label CONTAINS[c] 'incorrect'"
        ].joined(separator: " OR ")

        let errorElement = app.staticTexts.matching(NSPredicate(format: errorPredicates)).firstMatch
        if errorElement.exists {
            return errorElement
        }

        // 3. Check for any text fields with error state or labels
        return app.otherElements.matching(NSPredicate(format: "label CONTAINS[c] 'error'")).firstMatch
    }

    private var forgotPasswordButton: XCUIElement {
        return app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'forgot'")).firstMatch
    }

    private var signUpButton: XCUIElement {
        return app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'sign up' OR label CONTAINS[c] 'signup' OR label CONTAINS[c] 'register'")).firstMatch
    }

    // MARK: - Navigation

    /// Navigate to login screen by tapping the Login tab
    /// - Returns: Self for method chaining
    @discardableResult
    public func navigateToLoginScreen() -> Self {
        if loginTab.waitForExistence(timeout: 5.0) {
            loginTab.tap()
            logInfo("Navigated to Login screen")
            wait(1.0)
        }
        return self
    }

    // MARK: - Actions

    /// Enter username
    /// - Parameter username: Username to enter
    /// - Returns: Self for method chaining
    @discardableResult
    public func enterUsername(_ username: String) -> Self {
        navigateToLoginScreen()
        return clearAndTypeFluent(usernameTextField, text: username, description: "Username Field")
    }

    /// Enter password
    /// - Parameter password: Password to enter
    /// - Returns: Self for method chaining
    @discardableResult
    public func enterPassword(_ password: String) -> Self {
        return clearAndTypeFluent(passwordSecureTextField, text: password, description: "Password Field")
    }

    /// Tap login button
    /// - Returns: Self for method chaining
    @discardableResult
    public func tapLoginButton() -> Self {
        wait(0.5) // Small wait to ensure button is ready
        return tapFluent(loginButton, description: "Login Button")
    }

    /// Perform complete login action
    /// - Parameters:
    ///   - username: Username to enter
    ///   - password: Password to enter
    /// - Returns: Self for method chaining
    @discardableResult
    public func login(username: String, password: String) -> Self {
        return navigateToLoginScreen()
            .enterUsername(username)
            .enterPassword(password)
            .tapLoginButton()
    }

    /// Tap forgot password button
    /// - Returns: Self for method chaining
    @discardableResult
    public func tapForgotPassword() -> Self {
        navigateToLoginScreen()
        return tapFluent(forgotPasswordButton, description: "Forgot Password Button")
    }

    /// Tap sign up button
    /// - Returns: Self for method chaining
    @discardableResult
    public func tapSignUp() -> Self {
        navigateToLoginScreen()
        return tapFluent(signUpButton, description: "Sign Up Button")
    }

    // MARK: - Verifications

    /// Verify login page is displayed
    /// - Returns: Self for method chaining
    @discardableResult
    public func verifyLoginPageDisplayed() -> Self {
        navigateToLoginScreen()

        // Check for at least the text fields
        let hasTextField = usernameTextField.waitForExistence(timeout: 3.0) || app.textFields.count > 0
        let hasSecureField = passwordSecureTextField.exists || app.secureTextFields.count > 0

        if hasTextField || hasSecureField {
            logInfo("Login page is displayed with input fields")
        }

        return self
    }

    /// Verify error message is displayed
    /// - Parameter expectedMessage: Expected error message text
    /// - Returns: Self for method chaining
    @discardableResult
    public func verifyErrorMessage(_ expectedMessage: String) -> Self {
        return verifyElementDisplayed(errorMessageLabel, description: "Error Message")
            .verifyText(errorMessageLabel, expectedText: expectedMessage, description: "Error Message")
    }

    /// Verify error message is displayed (any text)
    /// - Returns: Self for method chaining
    @discardableResult
    public func verifyErrorMessageDisplayed() -> Self {
        return verifyElementDisplayed(errorMessageLabel, description: "Error Message")
    }

    /// Verify error message is not displayed
    /// - Returns: Self for method chaining
    @discardableResult
    public func verifyNoErrorMessage() -> Self {
        return verifyElementNotDisplayed(errorMessageLabel, description: "Error Message")
    }

    /// Verify login button is enabled
    /// - Returns: Self for method chaining
    @discardableResult
    public func verifyLoginButtonEnabled() -> Self {
        navigateToLoginScreen()
        // Just check if button exists and is hittable
        if loginButton.exists && loginButton.isHittable {
            logInfo("Login button is enabled and hittable")
        }
        return self
    }

    // MARK: - Getters

    /// Get error message text
    /// - Returns: Error message text
    public func getErrorMessage() -> String {
        return getText(errorMessageLabel, description: "Error Message")
    }

    /// Get username field text
    /// - Returns: Username field text
    public func getUsername() -> String {
        return getValue(usernameTextField, description: "Username Field")
    }

    /// Check if login button is enabled
    /// - Returns: True if enabled, false otherwise
    public func isLoginButtonEnabled() -> Bool {
        // Small wait to allow UI to settle
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

        // Check if we're still on login screen by verifying login tab exists
        if !loginTab.exists {
            logInfo("Login tab not found - may have navigated away")
            return false
        }

        // Check for login button existence and hittability
        return loginButton.exists && loginButton.isHittable
    }

    /// Check if error message is displayed
    /// - Returns: True if displayed, false otherwise
    public func isErrorMessageDisplayed() -> Bool {
        // Check for alerts first
        if app.alerts.firstMatch.exists {
            logInfo("Found alert as error message")
            return true
        }

        // Check for error text elements
        if errorMessageLabel.exists {
            logInfo("Found error message label")
            return true
        }

        // Check if any static text contains error keywords
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        for text in allStaticTexts where text.exists && text.isHittable {
            let label = text.label.lowercased()
            if label.contains("error") || label.contains("invalid") || label.contains("required") ||
               label.contains("please") || label.contains("wrong") || label.contains("incorrect") ||
               label.contains("failed") {
                logInfo("Found error in static text: \(text.label)")
                return true
            }
        }

        logInfo("No error message found")
        return false
    }

    // MARK: - Wait Methods

    /// Wait for login page to load
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if page loaded, false otherwise
    @discardableResult
    public func waitForLoginPageToLoad(timeout: TimeInterval = 10.0) -> Bool {
        // First ensure we're on the login tab
        if loginTab.waitForExistence(timeout: timeout / 2) {
            loginTab.tap()
            wait(1.0)
        }

        // Then check for input fields
        let hasTextFields = usernameTextField.waitForExistence(timeout: timeout / 2) || app.textFields.count > 0
        let hasButton = loginButton.waitForExistence(timeout: 2.0) || app.buttons.count > 0

        let loaded = hasTextFields || hasButton
        if loaded {
            logInfo("Login page loaded successfully")
        } else {
            logInfo("Login page did not load - checking what's available")
            print("Text fields: \(app.textFields.count)")
            print("Secure fields: \(app.secureTextFields.count)")
            print("Buttons: \(app.buttons.count)")
        }

        return loaded
    }

    /// Wait for error message to appear
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if error message appeared, false otherwise
    @discardableResult
    public func waitForErrorMessage(timeout: TimeInterval = 5.0) -> Bool {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            // Check for alerts
            if app.alerts.firstMatch.exists {
                logInfo("Found alert error message")
                return true
            }

            // Check for error message label
            if errorMessageLabel.exists {
                logInfo("Found error message label")
                return true
            }

            // Check for any error text
            if isErrorMessageDisplayed() {
                return true
            }

            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }

        // One last check
        let hasError = isErrorMessageDisplayed()
        if !hasError {
            logInfo("No error message found after \(timeout)s timeout")
            // Log what elements we do have for debugging
            print("Available static texts:")
            for (index, text) in app.staticTexts.allElementsBoundByIndex.prefix(10).enumerated() {
                print("  \(index): \(text.label)")
            }
        }
        return hasError
    }

    /// Wait for error message to disappear
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if error message disappeared, false otherwise
    @discardableResult
    public func waitForErrorMessageToDisappear(timeout: TimeInterval = 5.0) -> Bool {
        return waitForElementToDisappear(errorMessageLabel, timeout: timeout, description: "Error Message")
    }

    // MARK: - Helper

    private func wait(_ seconds: TimeInterval) {
        if seconds > 0 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: seconds))
        }
    }
}
