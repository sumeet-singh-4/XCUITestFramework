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

    public static var minimumLevel: LogLevel = .info
    public static var isEnabled: Bool = true

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
        let timestamp = dateFormatter.string(from: Date())

        let logMessage = "\(level.prefix) [\(timestamp)] [\(level.name)] [\(fileName):\(line)] \(message)"
        print(logMessage)
    }

    // MARK: - Date Formatting

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
