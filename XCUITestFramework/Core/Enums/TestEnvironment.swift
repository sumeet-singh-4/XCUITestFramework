//
//  TestEnvironment.swift
//  XCUITestFramework
//
//  Enumeration for test environments
//

import Foundation

/// Represents test execution environments
public enum TestEnvironment: String, CaseIterable {
    case development = "dev"
    case qa = "qa"
    case staging = "staging"
    case production = "prod"
    case local = "local"
    case `default` = "default"

    /// Configuration file name
    public var configFileName: String {
        return "config-\(rawValue).plist"
    }

    /// Check if production environment
    public var isProduction: Bool {
        return self == .production
    }

    /// Check if safe to run destructive tests
    public var isSafeForDestructiveTesting: Bool {
        return self == .development || self == .qa || self == .local
    }

    /// Environment display name
    public var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .qa:
            return "QA"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        case .local:
            return "Local"
        case .default:
            return "Default"
        }
    }

    /// Initialize from string (case-insensitive)
    public init?(fromString string: String) {
        if let env = TestEnvironment.allCases.first(where: { $0.rawValue.lowercased() == string.lowercased() }) {
            self = env
        } else {
            return nil
        }
    }
}
