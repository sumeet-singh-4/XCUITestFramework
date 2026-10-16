import XCTest

/// Utility class for monitoring app health and state
public class AppHealthChecker {

    // MARK: - Properties

    private let app: XCUIApplication

    // MARK: - Initialization

    public init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - App State Monitoring

    /// Check if app is running
    /// - Returns: True if app is running, false otherwise
    public func isAppRunning() -> Bool {
        let state = app.state
        let running = state == .runningForeground || state == .runningBackground
        print("ℹ️ [HealthCheck] App running: \(running) (state: \(stateToString(state)))")
        return running
    }

    /// Check if app is in foreground
    /// - Returns: True if app is in foreground, false otherwise
    public func isAppInForeground() -> Bool {
        let inForeground = app.state == .runningForeground
        print("ℹ️ [HealthCheck] App in foreground: \(inForeground)")
        return inForeground
    }

    /// Check if app is in background
    /// - Returns: True if app is in background, false otherwise
    public func isAppInBackground() -> Bool {
        let inBackground = app.state == .runningBackground
        print("ℹ️ [HealthCheck] App in background: \(inBackground)")
        return inBackground
    }

    /// Get current app state
    /// - Returns: XCUIApplication.State
    public func getAppState() -> XCUIApplication.State {
        return app.state
    }

    /// Get app state as string
    /// - Returns: String representation of app state
    public func getAppStateString() -> String {
        return stateToString(app.state)
    }

    // MARK: - App Launch Verification

    /// Verify app launched successfully
    /// - Parameters:
    ///   - timeout: Maximum time to wait for launch
    /// - Returns: True if app launched successfully, false otherwise
    public func verifyAppLaunched(timeout: TimeInterval = 10.0) -> Bool {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if isAppRunning() {
                print("✅ [HealthCheck] App launched successfully")
                return true
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }

        print("❌ [HealthCheck] App failed to launch within \(timeout)s")
        return false
    }

    /// Wait for app to reach specific state
    /// - Parameters:
    ///   - state: Target state
    ///   - timeout: Maximum time to wait
    /// - Returns: True if app reached the state, false otherwise
    public func waitForAppState(_ state: XCUIApplication.State, timeout: TimeInterval = 10.0) -> Bool {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if app.state == state {
                print("✅ [HealthCheck] App reached state: \(stateToString(state))")
                return true
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }

        print("❌ [HealthCheck] App did not reach state \(stateToString(state)) within \(timeout)s")
        return false
    }

    // MARK: - App Crash Detection

    /// Check if app has crashed (by checking if it's no longer running)
    /// - Returns: True if app appears to have crashed, false otherwise
    public func hasAppCrashed() -> Bool {
        let crashed = app.state == .notRunning
        if crashed {
            print("💥 [HealthCheck] App appears to have crashed or terminated")
        }
        return crashed
    }

    /// Monitor app for crashes during operation
    /// - Parameters:
    ///   - duration: How long to monitor
    ///   - checkInterval: How often to check
    /// - Returns: True if app remained stable, false if crash detected
    public func monitorForCrashes(duration: TimeInterval, checkInterval: TimeInterval = 1.0) -> Bool {
        let startTime = Date()
        print("👀 [HealthCheck] Monitoring app for crashes for \(duration)s...")

        while Date().timeIntervalSince(startTime) < duration {
            if hasAppCrashed() {
                print("❌ [HealthCheck] Crash detected during monitoring")
                return false
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: checkInterval))
        }

        print("✅ [HealthCheck] No crashes detected during \(duration)s monitoring period")
        return true
    }

    // MARK: - App Restart

    /// Restart the app
    /// - Returns: True if restart successful, false otherwise
    @discardableResult
    public func restartApp() -> Bool {
        print("🔄 [HealthCheck] Restarting app...")

        app.terminate()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        app.launch()
        let launched = verifyAppLaunched()

        if launched {
            print("✅ [HealthCheck] App restarted successfully")
        } else {
            print("❌ [HealthCheck] App restart failed")
        }

        return launched
    }

    /// Restart app if it has crashed
    /// - Returns: True if app was restarted or is still running, false if restart failed
    @discardableResult
    public func restartIfCrashed() -> Bool {
        if hasAppCrashed() {
            print("⚠️ [HealthCheck] App crashed, attempting restart...")
            return restartApp()
        }
        return true
    }

    // MARK: - Memory and Performance Monitoring

    /// Note: XCUITest has limited capability for memory monitoring
    /// For detailed performance testing, use XCTest Performance APIs or Instruments

    /// Verify app is responsive by checking if an element appears
    /// - Parameters:
    ///   - element: Element to check for responsiveness
    ///   - timeout: Maximum time to wait
    /// - Returns: True if app is responsive, false otherwise
    public func isAppResponsive(checkElement element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let responsive = element.waitForExistence(timeout: timeout)
        if responsive {
            print("✅ [HealthCheck] App is responsive")
        } else {
            print("⚠️ [HealthCheck] App may not be responsive (element not found)")
        }
        return responsive
    }

    // MARK: - Alert Detection

    /// Check if system alert is present (e.g., permissions, notifications)
    /// - Returns: True if alert is present, false otherwise
    public func isSystemAlertPresent() -> Bool {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alertPresent = springboard.alerts.firstMatch.exists

        if alertPresent {
            print("⚠️ [HealthCheck] System alert detected")
        }

        return alertPresent
    }

    /// Get system alert text if present
    /// - Returns: Alert text or nil if no alert
    public func getSystemAlertText() -> String? {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch

        if alert.exists {
            return alert.staticTexts.firstMatch.label
        }

        return nil
    }

    // MARK: - Health Report

    /// Generate comprehensive health report
    /// - Returns: Dictionary with health information
    public func generateHealthReport() -> [String: Any] {
        let report: [String: Any] = [
            "timestamp": Date(),
            "appState": getAppStateString(),
            "isRunning": isAppRunning(),
            "inForeground": isAppInForeground(),
            "inBackground": isAppInBackground(),
            "hasCrashed": hasAppCrashed(),
            "systemAlertPresent": isSystemAlertPresent()
        ]

        return report
    }

    /// Print health report
    public func printHealthReport() {
        let report = generateHealthReport()
        print("📊 [HealthCheck] App Health Report:")
        for (key, value) in report {
            print("  \(key): \(value)")
        }
    }

    // MARK: - Helper Methods

    /// Convert app state to string
    /// - Parameter state: XCUIApplication.State
    /// - Returns: String representation
    private func stateToString(_ state: XCUIApplication.State) -> String {
        switch state {
        case .notRunning:
            return "notRunning"
        case .runningForeground:
            return "runningForeground"
        case .runningBackground:
            return "runningBackground"
        case .runningBackgroundSuspended:
            return "runningBackgroundSuspended"
        default:
            return "unknown"
        }
    }
}
