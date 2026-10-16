//
//  Logger.swift
//  XCUITestFramework
//
//  Centralized logging utility with log levels
//

import Foundation

/// Centralized logger using LogLevel enum
public class Logger {

    // MARK: - Properties

    public private(set) static var minimumLevel: LogLevel = .info
    public private(set) static var isEnabled: Bool = true

    // MARK: - Configuration

    /// Configure logger settings
    /// - Parameters:
    ///   - level: Minimum log level to display
    ///   - enabled: Whether logging is enabled
    public static func configure(level: LogLevel, enabled: Bool = true) {
        minimumLevel = level
        isEnabled = enabled
    }

    // MARK: - Logging Methods

    public static func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .verbose, message: message, file: file, function: function, line: line)
    }

    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }

    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }

    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }

    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }

    public static func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .critical, message: message, file: file, function: function, line: line)
    }

    // MARK: - Core Logging

    private static func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        guard isEnabled else { return }
        guard level.shouldLog(minimumLevel: minimumLevel) else { return }

        let fileName = (file as NSString).lastPathComponent
        let timestamp = getCurrentTimeString()

        let logMessage = "\(level.prefix) [\(timestamp)] [\(level.name)] [\(fileName):\(line)] \(message)"
        print(logMessage)
    }

    // MARK: - Date Formatting

    /// Thread-safe date formatting using ISO8601DateFormatter
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withTime, .withFractionalSeconds]
        return formatter
    }()

    /// Helper to format current time in readable format
    private static func getCurrentTimeString() -> String {
        let isoString = dateFormatter.string(from: Date())
        // Extract time portion from ISO8601 format (e.g., "13:45:30.123" from "2024-01-15T13:45:30.123Z")
        if let timeRange = isoString.range(of: #"\d{2}:\d{2}:\d{2}\.\d{3}"#, options: .regularExpression) {
            return String(isoString[timeRange])
        }
        return isoString
    }
}
