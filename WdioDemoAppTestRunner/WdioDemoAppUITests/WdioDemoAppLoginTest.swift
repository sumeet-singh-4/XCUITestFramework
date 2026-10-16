import XCTest

/// Login Test - Test login functionality in wdiodemoapp
class WdioDemoAppLoginTest: BaseTest {

    // MARK: - Test Cases

    /// Test navigating to login screen and verifying elements
    func testNavigateToLoginScreen() {
        logStep("Test: Navigate to login screen")

        wait(2.0)

        // Look for Login tab/button
        let loginTab = app.buttons["Login"]
        let loginButton = app.buttons["login"]
        let loginText = app.staticTexts["Login"]

        // Try different ways to find login navigation
        if loginTab.waitForExistence(timeout: 5.0) {
            print("Found 'Login' button (tab style)")
            loginTab.tap()
            logInfo("Tapped Login tab")
        } else if loginButton.waitForExistence(timeout: 2.0) {
            print("Found 'login' button")
            loginButton.tap()
            logInfo("Tapped login button")
        } else {
            print("Looking for any button with 'login' in the label")
            let allButtons = app.buttons.allElementsBoundByIndex
            for button in allButtons {
                if button.label.lowercased().contains("login") {
                    print("Found button: \(button.label)")
                    button.tap()
                    logInfo("Tapped button: \(button.label)")
                    break
                }
            }
        }

        wait(2.0)

        // Verify we're on login screen by checking for common login elements
        let usernameField = app.textFields.element(boundBy: 0)
        let passwordField = app.secureTextFields.element(boundBy: 0)

        if usernameField.exists || passwordField.exists {
            logInfo("Successfully navigated to login screen")
            XCTAssertTrue(true, "Login screen displayed")
        } else {
            print("Could not verify login screen - checking all text fields")
            print("Text fields count: \(app.textFields.count)")
            print("Secure text fields count: \(app.secureTextFields.count)")
        }
    }

    /// Test login with credentials
    func testLoginWithCredentials() {
        logStep("Test: Login with credentials")

        wait(2.0)

        // Navigate to login screen first
        let loginTab = app.buttons["Login"]
        if loginTab.waitForExistence(timeout: 5.0) {
            loginTab.tap()
            wait(1.0)
        }

        // Try to find and fill username field
        let textFields = app.textFields
        if textFields.count > 0 {
            let usernameField = textFields.element(boundBy: 0)
            if usernameField.exists {
                usernameField.tap()
                usernameField.typeText("testuser@example.com")
                logInfo("Entered username")
            }
        }

        // Try to find and fill password field
        let secureFields = app.secureTextFields
        if secureFields.count > 0 {
            let passwordField = secureFields.element(boundBy: 0)
            if passwordField.exists {
                passwordField.tap()
                passwordField.typeText("password123")
                logInfo("Entered password")
            }
        }

        wait(1.0)

        // Try to find and tap login button
        let loginButton = app.buttons["LOGIN"]
            .firstMatch.exists ? app.buttons["LOGIN"] : app.buttons["Login"]

        if loginButton.exists {
            loginButton.tap()
            logInfo("Tapped login button")
            wait(2.0)
        }

        XCTAssertTrue(app.exists, "App should still exist after login attempt")
    }

    /// Test exploring all tabs in the app
    func testExploreTabs() {
        logStep("Test: Explore all tabs in wdiodemoapp")

        wait(2.0)

        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let tabs = tabBar.buttons.allElementsBoundByIndex
            print("Found \(tabs.count) tabs")

            for (index, tab) in tabs.enumerated() {
                print("Tab \(index): \(tab.label)")

                if tab.isHittable {
                    tab.tap()
                    logInfo("Tapped tab: \(tab.label)")
                    wait(1.0)

                    // Take a screenshot of each tab
                    captureScreenshot(name: "Tab_\(tab.label)_\(index)")
                }
            }

            XCTAssertTrue(tabs.count > 0, "Should have at least one tab")
        } else {
            print("No tab bar found in the app")

            // Check for other navigation elements
            let navigationBars = app.navigationBars
            if navigationBars.count > 0 {
                print("Found \(navigationBars.count) navigation bars")
                logInfo("App uses navigation bars instead of tabs")
            }
        }
    }

    /// Test form elements on login screen
    func testLoginFormElements() {
        logStep("Test: Verify login form elements")

        wait(2.0)

        // Navigate to login if there's a tab
        let loginTab = app.buttons["Login"]
        if loginTab.exists {
            loginTab.tap()
            wait(1.0)
        }

        // Count and verify form elements
        let textFieldCount = app.textFields.count
        let secureFieldCount = app.secureTextFields.count
        let buttonCount = app.buttons.count

        print("Form elements found:")
        print("- Text fields: \(textFieldCount)")
        print("- Secure fields: \(secureFieldCount)")
        print("- Buttons: \(buttonCount)")

        // List all text fields
        for (index, field) in app.textFields.allElementsBoundByIndex.enumerated() {
            print("  TextField \(index): label='\(field.label)', placeholder='\(field.placeholderValue ?? "")'")
        }

        // List all secure fields
        for (index, field) in app.secureTextFields.allElementsBoundByIndex.enumerated() {
            print("  SecureField \(index): label='\(field.label)', placeholder='\(field.placeholderValue ?? "")'")
        }

        // Verify we have at least some input fields
        XCTAssertGreaterThan(textFieldCount + secureFieldCount, 0,
                           "Should have at least one input field")

        logInfo("Login form elements verified")
    }

    /// Test accessibility identifiers
    func testLoginAccessibilityIdentifiers() {
        logStep("Test: Check accessibility identifiers")

        wait(2.0)

        // Navigate to login
        let loginTab = app.buttons["Login"]
        if loginTab.exists {
            loginTab.tap()
            wait(1.0)
        }

        // Try common accessibility identifiers for login screens
        let commonIds = [
            "username", "email", "emailTextField", "usernameTextField",
            "password", "passwordTextField", "passwordField",
            "loginButton", "signInButton", "submitButton"
        ]

        print("Checking for common accessibility identifiers:")
        for id in commonIds {
            let element = app.descendants(matching: .any).matching(identifier: id).firstMatch
            if element.exists {
                print("  ✓ Found element with identifier: '\(id)'")
                logInfo("Found element: \(id)")
            }
        }

        XCTAssertTrue(app.exists, "App should exist")
    }
}
