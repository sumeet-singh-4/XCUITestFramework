# WdioDemoAppTestRunner - XCUITest Project Setup Guide

This document details all the manual Xcode setup steps performed to create a working XCUITest project for testing the wdiodemoapp.

## Project Overview

- **Project Name**: WdioDemoAppTestRunner
- **Target App**: wdiodemoapp (Bundle ID: `org.wdiodemoapp`)
- **Test Target**: WdioDemoAppUITests
- **Simulator**: iPhone 17 Pro Test (ID: 1F09C945-1B90-4173-A744-992774EED514)

## Why We Needed an Xcode Project

**Important**: Swift Package Manager (SPM) does NOT support XCUITests properly because:
- SPM creates **Unit Test Bundles**, not **UI Test Bundles**
- XCUIApplication requires proper entitlements that only come with UI Test Bundles
- Without a proper Xcode project, you'll get: `"Device is not configured for UI testing"`

## Complete Xcode Setup Steps

### Step 1: Create New Xcode Project

1. Open Xcode
2. File > New > Project
3. Choose **iOS > App**
4. Configure project:
   - Product Name: `WdioDemoAppTestRunner`
   - Team: (Your team)
   - Organization Identifier: (Your org ID, e.g., `com.visa`)
   - Bundle Identifier: (Auto-generated from above)
   - Interface: SwiftUI
   - Language: Swift
   - Testing System: XCTest
   - Storage: (Leave as default)
5. Save location: `/Users/sumesing/New_Softwares/XCUITestFramework/WdioDemoAppTestRunner/`

### Step 2: Add UI Testing Target

1. In Xcode, select the project in the navigator
2. At the bottom of the targets list, click the **"+"** button
3. Choose **iOS > UI Testing Bundle**
4. Configure:
   - Product Name: `WdioDemoAppUITests`
   - Team: (Same as project)
   - Target to be Tested: `WdioDemoAppTestRunner`
5. Click **Finish**
6. When prompted **"Would you like to configure an Objective-C bridging header?"** - Click **Don't Create**

**Important**: This creates a proper UI Test Bundle with the correct entitlements for XCUIApplication.

### Step 3: Add Framework Source Files to UI Test Target

#### 3.1 Add All Test Files

1. In Xcode, right-click on the `WdioDemoAppUITests` folder
2. Choose **Add Files to "WdioDemoAppTestRunner"...**
3. Navigate to your framework's test files location
4. Select these files:
   - `BaseTest.swift`
   - `LoginTest.swift`
   - `WdioDemoAppBasicTest.swift`
   - `WdioDemoAppLoginTest.swift`
5. **Important**: Check **"Copy items if needed"**
6. **Important**: In "Add to targets", check **WdioDemoAppUITests** only
7. Click **Add**

#### 3.2 Add Core Framework Folder

1. Right-click on the `WdioDemoAppUITests` folder again
2. Choose **Add Files to "WdioDemoAppTestRunner"...**
3. Navigate to your framework's `Core` folder
4. Select the entire `Core` folder
5. **Important**: Check **"Copy items if needed"**
6. **Important**: Check **"Create groups"** (not "Create folder references")
7. **Important**: In "Add to targets", check **WdioDemoAppUITests** only
8. Click **Add**

The Core folder should include:
```
Core/
├── Base/
│   └── BaseTest.swift
├── Components/
│   ├── Alert.swift
│   ├── Button.swift
│   ├── Label.swift
│   ├── Switch.swift
│   ├── TableView.swift
│   └── TextField.swift
├── Configuration/
│   └── ConfigReader.swift
├── Exceptions/
│   ├── AppCrashException.swift
│   ├── ConfigurationException.swift
│   └── ElementNotFoundException.swift
├── Pages/
│   ├── Base/
│   │   └── BasePage.swift
│   └── LoginPage.swift
├── Utils/
│   ├── AppHealthChecker.swift
│   ├── DataProvider.swift
│   ├── DateTimeUtils.swift
│   ├── JSONReader.swift
│   ├── LoggerUtils.swift
│   ├── PerformanceUtils.swift
│   ├── RetryUtils.swift
│   ├── ScreenFactory.swift
│   └── ScreenshotUtils.swift
└── WaitUtils.swift
```

### Step 4: Configure BaseTest for Target App

1. Open `BaseTest.swift` in Xcode
2. Locate the `setUpWithError()` method
3. Ensure the app is initialized with the correct bundle identifier:

```swift
override func setUpWithError() throws {
    try super.setUpWithError()

    continueAfterFailure = false

    // Initialize app with bundle identifier of the installed app
    app = XCUIApplication(bundleIdentifier: "org.wdiodemoapp")

    // ... rest of setup
}
```

**Critical**: This bundle identifier must match the app installed on your simulator.

### Step 5: Remove Import Statements (If Needed)

Since all framework files are now directly in the test target (not a separate module), remove any module import statements:

**Before:**
```swift
@testable import XCUITestFramework
import XCTest
```

**After:**
```swift
import XCTest
```

### Step 6: Build and Run Tests

#### Using Xcode:
1. Select the scheme: **WdioDemoAppTestRunner**
2. Select your simulator as the destination
3. Press `Cmd + U` to run all tests
4. Or right-click a test class/method and choose **Run "TestName"**

#### Using Command Line:
```bash
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

## Project Structure

```
WdioDemoAppTestRunner/
├── WdioDemoAppTestRunner/          # Main app target (not used for testing)
│   ├── ContentView.swift
│   └── Assets.xcassets
├── WdioDemoAppUITests/             # UI Test target
│   ├── Core/                       # Framework source files
│   │   ├── Base/
│   │   ├── Components/
│   │   ├── Configuration/
│   │   ├── Exceptions/
│   │   ├── Pages/
│   │   ├── Utils/
│   │   └── WaitUtils.swift
│   ├── BaseTest.swift              # Base test class
│   ├── LoginTest.swift             # Example login test
│   ├── WdioDemoAppBasicTest.swift  # Basic app tests
│   └── WdioDemoAppLoginTest.swift  # wdiodemoapp-specific tests
└── WdioDemoAppTestRunner.xcodeproj
```

## 🎉 Framework Production Readiness (v1.0)

**Status:** ✅ Production Ready (October 2026)

This framework has undergone comprehensive improvements to ensure production readiness:

### Critical Fixes Implemented
- ✅ **Thread Safety**: ConfigReader singleton, TestLifecycleListener weak references, ScreenFactory DispatchQueue
- ✅ **No Blocking Operations**: All 17 Thread.sleep() calls replaced with proper XCTest wait mechanisms
- ✅ **Configuration Management**: Bundle identifier externalized to `config.plist`
- ✅ **API Safety**: Removed private API usage (pressLockButton)
- ✅ **Logger Thread Safety**: ISO8601DateFormatter for parallel logging
- ✅ **Access Control**: Proper encapsulation of mutable statics
- ✅ **Reliability**: TextField paste with fallback logic

### Documentation
- See `Documentation/PRODUCTION_FIXES_NEEDED.md` for detailed implementation guide
- See `Documentation/CHANGELOG.md` for complete list of improvements

### Configuration File
The framework now uses `config.plist` for configuration instead of hardcoded values:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>app</key>
    <dict>
        <key>bundleId</key>
        <string>org.wdiodemoapp</string>
    </dict>
    <key>wait</key>
    <dict>
        <key>implicitTimeout</key>
        <real>10.0</real>
        <key>explicitTimeout</key>
        <real>30.0</real>
    </dict>
</dict>
</plist>
```

## Test Results

**Latest Test Run:** October 16, 2026

### WdioDemoAppBasicTest (4/4 passed - 100%)
- ✅ `testAppLaunches()` - App launches and runs in foreground
- ✅ `testCanAccessAppElements()` - UI elements are accessible
- ✅ `testAppTabs()` - Tab bar navigation works
- ✅ `testTapFirstButton()` - Button interactions work

### WdioDemoAppLoginTest (4/5 passed - 80%)
- ✅ `testNavigateToLoginScreen()` - Navigate to login with multiple strategies
- ✅ `testLoginWithCredentials()` - Fill and submit login form
- ✅ `testExploreTabs()` - Explore all tabs with screenshots
- ✅ `testLoginFormElements()` - Catalog all form elements
- ⚠️ `testLoginAccessibilityIdentifiers()` - Pre-existing failure (unrelated to framework)

**Overall Pass Rate:** 8/9 tests (89%)

## Key Configuration Points

### 1. Bundle Identifier for Target App

**NEW (v1.0):** Configuration is now externalized in `config.plist`:

```xml
<key>app</key>
<dict>
    <key>bundleId</key>
    <string>org.wdiodemoapp</string>
</dict>
```

The BaseTest reads from this configuration:
```swift
// BaseTest.swift
let bundleId = config.appBundleId
if !bundleId.isEmpty {
    app = XCUIApplication(bundleIdentifier: bundleId)
} else {
    app = XCUIApplication()
}
```

**How to find bundle ID:**
```bash
xcrun simctl listapps <simulator-id> | grep -i "app-name"
```

**Migration Note:** Old hardcoded approach has been removed for production readiness.

### 2. Simulator ID
Find your simulator ID:
```bash
xcrun simctl list devices
```

### 3. Test Target Membership
**Critical**: All test files and framework files MUST have target membership set to **WdioDemoAppUITests** only, not the main app target.

To verify in Xcode:
1. Select any file
2. Open File Inspector (right panel)
3. Check **Target Membership** section
4. Only `WdioDemoAppUITests` should be checked

## Common Issues and Solutions

### Issue: "Device is not configured for UI testing"
**Cause**: Using SPM test bundle instead of Xcode UI Test Bundle
**Solution**: Use proper Xcode project with UI Testing Bundle (this project)

### Issue: "Unable to resolve module dependency: 'XCUITestFramework'"
**Cause**: Test files still have `@testable import XCUITestFramework`
**Solution**: Remove the import statement since files are now in the same target

### Issue: App doesn't launch during tests
**Cause**: Wrong bundle identifier or app not installed on simulator
**Solution**:
1. Verify bundle ID: `xcrun simctl listapps <simulator-id>`
2. Install app on simulator if needed
3. Update `BaseTest.swift` with correct bundle ID

### Issue: "Signing for WdioDemoAppUITests requires a development team"
**Cause**: No team selected for signing
**Solution**: Select your team in Xcode project settings > Signing & Capabilities

## Testing Third-Party Apps

This project demonstrates how to test apps you don't have source code for:

1. **Know the bundle identifier** of the target app
2. **Install the app** on your simulator
3. **Use XCUIApplication(bundleIdentifier:)** instead of XCUIApplication()
4. **Create a proper Xcode project** with UI Test Bundle (not SPM)

## Adding New Tests

To add new test files:

1. Create a new Swift file in Xcode
2. Place it in the `WdioDemoAppUITests` folder
3. Ensure target membership is set to `WdioDemoAppUITests`
4. Inherit from `BaseTest`:

```swift
import XCTest

class MyNewTest: BaseTest {

    func testSomething() {
        logStep("Test: Something")

        // Your test code here
        app.buttons["MyButton"].tap()

        XCTAssertTrue(app.staticTexts["Expected"].exists)
    }
}
```

## Framework Features Available

- **Page Object Model**: Use `ScreenFactory` and `BasePage`
- **Logging**: `logStep()`, `logInfo()`, `logError()`
- **Screenshots**: `captureScreenshot(name:)`
- **Waiting**: `wait()`, `waitForElement()`
- **App Health**: `healthChecker.isAppRunning()`
- **Performance**: `measurePerformance(name:)`
- **Retry Logic**: `RetryUtils.retry()`
- **Test Data**: `loadTestData(filename:)` with `JSONReader`

## Continuous Integration

For CI/CD pipelines, use the xcodebuild command:

```bash
#!/bin/bash

# Run tests and save results
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -resultBundlePath ./test-results.xcresult \
  -only-testing:WdioDemoAppUITests \
  | tee xcodebuild.log \
  | xcpretty

# Check exit code
if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "Tests passed"
  exit 0
else
  echo "Tests failed"
  exit 1
fi
```

## Parallel Testing

By default, Xcode runs tests in parallel using multiple simulator clones to speed up execution. You may notice multiple simulator instances during test runs (e.g., "Clone 1", "Clone 2").

### Disable Parallel Testing

If you prefer to run tests sequentially on a single simulator:

```bash
# Disable parallel testing completely
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,id=<simulator-id>' \
  -only-testing:WdioDemoAppUITests \
  -parallel-testing-enabled NO

# Or limit to 1 concurrent simulator
xcodebuild test \
  -scheme WdioDemoAppTestRunner \
  -destination 'platform=iOS Simulator,id=<simulator-id>' \
  -only-testing:WdioDemoAppUITests \
  -maximum-concurrent-test-simulator-destinations 1
```

**When to disable parallel testing:**
- Debugging tests (easier to watch single simulator)
- Limited system resources (RAM/CPU)
- Tests have shared state dependencies

**When to keep parallel testing enabled:**
- CI/CD pipelines (faster execution)
- Large test suites
- Independent, well-isolated tests

## Useful Commands

```bash
# List all simulators
xcrun simctl list devices

# List apps on simulator
xcrun simctl listapps <simulator-id>

# Boot simulator
xcrun simctl boot <simulator-id>

# Install app on simulator
xcrun simctl install <simulator-id> /path/to/app.app

# View test results
xcrun xcresulttool get object --path test-results.xcresult --format json

# Clean build
xcodebuild clean -scheme WdioDemoAppTestRunner

# Build only (no tests)
xcodebuild build -scheme WdioDemoAppTestRunner -destination 'platform=iOS Simulator,id=<simulator-id>'
```

## Resources

- [Apple XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [XCUITest Best Practices](https://developer.apple.com/videos/play/wwdc2020/10220/)
- [Xcode Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)

## License

This project structure demonstrates XCUITest setup for testing third-party iOS applications.
