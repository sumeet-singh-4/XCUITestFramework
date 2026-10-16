# Xcode Project Setup for Testing Third-Party Apps

**Last Updated:** October 8, 2026
**Version:** 2.0.0

---

## 📋 Overview

This guide documents the complete Xcode setup process for testing third-party iOS applications (apps you don't have source code for) using the XCUITest Framework.

**Important:** Swift Package Manager (SPM) **does NOT support XCUITests** properly. You must use an Xcode project with a proper UI Test Bundle.

---

## ⚠️ Why SPM Doesn't Work for XCUITests

| Issue | SPM Behavior | Xcode Project Solution |
|-------|--------------|------------------------|
| **Bundle Type** | Creates Unit Test Bundle | Creates UI Test Bundle |
| **Entitlements** | Missing XCUIApplication entitlements | Proper UI testing entitlements |
| **Error** | "Device is not configured for UI testing" | Tests run successfully |
| **App Launch** | Cannot launch third-party apps | Can launch any installed app |

**Bottom line:** You need a proper Xcode project with a UI Testing target.

---

## 🎯 What We're Building

- **Project Name:** WdioDemoAppTestRunner
- **Purpose:** Test runner for third-party apps
- **Target App:** wdiodemoapp (Bundle ID: `org.wdiodemoapp`)
- **Test Target:** WdioDemoAppUITests (UI Test Bundle)
- **Framework:** All XCUITestFramework source files integrated directly

---

## 🚀 Complete Step-by-Step Setup

### Step 1: Create New Xcode Project

1. **Launch Xcode**

2. **Create New Project:**
   - File → New → Project
   - Choose Template: **iOS → App**

3. **Project Configuration:**
   ```
   Product Name:          WdioDemoAppTestRunner
   Team:                  (Select your team)
   Organization Identifier: (e.g., com.visa)
   Bundle Identifier:     (Auto-generated)
   Interface:             SwiftUI
   Language:              Swift
   Testing System:        XCTest
   Storage:               (Leave default)
   ```

4. **Save Location:**
   ```
   /Users/sumesing/New_Softwares/XCUITestFramework/WdioDemoAppTestRunner/
   ```

5. **Click "Create"**

**Result:** You now have a basic iOS app project (we won't use this app, just the project structure).

---

### Step 2: Add UI Testing Target

**This is the critical step that enables XCUIApplication functionality.**

1. **Select Project in Navigator:**
   - Click on `WdioDemoAppTestRunner` (top of project navigator)

2. **Add New Target:**
   - Scroll to bottom of the targets list
   - Click the **"+"** button
   - Choose **iOS → UI Testing Bundle**

3. **Configure UI Test Bundle:**
   ```
   Product Name:          WdioDemoAppUITests
   Team:                  (Same as project)
   Target to be Tested:   WdioDemoAppTestRunner
   ```

4. **Click "Finish"**

5. **Bridging Header Prompt:**
   - When asked: "Would you like to configure an Objective-C bridging header?"
   - Click **"Don't Create"** (we're using pure Swift)

**Result:** You now have a proper UI Test Bundle with correct entitlements.

---

### Step 3: Add Framework Source Files

Now we copy all the XCUITestFramework source files into the UI Test target.

#### 3.1: Add Test Files

1. **Right-click** on `WdioDemoAppUITests` folder in Xcode
2. Choose **"Add Files to WdioDemoAppTestRunner..."**
3. Navigate to your framework test files:
   ```
   /Users/sumesing/New_Softwares/XCUITestFramework/XCUITestFrameworkTests/Tests/
   ```
4. **Select files:**
   - `BaseTest.swift`
   - `LoginTest.swift`
   - Any other test files you created

5. **Import Options:**
   - ✅ **Check:** "Copy items if needed"
   - ✅ **Check:** "Create groups"
   - ✅ **Target Membership:** Check **ONLY** `WdioDemoAppUITests`
   - ❌ **Don't check:** `WdioDemoAppTestRunner` (main app target)

6. Click **"Add"**

#### 3.2: Add Core Framework Folder

1. **Right-click** on `WdioDemoAppUITests` folder again
2. Choose **"Add Files to WdioDemoAppTestRunner..."**
3. Navigate to:
   ```
   /Users/sumesing/New_Softwares/XCUITestFramework/XCUITestFramework/Core/
   ```
4. **Select the entire `Core` folder**

5. **Import Options:**
   - ✅ **Check:** "Copy items if needed"
   - ✅ **Check:** "Create groups" (NOT "Create folder references")
   - ✅ **Target Membership:** Check **ONLY** `WdioDemoAppUITests`
   - ❌ **Don't check:** `WdioDemoAppTestRunner`

6. Click **"Add"**

**What Gets Added:**
```
WdioDemoAppUITests/
├── Core/
│   ├── Base/
│   │   └── BaseTest.swift
│   ├── Components/
│   │   ├── Alert.swift
│   │   ├── Button.swift
│   │   ├── Label.swift
│   │   ├── Switch.swift
│   │   ├── TableView.swift
│   │   └── TextField.swift
│   ├── Configuration/
│   │   └── ConfigReader.swift
│   ├── Exceptions/
│   │   ├── AppCrashException.swift
│   │   ├── ConfigurationException.swift
│   │   ├── ElementNotFoundException.swift
│   │   └── (other exceptions)
│   ├── Pages/
│   │   ├── Base/
│   │   │   └── BasePage.swift
│   │   └── LoginPage.swift
│   └── Utils/
│       ├── AppHealthChecker.swift
│       ├── DataProvider.swift
│       ├── JSONReader.swift
│       ├── LoggerUtils.swift
│       ├── PerformanceUtils.swift
│       ├── RetryUtils.swift
│       ├── ScreenFactory.swift
│       ├── ScreenshotUtils.swift
│       └── WaitUtils.swift
├── BaseTest.swift
├── LoginTest.swift
└── (your test files)
```

---

### Step 4: Configure BaseTest for Target App

**Critical:** Configure BaseTest to launch the third-party app installed on your simulator.

1. **Open `BaseTest.swift` in Xcode**

2. **Locate `setUpWithError()` method**

3. **Verify/Update the app initialization:**

```swift
override func setUpWithError() throws {
    try super.setUpWithError()

    continueAfterFailure = false

    // CRITICAL: Use bundle identifier of the installed app
    app = XCUIApplication(bundleIdentifier: "org.wdiodemoapp")

    // Launch the app
    app.launch()

    // Initialize health checker and screen factory
    healthChecker = AppHealthChecker(app: app)
    ScreenFactory.shared.setDefaultApp(app)
}
```

**How to find the bundle identifier:**
```bash
xcrun simctl listapps <simulator-id> | grep -i "wdio"
```

Example output:
```json
{
    "org.wdiodemoapp" : {
        "ApplicationType" : "User",
        "Bundle" : "file:///...",
        "CFBundleDisplayName" : "wdiodemoapp",
        ...
    }
}
```

The key is `"org.wdiodemoapp"` - use this in `XCUIApplication(bundleIdentifier:)`

---

### Step 5: Remove Module Import Statements

Since all framework files are now directly in the test target (not a separate module), we need to remove module import statements.

**Files to Check:**
- `BaseTest.swift`
- `LoginTest.swift`
- Any other test files

**Before:**
```swift
@testable import XCUITestFramework
import XCTest

class LoginTest: BaseTest {
    // ...
}
```

**After:**
```swift
import XCTest

class LoginTest: BaseTest {
    // ...
}
```

**Why:** The files are now in the same compilation unit, so no import is needed.

---

### Step 6: Verify Target Membership

**Important:** Ensure all framework files are part of the correct target.

1. **Select any framework file** (e.g., `Button.swift`)
2. **Open File Inspector** (View → Inspectors → Show File Inspector, or ⌥⌘1)
3. **Check Target Membership section:**
   - ✅ `WdioDemoAppUITests` should be checked
   - ❌ `WdioDemoAppTestRunner` should be unchecked

4. **Repeat for a few random files** to verify

**Common Issue:** If files are in the wrong target, you'll get compilation errors.

---

### Step 7: Build and Verify

1. **Select Scheme:**
   - Click on scheme dropdown (next to play/stop buttons)
   - Select `WdioDemoAppTestRunner`

2. **Select Destination:**
   - Click on destination dropdown
   - Select your simulator (e.g., "iPhone 17 Pro Test")

3. **Build the Project:**
   - Press ⌘B (Product → Build)
   - **Check for errors** - should compile successfully

4. **Fix any compilation warnings** (optional but recommended)

---

### Step 8: Run Tests

#### Option A: Using Xcode GUI

1. **Open Test Navigator:**
   - Press ⌘6 (View → Navigators → Test Navigator)

2. **Run All Tests:**
   - Click the diamond icon next to `WdioDemoAppUITests`

3. **Run Specific Test:**
   - Expand test classes
   - Click diamond icon next to specific test method

4. **View Results:**
   - Tests will appear in the navigator with ✅ or ❌
   - Click on test to see details

#### Option B: Using Command Line

```bash
# Navigate to project directory
cd /Users/sumesing/New_Softwares/XCUITestFramework/WdioDemoAppTestRunner

# Run all UI tests
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,id=1F09C945-1B90-4173-A744-992774EED514' \
  -only-testing:WdioDemoAppUITests

# Run specific test class
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,id=1F09C945-1B90-4173-A744-992774EED514' \
  -only-testing:WdioDemoAppUITests/WdioDemoAppLoginTest

# Run specific test method
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,id=1F09C945-1B90-4173-A744-992774EED514' \
  -only-testing:WdioDemoAppUITests/WdioDemoAppLoginTest/testNavigateToLoginScreen
```

---

## 📁 Final Project Structure

```
WdioDemoAppTestRunner/
├── WdioDemoAppTestRunner/          # Main app target (not used)
│   ├── ContentView.swift
│   ├── WdioDemoAppTestRunnerApp.swift
│   └── Assets.xcassets
│
├── WdioDemoAppUITests/             # UI Test target (where tests live)
│   ├── Core/                       # Framework source files
│   │   ├── Base/
│   │   ├── Components/
│   │   ├── Configuration/
│   │   ├── Exceptions/
│   │   ├── Pages/
│   │   └── Utils/
│   │
│   ├── BaseTest.swift              # Base test class
│   ├── LoginTest.swift             # Example test
│   ├── WdioDemoAppBasicTest.swift  # Basic app tests
│   └── WdioDemoAppLoginTest.swift  # App-specific tests
│
├── WdioDemoAppTestRunner.xcodeproj # Xcode project file
└── README.md                        # Project-specific readme
```

---

## 🎯 Creating Tests for Your App

### Example 1: Basic App Test

```swift
import XCTest

class WdioDemoAppBasicTest: BaseTest {

    func testAppLaunches() {
        logStep("Test: Verify app launches")

        XCTAssertTrue(app.exists, "App should exist")
        XCTAssertTrue(app.state == .runningForeground, "App should be running")

        logInfo("App launched successfully")
    }

    func testCanAccessElements() {
        logStep("Test: Verify we can access app elements")

        wait(2.0)  // Wait for app to fully load

        let buttons = app.buttons.count
        let textFields = app.textFields.count

        print("Found \(buttons) buttons")
        print("Found \(textFields) text fields")

        XCTAssertGreaterThan(buttons + textFields, 0, "Should have some UI elements")
    }
}
```

### Example 2: Navigation Test

```swift
import XCTest

class WdioDemoAppNavigationTest: BaseTest {

    func testNavigateToLogin() {
        logStep("Test: Navigate to login screen")

        wait(2.0)

        // Find login tab/button
        let loginTab = app.buttons["Login"]

        if loginTab.waitForExistence(timeout: 5.0) {
            loginTab.tap()
            logInfo("Tapped Login tab")
        }

        // Verify login screen loaded
        let usernameField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(usernameField.exists, "Login screen should be displayed")
    }
}
```

### Example 3: Form Interaction Test

```swift
import XCTest

class WdioDemoAppFormTest: BaseTest {

    func testFillLoginForm() {
        logStep("Test: Fill login form")

        wait(2.0)

        // Navigate to login if needed
        let loginTab = app.buttons["Login"]
        if loginTab.exists {
            loginTab.tap()
            wait(1.0)
        }

        // Fill username
        let usernameField = app.textFields.element(boundBy: 0)
        if usernameField.exists {
            usernameField.tap()
            usernameField.typeText("testuser@example.com")
            logInfo("Entered username")
        }

        // Fill password
        let passwordField = app.secureTextFields.element(boundBy: 0)
        if passwordField.exists {
            passwordField.tap()
            passwordField.typeText("password123")
            logInfo("Entered password")
        }

        // Tap login button
        let loginButton = app.buttons["LOGIN"]
        if loginButton.exists {
            loginButton.tap()
            logInfo("Tapped login button")
            wait(2.0)
        }

        XCTAssertTrue(app.exists, "App should still exist after login")
    }
}
```

---

## 🔧 Common Issues and Solutions

### Issue 1: "Device is not configured for UI testing"

**Symptom:**
```
Error: XCUIApplication use of XCUIApplication is not supported
```

**Cause:** Using SPM test bundle instead of Xcode UI Test Bundle

**Solution:** Follow this guide to create proper Xcode project (you're in the right place!)

---

### Issue 2: "Unable to resolve module dependency: 'XCUITestFramework'"

**Symptom:**
```swift
@testable import XCUITestFramework  // Error: No such module
```

**Cause:** Files are in same target, import statement is wrong

**Solution:** Remove the `@testable import XCUITestFramework` line (see Step 5)

---

### Issue 3: App doesn't launch during tests

**Symptom:** Tests run but app never appears on simulator

**Causes & Solutions:**

1. **Wrong bundle identifier:**
   ```bash
   # Verify correct bundle ID
   xcrun simctl listapps <simulator-id> | grep -i "app-name"
   ```
   Update `BaseTest.swift` with correct ID

2. **App not installed:**
   ```bash
   # Install app on simulator
   xcrun simctl install <simulator-id> /path/to/app.app
   ```

3. **Using wrong initialization:**
   ```swift
   // ❌ Wrong - tries to launch test runner app
   app = XCUIApplication()

   // ✅ Correct - launches installed app
   app = XCUIApplication(bundleIdentifier: "org.wdiodemoapp")
   ```

---

### Issue 4: "Signing for WdioDemoAppUITests requires a development team"

**Symptom:** Build fails with code signing error

**Solution:**
1. Select project in navigator
2. Select `WdioDemoAppUITests` target
3. Go to "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. Select your Team from dropdown

---

### Issue 5: Files in wrong target

**Symptom:** "Use of unresolved identifier" errors for framework classes

**Solution:**
1. Select the file with error
2. Open File Inspector (⌥⌘1)
3. In Target Membership section:
   - ✅ Check `WdioDemoAppUITests`
   - ❌ Uncheck `WdioDemoAppTestRunner`

---

### Issue 6: Cannot find simulator

**Symptom:**
```
xcodebuild: error: Unable to find a destination matching the provided destination specifier
```

**Solution:**
```bash
# List all available simulators
xcrun simctl list devices

# Use name instead of ID
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## 🧪 Framework Features Available

Once setup is complete, you have access to all framework features:

### Page Object Model
```swift
class MyAppPage: BasePage {
    private let submitButton = "submitButton"

    func submit() -> Self {
        tap(identifier: submitButton)
        return self
    }
}

let page = getScreen(MyAppPage.self)
page.submit().verifySuccess()
```

### Components
```swift
Button("loginButton", in: app)
    .verifyExists()
    .tap()

TextField("username", in: app)
    .clearAndType("testuser")
```

### Logging
```swift
logStep("Test: User Login")
logInfo("Entered credentials")
logError("Login failed")
```

### Screenshots
```swift
captureScreenshot(name: "login_screen")
```

### Waiting
```swift
wait(2.0)
waitForElement(app.buttons["Next"], timeout: 10.0)
```

### App Health
```swift
XCTAssertTrue(healthChecker.isAppRunning())
XCTAssertFalse(healthChecker.hasAppCrashed())
```

### Performance
```swift
measurePerformance(name: "Login") {
    loginPage.performLogin()
}
```

### Retry Logic
```swift
RetryUtils.retry(attempts: 3, delay: 2.0) {
    loginPage.tapLogin()
    return !loginPage.isErrorDisplayed()
}
```

### Test Data
```swift
let testData = loadTestData(filename: "loginData")
let username = JSONReader.getString(from: testData, keyPath: "user.username")
```

---

## 📊 Verification Checklist

After completing setup, verify:

- ✅ Xcode project builds without errors (⌘B)
- ✅ UI Test target exists (`WdioDemoAppUITests`)
- ✅ All framework files copied to test target
- ✅ Target membership set correctly (File Inspector)
- ✅ No `@testable import XCUITestFramework` statements
- ✅ BaseTest uses correct bundle identifier
- ✅ Target app installed on simulator
- ✅ Tests can be run from Xcode (⌘U)
- ✅ Tests can be run from command line (xcodebuild)
- ✅ App launches during test execution

---

## 🚀 Next Steps

1. **Write app-specific tests:**
   - Explore your app's UI elements
   - Create page objects for each screen
   - Write end-to-end user journeys

2. **Integrate with CI/CD:**
   - See examples in project README
   - Use xcodebuild in your pipeline
   - Store test results and screenshots

3. **Expand test coverage:**
   - Add data-driven tests
   - Test error scenarios
   - Verify edge cases

4. **Optimize tests:**
   - Use parallel execution
   - Implement retry logic
   - Add performance benchmarks

---

## 📚 Related Documentation

- [FRAMEWORK_STRUCTURE.md](FRAMEWORK_STRUCTURE.md) - Architecture overview
- [FRAMEWORK_FEATURES.md](FRAMEWORK_FEATURES.md) - Available features
- [WRITING_TESTS.md](WRITING_TESTS.md) - Test authoring guide
- [WdioDemoAppTestRunner/README.md](../WdioDemoAppTestRunner/README.md) - Project-specific setup

---

## 💡 Pro Tips

1. **Keep test target clean:** Only add files needed for testing
2. **Use descriptive test names:** Makes failures easier to diagnose
3. **One assertion per test:** Tests fail fast and clearly
4. **Take screenshots on failure:** Already configured in BaseTest
5. **Use accessibility identifiers:** More reliable than text matching
6. **Wait strategically:** Not too little, not too much
7. **Clean up after tests:** Remove test data, logout, etc.

---

**Questions or Issues?**
Refer to the "Common Issues" section or check existing test files for examples.
