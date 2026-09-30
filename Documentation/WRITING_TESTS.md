# XCUITest Framework - Writing Tests Guide

**Version:** 2.0.0
**Last Updated:** September 30, 2026

---

## 📚 Table of Contents

1. [Test Execution Flow](#test-execution-flow)
2. [Creating Your First Test](#creating-your-first-test)
3. [Creating Page Objects](#creating-page-objects)
4. [Using Components](#using-components)
5. [Data-Driven Testing](#data-driven-testing)
6. [Advanced Patterns](#advanced-patterns)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## 🔄 Test Execution Flow

### **Complete Chronological Flow**

```
┌─────────────────────────────────────────────────────────────┐
│ 1. TEST SUITE INITIALIZATION                                 │
│    • XCTest framework loads test bundle                      │
│    • Test plan configuration applied                         │
│    • Environment variables read (ENV=qa)                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. CONFIGURATION LOADING (ConfigReader)                      │
│    • Read ENV variable (default: "default")                  │
│    • Load config-{environment}.plist                         │
│    • Fallback to config.plist if not found                   │
│    • Throws ConfigurationException if errors                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. TEST CLASS INSTANTIATION                                  │
│    • Your test class (extends BaseTest) created              │
│    • BaseTest properties initialized                         │
│    • App instance created (XCUIApplication)                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. TEST LIFECYCLE - SETUP (setUp())                          │
│    │                                                          │
│    ├─> a) Listener Registration                              │
│    │      • TestLifecycleListenerManager initialized         │
│    │      • LoggingListener registered                       │
│    │      • ScreenshotListener registered                    │
│    │                                                          │
│    ├─> b) Listener Event: testSuiteWillStart()              │
│    │      • LoggingListener logs: "🏁 Test Suite Starting"  │
│    │                                                          │
│    ├─> c) Listener Event: testCaseWillStart()               │
│    │      • LoggingListener logs: "▶️  Test Starting"       │
│    │      • ScreenshotListener captures start screenshot    │
│    │                                                          │
│    ├─> d) App Launch                                         │
│    │      • XCUIApplication.launch() called                  │
│    │      • App bundle loaded                                │
│    │      • Splash screen appears                            │
│    │      • Initial screen loaded                            │
│    │                                                          │
│    ├─> e) Screen Factory Initialization                      │
│    │      • ScreenFactory.shared created                     │
│    │      • Cache initialized (empty)                        │
│    │      • Thread-safe queue configured                     │
│    │                                                          │
│    └─> f) Configuration Check                                │
│           • ConfigReader.shared.screenshotOnFailure read     │
│           • ConfigReader.shared.implicitWaitTimeout read     │
│           • Test-specific setup completed                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. TEST METHOD EXECUTION (testMyFeature())                   │
│    │                                                          │
│    ├─> a) Listener Event: testMethodWillStart()             │
│    │                                                          │
│    ├─> b) Get Page Object from Factory                       │
│    │      • let loginPage = getScreen(LoginPage.self)       │
│    │      ↓                                                   │
│    │      • ScreenFactory checks cache                       │
│    │      • If not cached: create new instance               │
│    │      • Pass app instance to page                        │
│    │      • Store in cache for reuse                         │
│    │      • Return page instance                             │
│    │                                                          │
│    ├─> c) Page Object Interaction                            │
│    │      • loginPage.enterUsername("testuser")             │
│    │      ↓                                                   │
│    │      • Method calls BasePage.type()                     │
│    │      • BasePage locates element: app.textFields["..."] │
│    │      • Waits for element existence (implicit timeout)   │
│    │      • Taps element to focus                            │
│    │      • Types text using XCUIElement.typeText()          │
│    │      • Returns self for method chaining                 │
│    │                                                          │
│    ├─> d) Component Usage (Alternative)                      │
│    │      • TextField("usernameField", in: app)             │
│    │      ↓                                                   │
│    │      • Component wraps XCUIElement                      │
│    │      • Provides fluent interface                        │
│    │      • .clearAndType("testuser")                        │
│    │      ↓                                                   │
│    │      • Component.clear() called                         │
│    │      • Component.type() called                          │
│    │      • Component.verifyValue() for safety              │
│    │      • Returns self for chaining                        │
│    │                                                          │
│    ├─> e) Verification                                        │
│    │      • loginPage.verifyDashboardLoaded()               │
│    │      ↓                                                   │
│    │      • Checks for dashboard element                     │
│    │      • Waits with explicit timeout                      │
│    │      • XCTAssertTrue() called                           │
│    │      • Test passes or fails                             │
│    │                                                          │
│    ├─> f) Exception Handling (If Error)                      │
│    │      • ElementNotFoundException thrown                  │
│    │      • Exception captures context (file:line)           │
│    │      • Exception logged with details                    │
│    │      • Test fails with meaningful error                 │
│    │                                                          │
│    └─> g) Listener Event: testMethodDidFinish()             │
│           • Result: .passed or .failed                       │
│           • LoggingListener logs: "✅ Test Finished"        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. TEST RESULT HANDLING                                      │
│    │                                                          │
│    ├─> If TEST PASSED:                                       │
│    │      • testCaseDidFinish() event fired                  │
│    │      • Duration calculated and logged                   │
│    │      • Screenshot captured (if mode: .onFinish)         │
│    │      • Continue to tearDown                             │
│    │                                                          │
│    └─> If TEST FAILED:                                       │
│           • testCaseDidFail() event fired                    │
│           • Failure details captured                         │
│           • Screenshot automatically taken                   │
│           • Video recording stopped (if enabled)             │
│           • ScreenshotUtils.captureFailureScreenshot()       │
│           • XCTAttachment created with failure context       │
│           • Continue to tearDown                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. TEST LIFECYCLE - TEARDOWN (tearDown())                    │
│    │                                                          │
│    ├─> a) Screenshot Capture (if configured)                 │
│    │      • Check screenshotOnFailure setting                │
│    │      • Capture if test failed                           │
│    │      • Attach to test results                           │
│    │                                                          │
│    ├─> b) Listener Event: testCaseDidFinish()               │
│    │      • Final result logged                              │
│    │      • Duration displayed                               │
│    │                                                          │
│    ├─> c) Resource Cleanup                                   │
│    │      • App terminated (if configured)                   │
│    │      • Screen factory cache cleared (optional)          │
│    │      • Temp files cleaned up                            │
│    │                                                          │
│    └─> d) Next Test or Suite End                             │
│           • If more tests: goto step 4                       │
│           • If suite complete: goto step 8                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. TEST SUITE COMPLETION                                     │
│    │                                                          │
│    ├─> a) Listener Event: testSuiteDidFinish()              │
│    │      • Final suite statistics                           │
│    │      • Total duration                                   │
│    │      • Pass/fail counts                                 │
│    │                                                          │
│    ├─> b) Report Generation                                  │
│    │      • XCTest result bundle (.xcresult)                 │
│    │      • HTML report (if configured)                      │
│    │      • Coverage data (if enabled)                       │
│    │      • Performance baselines updated                    │
│    │                                                          │
│    ├─> c) Artifact Collection                                │
│    │      • Screenshots archived                             │
│    │      • Videos archived                                  │
│    │      • Logs collected                                   │
│    │      • CI uploads (if running in CI)                    │
│    │                                                          │
│    └─> d) Cleanup & Exit                                     │
│           • Listeners unregistered                           │
│           • Resources released                               │
│           • Exit code returned (0=pass, 1=fail)             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Creating Your First Test

### **Step 1: Create Test Class**

**Location:** `XCUITestFrameworkTests/Tests/MyFeatureTest.swift`

```swift
import XCTest
@testable import XCUITestFramework

class MyFeatureTest: BaseTest {

    // MARK: - Test Methods

    func testBasicFeature() {
        // Your test code here
    }
}
```

**Key Points:**
- ✅ Extend `BaseTest` (provides all setup/teardown)
- ✅ Test methods start with `test` prefix
- ✅ Use descriptive test names
- ✅ One test method = one scenario

---

### **Step 2: Create Page Object**

**Location:** `XCUITestFramework/Core/Pages/Examples/DashboardPage.swift`

```swift
import XCTest

class DashboardPage: FluentPage {

    // MARK: - Element Identifiers

    private let welcomeLabel = "welcomeLabel"
    private let profileButton = "profileButton"
    private let settingsButton = "settingsButton"
    private let logoutButton = "logoutButton"

    // MARK: - Actions

    @discardableResult
    func tapProfile() -> Self {
        tap(identifier: profileButton)
        return self
    }

    @discardableResult
    func tapSettings() -> Self {
        tap(identifier: settingsButton)
        return self
    }

    @discardableResult
    func logout() -> Self {
        tap(identifier: logoutButton)
        return self
    }

    // MARK: - Verifications

    @discardableResult
    func verifyWelcomeMessage(_ username: String) -> Self {
        verifyText(identifier: welcomeLabel, expectedText: "Welcome, \(username)!")
        return self
    }

    @discardableResult
    func verifyPageLoaded() -> Self {
        waitForElement(identifier: welcomeLabel, timeout: 10)
        return self
    }

    // MARK: - Getters

    func getWelcomeText() -> String {
        return getText(identifier: welcomeLabel)
    }
}
```

---

### **Step 3: Write Test Using Page Object**

```swift
class DashboardTest: BaseTest {

    func testDashboardLoad() {
        // 1. Get login page from factory
        let loginPage = getScreen(LoginPage.self)

        // 2. Login
        loginPage
            .verifyPageLoaded()
            .enterUsername("testuser")
            .enterPassword("password123")
            .tapLoginButton()

        // 3. Verify dashboard
        let dashboardPage = getScreen(DashboardPage.self)
        dashboardPage
            .verifyPageLoaded()
            .verifyWelcomeMessage("testuser")
    }

    func testLogout() {
        // 1. Login first
        let loginPage = getScreen(LoginPage.self)
        loginPage
            .enterUsername("testuser")
            .enterPassword("password123")
            .tapLoginButton()

        // 2. Navigate and logout
        let dashboardPage = getScreen(DashboardPage.self)
        dashboardPage
            .verifyPageLoaded()
            .logout()

        // 3. Verify back to login
        loginPage.verifyPageLoaded()
    }
}
```

---

## 🧩 Using Components

### **Instead of Page Objects, Use Components Directly**

```swift
class ComponentBasedTest: BaseTest {

    func testLoginWithComponents() {
        // 1. Enter credentials using TextField component
        TextField("usernameField", in: app)
            .verifyExists(timeout: 10)
            .verifyPlaceholder("Enter username")
            .clearAndType("testuser")
            .verifyValue("testuser")

        TextField("passwordField", in: app)
            .clearAndType("password123")
            .pressReturn()

        // 2. Tap login button using Button component
        Button("loginButton", in: app)
            .verifyEnabled()
            .tap()

        // 3. Verify success using Label component
        Label("welcomeLabel", in: app)
            .verifyExists(timeout: 15)
            .verifyTextContains("Welcome")
    }

    func testAlertHandling() {
        // Trigger an alert
        Button("showAlertButton", in: app).tap()

        // Handle alert using Alert component
        Alert(app: app)
            .verifyExists(timeout: 5)
            .verifyTitle("Confirm Action")
            .accept()

        // Verify alert dismissed
        Alert(app: app).verifyNotExists()
    }

    func testSwitchToggle() {
        // Navigate to settings
        Button("settingsButton", in: app).tap()

        // Toggle notifications using Switch component
        Switch("notificationsSwitch", in: app)
            .verifyExists()
            .verifyOff()
            .turnOn()
            .verifyOn()

        // Verify setting saved
        Label("statusLabel", in: app)
            .verifyText("Notifications Enabled")
    }

    func testTableInteraction() {
        // Open list screen
        Button("viewListButton", in: app).tap()

        // Interact with table using TableView component
        TableView("usersList", in: app)
            .verifyExists()
            .verifyNotEmpty()
            .verifyCellCount(10)
            .tapCell(at: 0)

        // Verify detail screen loaded
        Label("detailTitle", in: app).verifyExists()
    }
}
```

---

## 📊 Data-Driven Testing

### **Step 1: Create Test Data File**

**Location:** `XCUITestFrameworkTests/Resources/TestData/loginData.json`

```json
[
  {
    "username": "validuser",
    "password": "validpass123",
    "shouldSucceed": true,
    "expectedScreen": "Dashboard"
  },
  {
    "username": "invaliduser",
    "password": "wrongpass",
    "shouldSucceed": false,
    "expectedError": "Invalid credentials"
  },
  {
    "username": "",
    "password": "password123",
    "shouldSucceed": false,
    "expectedError": "Username is required"
  },
  {
    "username": "testuser",
    "password": "",
    "shouldSucceed": false,
    "expectedError": "Password is required"
  }
]
```

---

### **Step 2: Create Data Model**

```swift
struct LoginTestData: Decodable {
    let username: String
    let password: String
    let shouldSucceed: Bool
    let expectedScreen: String?
    let expectedError: String?
}
```

---

### **Step 3: Write Data-Driven Test**

```swift
class DataDrivenLoginTest: BaseTest {

    func testLoginWithMultipleDataSets() {
        let loginPage = getScreen(LoginPage.self)

        // Run test with each data set
        DataDrivenTestRunner.runWithJSON(fileName: "loginData") {
            (data: LoginTestData, index: Int) in

            print("Running test case \(index + 1)")

            // Perform login
            loginPage
                .enterUsername(data.username)
                .enterPassword(data.password)
                .tapLoginButton()

            // Verify result
            if data.shouldSucceed {
                let dashboardPage = getScreen(DashboardPage.self)
                dashboardPage.verifyPageLoaded()
            } else {
                loginPage.verifyErrorMessage(data.expectedError!)
            }

            // Reset for next test
            if !data.shouldSucceed && index < 3 {
                loginPage.clearForm()
            }
        }
    }
}
```

---

### **CSV Data-Driven Testing**

**CSV File:** `testcases.csv`
```csv
username,password,expected_result
user1,pass1,success
user2,wrongpass,failure
user3,pass3,success
```

**Test:**
```swift
func testLoginWithCSV() {
    DataDrivenTestRunner.runWithCSV(fileName: "testcases") {
        (row: [String: String], index: Int) in

        let username = row["username"]!
        let password = row["password"]!
        let expectedResult = row["expected_result"]!

        loginPage
            .enterUsername(username)
            .enterPassword(password)
            .tapLoginButton()

        if expectedResult == "success" {
            dashboardPage.verifyPageLoaded()
        } else {
            loginPage.verifyErrorExists()
        }
    }
}
```

---

## 🎯 Advanced Patterns

### **1. Performance Testing**

```swift
class PerformanceTest: BaseTest {

    func testAppLaunchPerformance() {
        // Measure and save baseline
        PerformanceUtils.measureAndSaveBaseline(name: "AppLaunch") {
            app.launch()
        }
    }

    func testLoginPerformance() {
        // Measure against baseline (10% tolerance)
        PerformanceUtils.measureAgainstStoredBaseline(
            name: "LoginFlow",
            tolerance: 0.1
        ) {
            loginPage
                .enterUsername("testuser")
                .enterPassword("password123")
                .tapLoginButton()

            dashboardPage.verifyPageLoaded()
        }
    }

    func testScreenLoadPerformance() {
        loginPage.login(username: "testuser", password: "password123")

        // Measure specific screen load
        PerformanceUtils.measureScreenLoad(
            screenElement: app.staticTexts["Dashboard"],
            name: "DashboardLoad"
        ) {
            app.tabBars.buttons["Dashboard"].tap()
        }
    }
}
```

---

### **2. Deep Link Testing**

```swift
class DeepLinkTest: BaseTest {

    func testProfileDeepLink() {
        let deepLink = DeepLinkUtils(app: app)

        // Open deep link
        deepLink.openDeepLink(
            baseURL: "myapp://",
            path: "profile",
            parameters: ["userId": "123"]
        )

        // Verify navigation
        deepLink.verifyDeepLinkOpened(
            expectedScreen: "ProfileScreen",
            timeout: 10
        )

        // Verify data loaded
        Label("userIdLabel", in: app)
            .verifyText("User ID: 123")
    }

    func testUniversalLink() {
        let deepLink = DeepLinkUtils(app: app)

        deepLink.openUniversalLink("https://myapp.com/products/456")

        // Verify product detail screen
        Label("productIdLabel", in: app)
            .verifyTextContains("456")
    }
}
```

---

### **3. Biometric Authentication Testing**

```swift
class BiometricTest: BaseTest {

    func testFaceIDSuccess() {
        // Navigate to biometric login
        loginPage.tapBiometricLogin()

        // Wait for Face ID prompt
        BiometricUtils.waitForBiometricPrompt(timeout: 5)

        // Simulate successful auth
        BiometricUtils.simulateSuccessfulAuth(type: .faceID)

        // Verify success
        BiometricUtils.verifyAuthSuccess(
            expectedElement: app.staticTexts["Dashboard"],
            timeout: 10
        )
    }

    func testFaceIDFailure() {
        loginPage.tapBiometricLogin()

        // Simulate failed authentication
        BiometricUtils.simulateFailedAuth(type: .faceID)

        // Verify error shown
        Label("errorLabel", in: app)
            .verifyTextContains("Authentication Failed")
    }

    func testPasswordFallback() {
        loginPage.tapBiometricLogin()
        BiometricUtils.waitForBiometricPrompt()

        // Use password instead
        BiometricUtils.usePasswordFallback(password: "testpass123")

        // Verify logged in
        dashboardPage.verifyPageLoaded()
    }
}
```

---

### **4. Retry Mechanisms**

```swift
class RetryTest: BaseTest {

    func testUnstableElement() {
        // Element might take time to appear
        let success = RetryUtils.retry(maxAttempts: 3, delay: 1.0) {
            return app.buttons["unstableButton"].exists
        }

        XCTAssertTrue(success, "Element should appear within 3 retries")

        if success {
            Button("unstableButton", in: app).tap()
        }
    }

    func testWithExponentialBackoff() {
        // Retry with increasing delays
        let success = RetryUtils.retryWithExponentialBackoff(
            maxAttempts: 5,
            initialDelay: 0.5,
            maxDelay: 5.0
        ) {
            // Check if data loaded
            return app.cells.count > 0
        }

        XCTAssertTrue(success)
    }

    func testRetryUntilTimeout() {
        // Keep retrying until timeout
        let success = RetryUtils.retryUntil(timeout: 30.0, interval: 1.0) {
            return app.staticTexts["Loading"].exists == false
        }

        XCTAssertTrue(success, "Loading should complete within 30 seconds")
    }
}
```

---

### **5. Exception Handling**

```swift
class ExceptionHandlingTest: BaseTest {

    func testConfigurationError() {
        do {
            let apiKey = try ConfigReader.shared.getString("nonexistent_key")
            XCTFail("Should have thrown exception")
        } catch let error as ConfigurationException {
            Logger.info("Caught expected exception: \(error.message)")
            // Test passed - exception caught
        }
    }

    func testElementNotFound() {
        do {
            let element = app.buttons["doesNotExist"]
            if !element.waitForExistence(timeout: 5) {
                throw ElementNotFoundException.notFoundAfterWait(
                    "doesNotExist",
                    timeout: 5
                )
            }
            XCTFail("Should have thrown exception")
        } catch let error as ElementNotFoundException {
            Logger.info("Caught expected exception")
            error.log()
        }
    }

    func testTimeout() {
        do {
            let startTime = Date()
            let element = app.staticTexts["neverAppears"]

            if !element.waitForExistence(timeout: 5) {
                throw TimeoutException.elementWait(
                    "neverAppears",
                    timeout: 5
                )
            }
        } catch let error as TimeoutException {
            // Expected - element doesn't exist
            XCTAssertTrue(error.timeout == 5.0)
        }
    }
}
```

---

## ✅ Best Practices

### **1. Test Structure**

```swift
func testFeatureName() {
    // ARRANGE - Setup
    let loginPage = getScreen(LoginPage.self)
    let testData = loadTestData()

    // ACT - Perform actions
    loginPage
        .enterUsername(testData.username)
        .enterPassword(testData.password)
        .tapLoginButton()

    // ASSERT - Verify results
    let dashboardPage = getScreen(DashboardPage.self)
    dashboardPage.verifyPageLoaded()
}
```

---

### **2. Naming Conventions**

```swift
// ✅ Good - Descriptive names
func testLoginWithValidCredentialsShowsDashboard()
func testLoginWithInvalidCredentialsShowsError()
func testLogoutReturnsToLoginScreen()

// ❌ Bad - Vague names
func testLogin()
func test1()
func testStuff()
```

---

### **3. Use Components Over Raw Elements**

```swift
// ❌ Bad - Raw XCUIElement
app.textFields["username"].tap()
app.textFields["username"].typeText("testuser")

// ✅ Good - Component wrapper
TextField("username", in: app)
    .clearAndType("testuser")
    .verifyValue("testuser")
```

---

### **4. Always Verify**

```swift
// ❌ Bad - No verification
loginPage.enterUsername("test").tapLogin()

// ✅ Good - Verify each step
loginPage
    .verifyPageLoaded()
    .enterUsername("test")
    .verifyUsernameEntered("test")
    .tapLogin()
    .verifyNavigatedToDashboard()
```

---

### **5. Handle Exceptions Gracefully**

```swift
func testFeature() {
    do {
        let data = try JSONReader.decode(
            fileName: "testdata",
            as: TestData.self
        )
        performTest(with: data)
    } catch let error as JSONParsingException {
        Logger.error("Failed to load test data: \(error.message)")
        XCTFail("Test data required")
    } catch {
        Logger.error("Unexpected error: \(error)")
        XCTFail("Unexpected error occurred")
    }
}
```

---

### **6. Use Listeners for Common Tasks**

```swift
override func setUp() {
    super.setUp()

    // Register listeners once
    TestLifecycleListenerManager.shared.register(
        LoggingListener(verbose: true)
    )
    TestLifecycleListenerManager.shared.register(
        ScreenshotListener(captureMode: .onFailure, app: app)
    )

    // Listeners will automatically:
    // - Log test progress
    // - Capture screenshots on failure
    // - No manual intervention needed
}
```

---

## 🐛 Troubleshooting

### **Common Issues**

#### **1. Element Not Found**

```swift
// Problem: Element not appearing
Button("loginButton", in: app).tap() // Fails immediately

// Solution: Wait for element
Button("loginButton", in: app)
    .verifyExists(timeout: 10) // Wait up to 10 seconds
    .tap()

// Or use retry
let success = RetryUtils.retry(maxAttempts: 3, delay: 1.0) {
    return app.buttons["loginButton"].exists
}
```

---

#### **2. Configuration Not Loading**

```swift
// Problem: Config file not found
let apiKey = try ConfigReader.shared.getString("apiKey")
// Throws: ConfigurationException

// Solution: Check environment and fallback
let environment = ConfigReader.shared.getCurrentEnvironment()
Logger.info("Current environment: \(environment)")

// Use default value
let apiKey = ConfigReader.shared.getString("apiKey", default: "test-key")
```

---

#### **3. Page Object Not Cached**

```swift
// Problem: Creating new instances each time
let page1 = LoginPage(app: app)
let page2 = LoginPage(app: app) // Different instance

// Solution: Use ScreenFactory
let page1 = ScreenFactory.shared.getScreen(LoginPage.self, app: app)
let page2 = ScreenFactory.shared.getScreen(LoginPage.self, app: app)
// Same instance (cached)
```

---

#### **4. Test Flakiness**

```swift
// Problem: Test passes sometimes, fails other times

// Solution 1: Add explicit waits
func tapLoginButton() -> Self {
    Button("loginButton", in: app)
        .verifyExists(timeout: 10)
        .verifyEnabled()
        .tap()
    return self
}

// Solution 2: Use retry mechanism
RetryUtils.retry(maxAttempts: 3, delay: 1.0) {
    return performUnstableAction()
}

// Solution 3: Check app health
if !AppHealthChecker.isAppHealthy(app) {
    AppHealthChecker.restartApp(app)
}
```

---

## 📝 Complete Test Example

**Full end-to-end test with all best practices:**

```swift
import XCTest
@testable import XCUITestFramework

class CompleteFeatureTest: BaseTest {

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        // Register listeners
        TestLifecycleListenerManager.shared.register(
            LoggingListener(verbose: true)
        )
        TestLifecycleListenerManager.shared.register(
            ScreenshotListener(captureMode: .onFailure, app: app)
        )

        Logger.info("Test setup completed")
    }

    // MARK: - Tests

    func testCompleteUserJourney() {
        Logger.info("Starting complete user journey test")

        // 1. Load test data
        struct TestData: Decodable {
            let username: String
            let password: String
        }

        do {
            let testData = try JSONReader.decode(
                fileName: "userdata",
                as: TestData.self
            )

            // 2. Measure app launch
            PerformanceUtils.measureAgainstStoredBaseline(
                name: "AppLaunch",
                tolerance: 0.1
            ) {
                // App already launched in setUp
            }

            // 3. Login flow
            let loginPage = getScreen(LoginPage.self)
            loginPage
                .verifyPageLoaded()
                .enterUsername(testData.username)
                .enterPassword(testData.password)
                .tapLoginButton()

            // 4. Verify dashboard
            let dashboardPage = getScreen(DashboardPage.self)
            dashboardPage
                .verifyPageLoaded()
                .verifyWelcomeMessage(testData.username)

            // 5. Navigate to profile
            dashboardPage.tapProfile()

            // 6. Verify profile using components
            Label("profileUsername", in: app)
                .verifyExists(timeout: 10)
                .verifyText(testData.username)

            // 7. Logout
            Button("logoutButton", in: app).tap()

            // 8. Verify back to login
            loginPage.verifyPageLoaded()

            Logger.info("Test completed successfully")

        } catch let error as FrameworkException {
            error.log()
            XCTFail("Test failed: \(error.message)")
        } catch {
            Logger.error("Unexpected error: \(error)")
            XCTFail("Unexpected error occurred")
        }
    }

    // MARK: - Teardown

    override func tearDown() {
        Logger.info("Test teardown")
        super.tearDown()
    }
}
```

---

**Congratulations!** You now understand the complete framework structure, all features, and how to write comprehensive tests!

**Previous:** [FRAMEWORK_FEATURES.md](FRAMEWORK_FEATURES.md)
**Up:** [FRAMEWORK_STRUCTURE.md](FRAMEWORK_STRUCTURE.md)

