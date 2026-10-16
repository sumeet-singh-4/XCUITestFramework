//
//  ConfigurationException.swift
//  XCUITestFramework
//
//  Exception for configuration-related errors
//

import Foundation

/// Exception thrown when there are configuration loading or parsing errors
public class ConfigurationException: FrameworkException {

    // MARK: - Factory Methods

    /// Configuration file not found
    public static func fileNotFound(_ fileName: String) -> ConfigurationException {
        return ConfigurationException("Configuration file '\(fileName)' not found")
    }

    /// Configuration file is invalid or corrupted
    public static func invalidFormat(_ fileName: String, reason: String? = nil) -> ConfigurationException {
        var message = "Configuration file '\(fileName)' has invalid format"
        if let reason = reason {
            message += ": \(reason)"
        }
        return ConfigurationException(message)
    }

    /// Required configuration key is missing
    public static func missingKey(_ key: String, in fileName: String) -> ConfigurationException {
        return ConfigurationException("Required configuration key '\(key)' is missing in '\(fileName)'")
    }

    /// Configuration value type mismatch
    public static func typeMismatch(_ key: String, expected: String, actual: String) -> ConfigurationException {
        return ConfigurationException("Configuration key '\(key)' expected type '\(expected)' but got '\(actual)'")
    }

    /// Environment not configured
    public static func environmentNotConfigured(_ environment: String) -> ConfigurationException {
        return ConfigurationException("Environment '\(environment)' is not configured. Please check Config directory.")
    }
}
