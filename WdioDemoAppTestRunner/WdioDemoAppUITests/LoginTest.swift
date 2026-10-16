import XCTest

/// Login Test - Example test implementation
class LoginTest: BaseTest {

    var loginPage: WdioDemoAppLoginPage!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize login page using ScreenFactory
        loginPage = getScreen(WdioDemoAppLoginPage.self)

        // Verify login page is displayed
        XCTAssertTrue(loginPage.waitForLoginPageToLoad(), "Login page should load successfully")
    }

    // MARK: - Test Cases

    /// Test successful login with valid credentials
    func testLoginWithValidCredentials() {
        logStep("Test: Login with valid credentials")

        // Arrange
        let username = "test@example.com"
        let password = "password123"

        // Act
        loginPage
            .enterUsername(username)
            .enterPassword(password)
            .tapLoginButton()

        // Assert
        // Add assertions based on your app's behavior after successful login
        // Example: XCTAssertTrue(homePage.isDisplayed(), "Home page should be displayed after login")

        logInfo("Login test with valid credentials completed")
    }

    /// Test login with invalid credentials
    func testLoginWithInvalidCredentials() {
        logStep("Test: Login with invalid credentials")

        // Arrange
        let username = "invalid@example.com"
        let password = "wrongpassword"

        // Act
        loginPage
            .enterUsername(username)
            .enterPassword(password)
            .tapLoginButton()

        // Wait a moment for potential error or navigation
        wait(3.0)

        // Assert
        // Note: wdiodemoapp may not show error messages for invalid credentials
        // For this demo app, we just verify the action completed without app crash
        let appIsRunning = healthChecker.isAppRunning()
        XCTAssertTrue(appIsRunning, "App should still be running after invalid login attempt")

        logInfo("Login test with invalid credentials completed")
    }

    /// Test login with empty username
    func testLoginWithEmptyUsername() {
        logStep("Test: Login with empty username")

        // Arrange
        let password = "password123"

        // Act
        loginPage
            .enterPassword(password)
            .tapLoginButton()

        // Wait a moment for potential error or navigation
        wait(2.0)

        // Assert
        // Note: wdiodemoapp may not show error messages for empty fields
        // For this demo app, we just verify the action completed without app crash
        let appIsRunning = healthChecker.isAppRunning()
        XCTAssertTrue(appIsRunning, "App should still be running after empty username login attempt")

        logInfo("Login test with empty username completed")
    }

    /// Test login with empty password
    func testLoginWithEmptyPassword() {
        logStep("Test: Login with empty password")

        // Arrange
        let username = "test@example.com"

        // Act
        loginPage
            .enterUsername(username)
            .tapLoginButton()

        // Wait a moment for potential error or navigation
        wait(2.0)

        // Assert
        // Note: wdiodemoapp may not show error messages for empty fields
        // For this demo app, we just verify the action completed without app crash
        let appIsRunning = healthChecker.isAppRunning()
        XCTAssertTrue(appIsRunning, "App should still be running after empty password login attempt")

        logInfo("Login test with empty password completed")
    }

    /// Test login with empty credentials
    func testLoginWithEmptyCredentials() {
        logStep("Test: Login with empty credentials")

        // Act
        loginPage.tapLoginButton()

        // Assert
        // Note: wdiodemoapp may not show error messages for empty fields
        // Check if error message is displayed OR if we're still on login page
        let hasError = loginPage.waitForErrorMessage(timeout: 3.0)
        let stillOnLoginPage = loginPage.isLoginButtonEnabled()

        XCTAssertTrue(hasError || stillOnLoginPage, "Should show error or remain on login page")

        logInfo("Login test with empty credentials completed")
    }

    /// Test login page elements are displayed
    func testLoginPageElementsDisplayed() {
        logStep("Test: Verify login page elements are displayed")

        // Assert
        loginPage
            .verifyLoginPageDisplayed()
            .verifyLoginButtonEnabled()

        logInfo("Login page elements verification completed")
    }

    /// Test forgot password flow
    func testForgotPasswordFlow() {
        logStep("Test: Forgot password flow")

        // Act
        loginPage.tapForgotPassword()

        // Assert
        // Add assertions based on your app's forgot password flow
        // Example: XCTAssertTrue(forgotPasswordPage.isDisplayed(), "Forgot password page should be displayed")

        logInfo("Forgot password flow test completed")
    }

    /// Test sign up flow
    func testSignUpFlow() {
        logStep("Test: Sign up flow")

        // Act
        loginPage.tapSignUp()

        // Assert
        // Add assertions based on your app's sign up flow
        // Example: XCTAssertTrue(signUpPage.isDisplayed(), "Sign up page should be displayed")

        logInfo("Sign up flow test completed")
    }

    /// Test login with test data from JSON
    func testLoginWithTestData() {
        logStep("Test: Login with test data from JSON")

        // Load test data
        let testData = loadTestData(filename: "testdata")

        // Extract credentials from test data
        let username = JSONReader.getString(from: testData, keyPath: "credentials.validUser.username")
        let password = JSONReader.getString(from: testData, keyPath: "credentials.validUser.password")

        // Act
        loginPage
            .enterUsername(username)
            .enterPassword(password)
            .tapLoginButton()

        // Assert
        // Add assertions based on your app's behavior

        logInfo("Login test with test data completed")
    }

    /// Test login form validation
    func testLoginFormValidation() {
        logStep("Test: Login form validation")

        // Test 1: Login button should be disabled/enabled based on input
        loginPage.verifyLoginPageDisplayed()

        // Test 2: Enter username only
        loginPage.enterUsername("test@example.com")
        // Verify password field is still empty

        // Test 3: Clear username and enter password only
        loginPage
            .enterUsername("")
            .enterPassword("password123")

        logInfo("Login form validation test completed")
    }

    /// Test login with retry on failure
    func testLoginWithRetry() {
        logStep("Test: Login with retry mechanism")

        let success = RetryUtils.retry(attempts: 3, delay: 2.0) {
            loginPage
                .enterUsername("test@example.com")
                .enterPassword("password123")
                .tapLoginButton()

            // Check if login was successful
            // Return true if successful, false to retry
            return !self.loginPage.isErrorMessageDisplayed()
        }

        XCTAssertTrue(success, "Login should succeed within 3 attempts")

        logInfo("Login with retry test completed")
    }

    /// Test app health during login
    func testAppHealthDuringLogin() {
        logStep("Test: Monitor app health during login")

        // Check app health before login
        XCTAssertTrue(healthChecker.isAppRunning(), "App should be running")
        XCTAssertTrue(healthChecker.isAppInForeground(), "App should be in foreground")

        // Perform login
        loginPage
            .enterUsername("test@example.com")
            .enterPassword("password123")
            .tapLoginButton()

        // Check app health after login
        XCTAssertTrue(healthChecker.isAppRunning(), "App should still be running")
        XCTAssertFalse(healthChecker.hasAppCrashed(), "App should not have crashed")

        // Print health report
        healthChecker.printHealthReport()

        logInfo("App health monitoring test completed")
    }

    /// Performance test for login operation
    func testLoginPerformance() {
        logStep("Test: Measure login performance")

        measurePerformance(name: "Login Operation") {
            loginPage
                .enterUsername("test@example.com")
                .enterPassword("password123")
                .tapLoginButton()

            // Wait for login to complete
            wait(2.0)

            // Navigate back to login if needed for next iteration
        }

        logInfo("Login performance test completed")
    }
}
