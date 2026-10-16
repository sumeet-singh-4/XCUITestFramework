//
//  FrameworkException.swift
//  XCUITestFramework
//
//  Base exception class for all framework-specific errors
//

import Foundation

/// Base exception class for all XCUITestFramework errors
public class FrameworkException: Error, LocalizedError {

    // MARK: - Properties

    public let message: String
    public let underlyingError: Error?
    public let timestamp: Date
    public let file: String
    public let function: String
    public let line: Int

    // MARK: - Initialization

    public init(
        _ message: String,
        underlyingError: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.message = message
        self.underlyingError = underlyingError
        self.timestamp = Date()
        self.file = (file as NSString).lastPathComponent
        self.function = function
        self.line = line
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        var description = "[\(type(of: self))] \(message)"
        if let underlyingError = underlyingError {
            description += "\nUnderlying Error: \(underlyingError.localizedDescription)"
        }
        description += "\nLocation: \(file):\(line) in \(function)"
        description += "\nTimestamp: \(timestamp)"
        return description
    }

    // MARK: - Logging

    /// Log this exception with details
    public func log() {
        print("❌ \(errorDescription ?? "Unknown error")")
    }
}
