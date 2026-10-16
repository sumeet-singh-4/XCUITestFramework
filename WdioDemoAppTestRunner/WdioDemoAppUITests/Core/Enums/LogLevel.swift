//
//  LogLevel.swift
//  XCUITestFramework
//
//  Enumeration for logging levels
//

import Foundation

/// Represents logging severity levels
public enum LogLevel: Int, CaseIterable, Comparable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5
    case none = 6

    /// Log level prefix/emoji
    public var prefix: String {
        switch self {
        case .verbose:
            return "🔍"
        case .debug:
            return "🐛"
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        case .critical:
            return "🔥"
        case .none:
            return ""
        }
    }

    /// Log level name
    public var name: String {
        switch self {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "CRITICAL"
        case .none:
            return "NONE"
        }
    }

    /// Check if logging should occur based on current level
    public func shouldLog(minimumLevel: LogLevel) -> Bool {
        return self.rawValue >= minimumLevel.rawValue
    }

    /// Comparable implementation
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
