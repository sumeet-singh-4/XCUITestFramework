import XCTest

/// Login Page - Example implementation of FluentPage
public class LoginPage: FluentPage {

    // MARK: - Elements

    private var usernameTextField: XCUIElement {
        return app.textFields["usernameTextField"]
    }

    private var passwordSecureTextField: XCUIElement {
        return app.secureTextFields["passwordTextField"]
    }

    private var loginButton: XCUIElement {
        return app.buttons["loginButton"]
    }

    private var errorMessageLabel: XCUIElement {
        return app.staticTexts["errorMessage"]
    }

    private var forgotPasswordButton: XCUIElement {
        return app.buttons["forgotPasswordButton"]
    }

    private var signUpButton: XCUIElement {
        return app.buttons["signUpButton"]
    }

    private var showPasswordButton: XCUIElement {
        return app.buttons["showPasswordButton"]
    }

    // MARK: - Actions

    /// Enter username
    /// - Parameter username: Username to enter
    /// - Returns: Self for method chaining
    @discardableResult
    public func enterUsername(_ username: String) -> Self {
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
        return tapFluent(loginButton, description: "Login Button")
    }

    /// Perform complete login action
    /// - Parameters:
    ///   - username: Username to enter
    ///   - password: Password to enter
    /// - Returns: Self for method chaining
    @discardableResult
    public func login(username: String, password: String) -> Self {
        return enterUsername(username)
            .enterPassword(password)
            .tapLoginButton()
    }

    /// Tap forgot password button
    /// - Returns: Self for method chaining
    @discardableResult
    public func tapForgotPassword() -> Self {
        return tapFluent(forgotPasswordButton, description: "Forgot Password Button")
    }

    /// Tap sign up button
    /// - Returns: Self for method chaining
    @discardableResult
    public func tapSignUp() -> Self {
        return tapFluent(signUpButton, description: "Sign Up Button")
    }

    /// Tap show password button
    /// - Returns: Self for method chaining
    @discardableResult
    public func tapShowPassword() -> Self {
        return tapFluent(showPasswordButton, description: "Show Password Button")
    }

    // MARK: - Verifications

    /// Verify login page is displayed
    /// - Returns: Self for method chaining
    @discardableResult
    public func verifyLoginPageDisplayed() -> Self {
        return verifyElementDisplayed(usernameTextField, description: "Username Field")
            .verifyElementDisplayed(passwordSecureTextField, description: "Password Field")
            .verifyElementDisplayed(loginButton, description: "Login Button")
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
        return verifyElementEnabled(loginButton, description: "Login Button")
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
        return isEnabled(loginButton, description: "Login Button")
    }

    /// Check if error message is displayed
    /// - Returns: True if displayed, false otherwise
    public func isErrorMessageDisplayed() -> Bool {
        return isDisplayed(errorMessageLabel, description: "Error Message")
    }

    // MARK: - Wait Methods

    /// Wait for login page to load
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if page loaded, false otherwise
    @discardableResult
    public func waitForLoginPageToLoad(timeout: TimeInterval = 10.0) -> Bool {
        return waitForElement(loginButton, timeout: timeout, description: "Login Button")
    }

    /// Wait for error message to appear
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if error message appeared, false otherwise
    @discardableResult
    public func waitForErrorMessage(timeout: TimeInterval = 5.0) -> Bool {
        return waitForElement(errorMessageLabel, timeout: timeout, description: "Error Message")
    }

    /// Wait for error message to disappear
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if error message disappeared, false otherwise
    @discardableResult
    public func waitForErrorMessageToDisappear(timeout: TimeInterval = 5.0) -> Bool {
        return waitForElementToDisappear(errorMessageLabel, timeout: timeout, description: "Error Message")
    }
}
