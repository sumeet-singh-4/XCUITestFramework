# XCUITest Framework - Features Guide

**Version:** 2.0.0
**Last Updated:** September 30, 2026

---

## 📚 Table of Contents

1. [Core Features](#core-features)
2. [Exception Handling](#exception-handling)
3. [Reusable Components](#reusable-components)
4. [Test Lifecycle Listeners](#test-lifecycle-listeners)
5. [Configuration Management](#configuration-management)
6. [Utility Features](#utility-features)
7. [Advanced Testing](#advanced-testing)
8. [Code Quality](#code-quality)

---

## 🎯 Core Features

### **1. Page Object Model (POM) Architecture**

**Three-tier architecture for maintainable tests:**

```swift
// Tier 1: BasePage (Core functionality)
class BasePage {
    func tap(identifier: String) { }
    func type(identifier: String, text: String) { }
    func waitForElement(identifier: String) -> Bool { }
}

// Tier 2: FluentPage (Fluent interface)
class FluentPage: BasePage {
    @discardableResult
    func tap(identifier: String) -> Self {
        super.tap(identifier: identifier)
        return self
    }
}

// Tier 3: Specific Page (Screen logic)
class LoginPage: FluentPage {
    func enterUsername(_ username: String) -> Self {
        return type(identifier: "usernameField", text: username)
    }
}
```

**Benefits:**
- ✅ Separation of concerns
- ✅ Reusable page logic
- ✅ Easy maintenance
- ✅ Method chaining support

---

### **2. Screen Factory Pattern**

**Centralized screen instance management with thread-safe caching:**

```swift
// Get screen instance
let loginPage = ScreenFactory.shared.getScreen(LoginPage.self, app: app)

// Cached - second call returns same instance
let samePage = ScreenFactory.shared.getScreen(LoginPage.self, app: app)

// Clear cache if needed
ScreenFactory.shared.clearCache()
```

**Features:**
- ✅ Singleton pattern
- ✅ Thread-safe concurrent access
- ✅ Automatic caching
- ✅ Memory management

---

### **3. Fluent Interface (Method Chaining)**

**Write readable, chainable test code:**

```swift
LoginPage(app: app)
    .verifyPageLoaded()
    .enterUsername("testuser")
    .enterPassword("password123")
    .tapLoginButton()
    .verifyDashboardLoaded()
```

**All components support fluent interface:**
- Button, TextField, Label, Alert, Switch, TableView
- All page objects extending FluentPage
- All verification methods

---

## ⚠️ Exception Handling

### **Custom Exception Hierarchy**

```
FrameworkException (Base)
├── ConfigurationException
├── ElementNotFoundException
├── TimeoutException
├── JSONParsingException
└── AppCrashException
```

### **ConfigurationException**

**When configuration errors occur:**

```swift
// Throws exception if key missing
do {
    let apiKey = try ConfigReader.shared.getString("apiKey")
} catch let error as ConfigurationException {
    error.log()
    // Handle gracefully
}

// Use default fallback (no exception)
let apiKey = ConfigReader.shared.getString("apiKey", default: "default-key")
```

**Factory Methods:**
```swift
ConfigurationException.fileNotFound("config.plist")
ConfigurationException.missingKey("apiKey", in: "config.plist")
ConfigurationException.typeMismatch("timeout", expected: "Int", actual: "String")
ConfigurationException.environmentNotConfigured("staging")
```

---

### **ElementNotFoundException**

**When UI elements can't be found:**

```swift
// Throw when element not found
if !element.waitForExistence(timeout: 10) {
    throw ElementNotFoundException.notFoundAfterWait("loginButton", timeout: 10)
}

// Element exists but not interactable
throw ElementNotFoundException.notHittable("submitButton", timeout: 5)

// Multiple elements when expecting one
throw ElementNotFoundException.multipleElementsFound("userCell", count: 5)
```

**Features:**
- Element identifier tracking
- Timeout information
- Element type tracking

---

### **TimeoutException**

**When operations exceed time limits:**

```swift
// Element wait timeout
throw TimeoutException.elementWait("loadingSpinner", timeout: 30)

// Screen load timeout
throw TimeoutException.screenLoad("DashboardScreen", timeout: 15)

// App launch timeout
throw TimeoutException.appLaunch(timeout: 10)

// Network request timeout
throw TimeoutException.networkRequest("/api/users", timeout: 20)
```

---

### **JSONParsingException**

**When JSON operations fail:**

```swift
// File not found
throw JSONParsingException.fileNotFound("users.json")

// Invalid JSON format
throw JSONParsingException.invalidJSON("data.json", underlyingError: error)

// Key not found
throw JSONParsingException.keyNotFound("username", in: "users.json")

// Decoding failed
throw JSONParsingException.decodingFailed(User.self, fileName: "users.json", underlyingError: error)
```

---

### **AppCrashException**

**When app crashes or becomes unhealthy:**

```swift
// App crashed
throw AppCrashException.crashed(crashLog: logContent)

// App not responding
throw AppCrashException.notResponding()

// Failed to launch
throw AppCrashException.failedToLaunch(reason: "Permissions denied")

// Health check failed
throw AppCrashException.healthCheckFailed(state: .notRunning, retryCount: 3)
```

---

## 🧩 Reusable Components

### **Button Component**

**Features:**
- Single tap, double tap, long press
- Two-finger tap, force tap
- Existence verification
- Enabled/disabled state checks
- Label/title verification
- Screenshot capture

```swift
Button("loginButton", in: app)
    .verifyExists()
    .verifyEnabled()
    .verifyLabel("Login")
    .tap()

// Long press
Button("contextMenu", in: app).longPress(duration: 2.0)

// Double tap
Button("likeButton", in: app).doubleTap()
```

---

### **TextField Component**

**Features:**
- Typing and clearing text
- Paste operations
- Keyboard management
- Value verification
- Placeholder verification
- Empty state checks

```swift
TextField("usernameField", in: app)
    .verifyExists()
    .verifyPlaceholder("Enter username")
    .clearAndType("testuser")
    .verifyValue("testuser")
    .pressReturn()
    .dismissKeyboard()

// Paste text
TextField("emailField", in: app)
    .pasteText("user@example.com")
```

---

### **Label Component**

**Features:**
- Text extraction
- Text verification
- Contains/starts with/ends with checks
- Regex pattern matching

```swift
Label("welcomeLabel", in: app)
    .verifyExists()
    .verifyText("Welcome, John")
    .verifyTextContains("Welcome")
    .verifyTextStartsWith("Welcome")
    .verifyTextEndsWith("John")
    .verifyTextMatches(regex: "Welcome, \\w+")
```

---

### **Alert Component**

**Features:**
- Accept/dismiss alerts
- Permission handling
- System alert support
- Springboard alert support
- Button tapping by title
- Title/message verification

```swift
Alert(app: app)
    .verifyExists()
    .verifyTitle("Location Access")
    .allowPermission()

// Tap specific button
Alert(app: app).tapButton("Allow Once")

// Deny permission
Alert(app: app).denyPermission()

// Dismiss
Alert(app: app).dismiss()
```

---

### **Switch Component**

**Features:**
- Turn on/off
- Toggle
- State verification
- Enabled/disabled checks

```swift
Switch("notificationsSwitch", in: app)
    .verifyExists()
    .verifyOff()
    .turnOn()
    .verifyOn()

// Toggle (flip current state)
Switch("darkModeSwitch", in: app).toggle()

// Set specific state
Switch("wifiSwitch", in: app).setState(true)
```

---

### **TableView Component**

**Features:**
- Cell tapping (by index, identifier, text)
- Scrolling (up, down, top, bottom)
- Pull to refresh
- Cell count verification
- Cell existence checks

```swift
TableView("usersList", in: app)
    .verifyExists()
    .verifyNotEmpty()
    .verifyCellCount(10)
    .tapCell(at: 0)

// Tap by text content
TableView("menuList", in: app)
    .tapCellContaining(text: "Settings")

// Scroll operations
TableView("feedList", in: app)
    .swipeUp()
    .scrollToBottom()
    .pullToRefresh()
```

---

## 👂 Test Lifecycle Listeners

### **Event System**

**Lifecycle Events:**
```
testSuiteWillStart()
  ↓
testCaseWillStart()
  ↓
testMethodWillStart()
  ↓
[Test Execution]
  ↓
testMethodDidFinish() / testCaseDidFail()
  ↓
testCaseDidFinish()
  ↓
testSuiteDidFinish()
```

---

### **LoggingListener**

**Comprehensive test execution logging:**

```swift
// Register in test setup
TestLifecycleListenerManager.shared.register(
    LoggingListener(verbose: true)
)
```

**Output:**
```
================================================================================
🏁 Test Suite Starting: LoginTestSuite
   Test Count: 5
================================================================================

--------------------------------------------------------------------------------
▶️  Test Starting: testValidLogin
--------------------------------------------------------------------------------
✅ Test Finished: testValidLogin
   Result: PASSED
   Duration: 2.34 seconds
```

**Features:**
- ✅ Emoji indicators (✅❌⏭️🔥)
- ✅ Duration tracking
- ✅ Suite and case level reporting
- ✅ Verbose and concise modes

---

### **ScreenshotListener**

**Automatic screenshot capture:**

```swift
// Capture on failure only
TestLifecycleListenerManager.shared.register(
    ScreenshotListener(captureMode: .onFailure, app: app)
)

// Capture modes
.onFailure  // On test failure
.onFinish   // After each test
.always     // Start and end
.never      // Disabled
```

**Features:**
- ✅ Automatic capture based on mode
- ✅ XCTAttachment integration
- ✅ Test result bundle inclusion

---

### **Custom Listeners**

**Create your own:**

```swift
class CustomListener: TestLifecycleListener {
    func testCaseDidFail(_ testCase: XCTestCase, failure: TestFailure) {
        // Send notification to Slack
        // Log to custom system
        // Take additional screenshots
    }
}

// Register
TestLifecycleListenerManager.shared.register(CustomListener())
```

---

## 🔧 Configuration Management

### **Multi-Environment Support**

**Four environments supported:**
- `default` - Default configuration
- `dev` - Development environment
- `qa` - QA/Testing environment
- `prod` - Production environment

**Set via environment variable:**
```bash
ENV=qa xcodebuild test ...
```

---

### **Configuration Loading**

**Priority:**
1. Environment variable (ENV)
2. Environment-specific config (config-{env}.plist)
3. Default config (config.plist)

```swift
// Throws exception if not found
let apiKey = try ConfigReader.shared.getString("apiKey")

// With default fallback
let apiKey = ConfigReader.shared.getString("apiKey", default: "test-key")

// Built-in getters
let timeout = ConfigReader.shared.implicitWaitTimeout
let screenshotOnFailure = ConfigReader.shared.screenshotOnFailure
let baseURL = ConfigReader.shared.baseURL
```

---

### **Configuration Properties**

**Common properties:**
```
app.bundleId          # App bundle identifier
app.path              # Path to .app file
app.baseURL           # API base URL
device.name           # Device name
device.platformVersion # iOS version
wait.implicitTimeout  # Default wait timeout
wait.explicitTimeout  # Explicit wait timeout
reporting.screenshotOnFailure # Auto-screenshot
reporting.videoRecording # Video recording
testData.path         # Test data directory
```

---

## 🛠️ Utility Features

### **1. Retry Mechanisms**

**Six retry strategies:**

```swift
// 1. Simple retry (max attempts)
let success = RetryUtils.retry(maxAttempts: 3) {
    return element.exists
}

// 2. Retry with delay
let success = RetryUtils.retry(maxAttempts: 3, delay: 1.0) {
    return element.exists
}

// 3. Exponential backoff
let success = RetryUtils.retryWithExponentialBackoff(
    maxAttempts: 5,
    initialDelay: 0.5,
    maxDelay: 5.0
) {
    return apiCall()
}

// 4. Retry until timeout
let success = RetryUtils.retryUntil(timeout: 10.0, interval: 0.5) {
    return condition()
}

// 5. Conditional retry
let success = RetryUtils.retryConditional(
    maxAttempts: 5,
    shouldRetry: { error in
        return error.isRetryable
    }
) {
    return riskyOperation()
}

// 6. Custom retry logic
let success = RetryUtils.retryWithCustomLogic(
    condition: { attemptCount in
        return attemptCount < 5
    },
    action: {
        return operation()
    }
)
```

---

### **2. Screenshot & Video Recording**

**Screenshot utilities:**

```swift
// Capture and attach
ScreenshotUtils.captureAndAttach(name: "LoginScreen")

// Capture failure screenshot
ScreenshotUtils.captureFailureScreenshot(testName: "testLogin")

// Capture element
let attachment = ScreenshotUtils.captureElementScreenshot(
    element: loginButton,
    name: "LoginButton"
)

// Save to file
ScreenshotUtils.saveScreenshotToDefaultLocation(name: "HomeScreen")

// Clean old screenshots
ScreenshotUtils.cleanOldScreenshots(
    fromDirectory: "/path/to/screenshots",
    olderThanDays: 7
)
```

**Video recording:**

```swift
// Start/stop recording
let recordingId = ScreenshotUtils.startVideoRecording(name: "LoginFlow")
// ... perform actions ...
ScreenshotUtils.stopVideoRecording(recordingId: recordingId)

// Record during block
ScreenshotUtils.recordVideo(name: "SignupFlow") {
    // Perform test actions
    signupPage.fillForm().submit()
}
```

---

### **3. App Health Monitoring**

**Monitor and recover from app issues:**

```swift
// Check if app is healthy
if AppHealthChecker.isAppHealthy(app) {
    print("App is running normally")
}

// Monitor during test
AppHealthChecker.monitorAppHealth(app, interval: 1.0) { state in
    print("App state changed to: \(state)")
}

// Restart if unhealthy
if !AppHealthChecker.isAppHealthy(app) {
    AppHealthChecker.restartApp(app)
}

// Wait for app to become healthy
let isHealthy = AppHealthChecker.waitForAppToBeHealthy(app, timeout: 30.0)
```

---

### **4. JSON Data Reading**

**Read and parse JSON test data:**

```swift
// Read raw JSON
let jsonDict = try JSONReader.read(fileName: "users")

// Decode to model
struct User: Decodable {
    let username: String
    let email: String
}
let users = try JSONReader.decode(fileName: "users", as: [User].self)

// Get value by key
let username = try JSONReader.getValue(fileName: "users", key: "username") as String

// Get value by key path
let email = try JSONReader.getValue(
    fileName: "users",
    keyPath: "users.0.email"
) as String
```

---

### **5. Deep Link Testing**

**Test deep links and universal links:**

```swift
let deepLink = DeepLinkUtils(app: app)

// Open deep link
deepLink.openDeepLink("myapp://profile/123")

// Open with parameters
deepLink.openDeepLink(
    baseURL: "myapp://",
    path: "profile",
    parameters: ["userId": "123", "tab": "posts"]
)

// Open universal link
deepLink.openUniversalLink("https://myapp.com/profile/123")

// Verify navigation
deepLink.verifyDeepLinkOpened(expectedScreen: "ProfileScreen", timeout: 10)

// Extract parameters
let params = DeepLinkUtils.extractParameters(from: "myapp://profile?userId=123")
// params = ["userId": "123"]
```

---

### **6. Biometric Testing**

**Test Face ID and Touch ID:**

```swift
// Simulate successful authentication
BiometricUtils.simulateSuccessfulAuth(type: .faceID)

// Simulate failed authentication
BiometricUtils.simulateFailedAuth(type: .touchID)

// Wait for prompt
BiometricUtils.waitForBiometricPrompt(timeout: 5)

// Cancel authentication
BiometricUtils.cancelBiometricAuth()

// Use password fallback
BiometricUtils.usePasswordFallback(password: "testpass123")

// Verify success
BiometricUtils.verifyAuthSuccess(
    expectedElement: homeScreen,
    timeout: 5
)

// Enrollment (simulator)
BiometricUtils.enrollBiometric(type: .faceID)
```

---

### **7. Data-Driven Testing**

**Run tests with multiple data sets:**

```swift
// JSON data-driven
DataDrivenTestRunner.runWithJSON(fileName: "loginData") { (data: LoginData, index: Int) in
    loginPage
        .enterUsername(data.username)
        .enterPassword(data.password)
        .tapLogin()

    if data.shouldSucceed {
        dashboardPage.verifyLoaded()
    } else {
        loginPage.verifyErrorMessage(data.expectedError)
    }
}

// CSV data-driven
DataDrivenTestRunner.runWithCSV(fileName: "testcases") { (row: [String: String], index: Int) in
    let username = row["username"]!
    let password = row["password"]!
    // Perform test
}

// Custom provider
let provider = InMemoryDataProvider(data: [
    ("user1", "pass1"),
    ("user2", "pass2")
])
DataDrivenTestRunner.run(with: provider) { (credentials, index) in
    // Test with credentials
}
```

---

### **8. Performance Testing**

**Measure and track performance:**

```swift
// Simple measurement
let duration = PerformanceUtils.measure(name: "AppLaunch") {
    app.launch()
}

// Save baseline
PerformanceUtils.measureAndSaveBaseline(name: "AppLaunch") {
    app.launch()
}

// Measure against baseline (10% tolerance)
PerformanceUtils.measureAgainstStoredBaseline(name: "AppLaunch", tolerance: 0.1) {
    app.launch()
}

// Measure screen load
PerformanceUtils.measureScreenLoad(
    screenElement: dashboardElement,
    name: "DashboardLoad"
) {
    loginButton.tap()
}

// Baseline management
PerformanceUtils.listBaselines()
PerformanceUtils.clearBaselines()
let baseline = PerformanceUtils.getBaseline(name: "AppLaunch")
```

---

### **9. Centralized Logging**

**Log with different severity levels:**

```swift
// Set minimum level
Logger.minimumLevel = .info

// Log messages
Logger.verbose("Detailed debug information")
Logger.debug("Debug information")
Logger.info("Informational message")
Logger.warning("Warning message")
Logger.error("Error occurred")
Logger.critical("Critical failure")

// Output format:
// 🔍 [14:23:45.123] [VERBOSE] [LoginTest.swift:45] Detailed debug information
// ℹ️ [14:23:45.456] [INFO] [LoginTest.swift:50] Informational message
// ❌ [14:23:45.789] [ERROR] [LoginTest.swift:55] Error occurred
```

---

## 🚀 Advanced Testing

### **1. Parallel Test Execution**

**Test plan configuration:**

```json
{
  "configurations": [
    {
      "name": "Parallel Execution",
      "options": {
        "parallelizationEnabled": true,
        "testExecutionOrdering": "random"
      }
    }
  ]
}
```

**Run parallel tests:**
```bash
xcodebuild test -scheme XCUITestFramework -testPlan XCUITestFramework -parallel-testing-enabled YES
```

---

### **2. Test Data Management**

**Organize test data:**

```
TestData/
├── users.json
├── products.json
├── testcases.csv
└── environments/
    ├── dev-data.json
    └── qa-data.json
```

**Load environment-specific data:**
```swift
let environment = ConfigReader.shared.getCurrentEnvironment()
let data = try JSONReader.read(fileName: "environments/\(environment)-data")
```

---

### **3. Cross-Environment Testing**

**Run same tests across environments:**

```bash
# Dev environment
ENV=dev xcodebuild test ...

# QA environment
ENV=qa xcodebuild test ...

# Production environment
ENV=prod xcodebuild test ...
```

---

## 🎨 Code Quality

### **SwiftLint Integration**

**Automatic code quality enforcement:**

```yaml
# .swiftlint.yml
file_length: 500
function_body_length: 100
cyclomatic_complexity: 15
force_unwrapping: warning
```

**Run SwiftLint:**
```bash
swiftlint lint
swiftlint autocorrect
```

---

### **Enum-Based Type Safety**

**Eliminate magic strings:**

```swift
// ❌ Bad - Magic strings
app.swipe(.up)
if orientation == "portrait" { }

// ✅ Good - Type-safe enums
app.swipe(direction: .up)
if orientation == .portrait { }
```

---

### **Exception-Based Error Handling**

**Clear error context:**

```swift
// ❌ Bad - Silent failures
let value = config["key"] ?? ""

// ✅ Good - Explicit errors
do {
    let value = try config.getString("key")
} catch let error as ConfigurationException {
    Logger.error("Config error: \(error.message)")
    throw error
}
```

---

## 📊 Feature Comparison

| Feature | Traditional XCTest | This Framework |
|---------|-------------------|----------------|
| **Page Objects** | Manual | ✅ Built-in with fluent interface |
| **Components** | Raw XCUIElement | ✅ 6 reusable components |
| **Exceptions** | Generic errors | ✅ 6 custom exception types |
| **Retries** | Manual loops | ✅ 6 retry strategies |
| **Screenshots** | Manual capture | ✅ Automatic + video recording |
| **Listeners** | None | ✅ Extensible event system |
| **Data-Driven** | Manual | ✅ JSON/CSV providers |
| **Performance** | Basic | ✅ Baseline tracking |
| **Deep Links** | Manual | ✅ Built-in utility |
| **Biometrics** | Manual | ✅ Built-in utility |
| **Logging** | print() | ✅ Centralized with levels |
| **Parallel Tests** | Manual | ✅ Configured |
| **Code Quality** | None | ✅ SwiftLint integration |

---

**Next:** See [WRITING_TESTS.md](WRITING_TESTS.md) for step-by-step test writing guide.

