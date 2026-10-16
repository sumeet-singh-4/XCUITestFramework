import XCTest

/// Base test class for all XCUITest test cases
/// Provides common setup, teardown, and utilities
class BaseTest: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!
    var config: ConfigReader!
    var healthChecker: AppHealthChecker!

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Stop immediately when a failure occurs
        continueAfterFailure = false

        // Initialize configuration
        config = ConfigReader.shared

        // Initialize app with bundle identifier from configuration
        let bundleId = config.appBundleId
        if !bundleId.isEmpty {
            app = XCUIApplication(bundleIdentifier: bundleId)
        } else {
            app = XCUIApplication()
        }

        // Configure app launch arguments and environment
        setupAppLaunchConfiguration()

        // Launch app
        app.launch()

        // Initialize health checker
        healthChecker = AppHealthChecker(app: app)

        // Verify app launched successfully
        guard healthChecker.verifyAppLaunched() else {
            throw TestSetupError.appLaunchFailed
        }

        // Clear screen factory cache
        ScreenFactory.clearCache()

        print("✅ [BaseTest] Test setup completed for: \(name)")
    }

    override func tearDownWithError() throws {
        // Capture screenshot on failure
        if let testRun = testRun, testRun.hasSucceeded == false {
            captureFailureScreenshot()
        }

        // Terminate app
        app.terminate()

        // Clear screen factory cache
        ScreenFactory.clearCache()

        // Cleanup
        app = nil
        healthChecker = nil

        print("✅ [BaseTest] Test teardown completed for: \(name)")

        try super.tearDownWithError()
    }

    // MARK: - App Launch Configuration

    /// Setup app launch configuration
    /// Override this method in subclasses to customize launch configuration
    func setupAppLaunchConfiguration() {
        // Set launch arguments
        app.launchArguments = [
            "-UITesting",
            "-DisableAnimations"
        ]

        // Set launch environment
        app.launchEnvironment = [
            "ENV": config.getCurrentEnvironment(),
            "UITEST_MODE": "true"
        ]
    }

    // MARK: - Screenshot Utilities

    /// Capture screenshot on test failure
    func captureFailureScreenshot() {
        let testName = name.replacingOccurrences(of: "[", with: "")
                           .replacingOccurrences(of: "]", with: "")
                           .replacingOccurrences(of: " ", with: "_")

        ScreenshotUtils.captureFailureScreenshot(testName: testName)
        print("📸 [BaseTest] Captured failure screenshot for: \(testName)")
    }

    /// Capture screenshot with custom name
    func captureScreenshot(name: String) {
        ScreenshotUtils.captureAndAttach(name: name, lifetime: .keepAlways)
        print("📸 [BaseTest] Captured screenshot: \(name)")
    }

    // MARK: - Screen Factory Helpers

    /// Get screen instance using ScreenFactory
    /// - Parameter screenType: Type of screen to get
    /// - Returns: Screen instance
    func getScreen<T: BasePage>(_ screenType: T.Type) -> T {
        return ScreenFactory.getScreen(screenType, app: app)
    }

    /// Get screen instance with custom timeout using ScreenFactory
    /// - Parameters:
    ///   - screenType: Type of screen to get
    ///   - timeout: Custom timeout
    /// - Returns: Screen instance
    func getScreen<T: BasePage>(_ screenType: T.Type, timeout: TimeInterval) -> T {
        return ScreenFactory.getScreen(screenType, app: app, timeout: timeout)
    }

    // MARK: - Wait Utilities

    /// Wait for specific duration
    /// - Parameter seconds: Number of seconds to wait
    func wait(_ seconds: TimeInterval) {
        if seconds > 0 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: seconds))
        }
    }

    /// Wait for condition to be true
    /// - Parameters:
    ///   - timeout: Maximum time to wait
    ///   - condition: Condition to check
    /// - Returns: True if condition met, false if timeout
    @discardableResult
    func waitForCondition(timeout: TimeInterval = 10.0, condition: () -> Bool) -> Bool {
        return RetryUtils.retryUntil(timeout: timeout, interval: 0.5, condition: condition)
    }

    // MARK: - App Control

    /// Restart the app
    func restartApp() {
        healthChecker.restartApp()
    }

    /// Terminate the app
    func terminateApp() {
        app.terminate()
        print("🛑 [BaseTest] App terminated")
    }

    /// Relaunch the app
    func relaunchApp() {
        app.terminate()
        wait(1.0)
        app.launch()
        guard healthChecker.verifyAppLaunched() else {
            XCTFail("Failed to relaunch app")
            return
        }
        print("🔄 [BaseTest] App relaunched")
    }

    /// Send app to background
    /// - Parameter duration: Duration to keep app in background
    func sendAppToBackground(duration: TimeInterval = 5.0) {
        XCUIDevice.shared.press(.home)
        wait(duration)
        app.activate()
        print("⏸️ [BaseTest] App sent to background for \(duration)s")
    }

    // MARK: - Device Utilities

    /// Rotate device to landscape
    func rotateToLandscape() {
        XCUIDevice.shared.orientation = .landscapeLeft
        print("🔄 [BaseTest] Rotated to landscape")
    }

    /// Rotate device to portrait
    func rotateToPortrait() {
        XCUIDevice.shared.orientation = .portrait
        print("🔄 [BaseTest] Rotated to portrait")
    }

    /// Lock device
    /// Note: Device locking is not supported via official XCUITest APIs
    /// Consider testing lock screen scenarios manually or via alternative approaches
    func lockDevice() {
        print("⚠️ [BaseTest] Device locking not supported via official XCUITest APIs")
        print("   Consider manual testing or using XCTest UI automation for lock screen scenarios")
    }

    // MARK: - Alert Handling

    /// Handle system alert by tapping button
    /// - Parameters:
    ///   - buttonTitle: Title of button to tap (e.g., "Allow", "Don't Allow")
    ///   - timeout: Maximum time to wait for alert
    /// - Returns: True if alert handled, false otherwise
    @discardableResult
    func handleSystemAlert(buttonTitle: String, timeout: TimeInterval = 5.0) -> Bool {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch

        if alert.waitForExistence(timeout: timeout) {
            let button = alert.buttons[buttonTitle]
            if button.exists {
                button.tap()
                print("✅ [BaseTest] Handled system alert: '\(buttonTitle)'")
                return true
            }
        }

        print("⚠️ [BaseTest] System alert not found or button '\(buttonTitle)' not available")
        return false
    }

    // MARK: - Logging

    /// Log test step
    /// - Parameter message: Message to log
    func logStep(_ message: String) {
        print("📝 [TEST STEP] \(message)")
    }

    /// Log test info
    /// - Parameter message: Message to log
    func logInfo(_ message: String) {
        print("ℹ️ [TEST INFO] \(message)")
    }

    // MARK: - Test Data

    /// Load test data from JSON file
    /// - Parameter filename: Name of JSON file (without extension)
    /// - Returns: Dictionary with test data
    func loadTestData(filename: String) -> [String: Any] {
        return JSONReader.readJSON(filename: filename)
    }

    /// Get test data value by key path
    /// - Parameters:
    ///   - json: JSON dictionary
    ///   - keyPath: Dot-separated key path
    /// - Returns: Value at key path
    func getTestDataValue(from json: [String: Any], keyPath: String) -> Any? {
        return JSONReader.getValue(from: json, keyPath: keyPath)
    }

    // MARK: - Performance Testing

    /// Measure performance of operation
    /// - Parameters:
    ///   - name: Name of the measurement
    ///   - operation: Operation to measure
    func measurePerformance(name: String, operation: () -> Void) {
        measure {
            operation()
        }
        print("⏱️ [BaseTest] Measured performance for: \(name)")
    }
}

// MARK: - Test Setup Error

enum TestSetupError: Error {
    case appLaunchFailed

    var localizedDescription: String {
        switch self {
        case .appLaunchFailed:
            return "App failed to launch during test setup"
        }
    }
}
