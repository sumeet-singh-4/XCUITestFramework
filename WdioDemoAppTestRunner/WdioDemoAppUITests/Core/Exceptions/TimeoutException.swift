//
//  TimeoutException.swift
//  XCUITestFramework
//
//  Exception for timeout-related errors
//

import Foundation

/// Exception thrown when operations exceed their timeout duration
public class TimeoutException: FrameworkException {

    // MARK: - Properties

    public let operation: String
    public let timeout: TimeInterval
    public let actualDuration: TimeInterval?

    // MARK: - Initialization

    public init(
        _ operation: String,
        timeout: TimeInterval,
        actualDuration: TimeInterval? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.operation = operation
        self.timeout = timeout
        self.actualDuration = actualDuration

        var message = "Operation '\(operation)' timed out after \(timeout) seconds"
        if let actualDuration = actualDuration {
            message += " (actual duration: \(actualDuration) seconds)"
        }

        super.init(message, file: file, function: function, line: line)
    }

    // MARK: - Factory Methods

    /// Element wait timeout
    public static func elementWait(_ elementIdentifier: String, timeout: TimeInterval) -> TimeoutException {
        return TimeoutException("Waiting for element '\(elementIdentifier)'", timeout: timeout)
    }

    /// Condition wait timeout
    public static func conditionWait(_ condition: String, timeout: TimeInterval) -> TimeoutException {
        return TimeoutException("Waiting for condition '\(condition)'", timeout: timeout)
    }

    /// App launch timeout
    public static func appLaunch(timeout: TimeInterval) -> TimeoutException {
        return TimeoutException("App launch", timeout: timeout)
    }

    /// Screen load timeout
    public static func screenLoad(_ screenName: String, timeout: TimeInterval) -> TimeoutException {
        return TimeoutException("Loading screen '\(screenName)'", timeout: timeout)
    }

    /// Network request timeout
    public static func networkRequest(_ endpoint: String, timeout: TimeInterval) -> TimeoutException {
        return TimeoutException("Network request to '\(endpoint)'", timeout: timeout)
    }

    /// Animation completion timeout
    public static func animation(timeout: TimeInterval) -> TimeoutException {
        return TimeoutException("Animation completion", timeout: timeout)
    }
}
