//
//  AppCrashException.swift
//  XCUITestFramework
//
//  Exception for app crash and health check errors
//

import Foundation
import XCTest

/// Exception thrown when the app crashes or enters an unhealthy state
public class AppCrashException: FrameworkException {

    // MARK: - Properties

    public let appState: String
    public let crashLog: String?

    // MARK: - Initialization

    public init(
        _ message: String,
        appState: String,
        crashLog: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.appState = appState
        self.crashLog = crashLog
        super.init(message, file: file, function: function, line: line)
    }

    // MARK: - Factory Methods

    /// App crashed during test execution
    public static func crashed(crashLog: String? = nil) -> AppCrashException {
        return AppCrashException(
            "Application crashed during test execution",
            appState: "notRunning",
            crashLog: crashLog
        )
    }

    /// App is not responding
    public static func notResponding() -> AppCrashException {
        return AppCrashException(
            "Application is not responding",
            appState: "runningBackgroundSuspended"
        )
    }

    /// App failed to launch
    public static func failedToLaunch(reason: String? = nil) -> AppCrashException {
        var message = "Application failed to launch"
        if let reason = reason {
            message += ": \(reason)"
        }
        return AppCrashException(message, appState: "unknown")
    }

    /// App terminated unexpectedly
    public static func unexpectedTermination() -> AppCrashException {
        return AppCrashException(
            "Application terminated unexpectedly",
            appState: "notRunning"
        )
    }

    /// App health check failed
    public static func healthCheckFailed(state: XCUIApplication.State, retryCount: Int) -> AppCrashException {
        return AppCrashException(
            "App health check failed after \(retryCount) retries. Current state: \(state)",
            appState: "\(state)"
        )
    }

    /// App restart failed
    public static func restartFailed(attempts: Int) -> AppCrashException {
        return AppCrashException(
            "Failed to restart application after \(attempts) attempts",
            appState: "unknown"
        )
    }

    // MARK: - Logging

    public override var errorDescription: String? {
        var description = super.errorDescription ?? ""
        if let crashLog = crashLog {
            description += "\n\nCrash Log:\n\(crashLog)"
        }
        return description
    }
}
