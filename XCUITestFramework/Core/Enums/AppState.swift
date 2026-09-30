//
//  AppState.swift
//  XCUITestFramework
//
//  Enumeration for application states
//

import Foundation
import XCTest

/// Represents application states
public enum AppState: Int, CaseIterable {
    case unknown = 0
    case notRunning = 1
    case runningBackgroundSuspended = 2
    case runningBackground = 3
    case runningForeground = 4

    /// Initialize from XCUIApplication.State
    public init(from xcuiState: XCUIApplication.State) {
        switch xcuiState {
        case .notRunning:
            self = .notRunning
        case .runningBackgroundSuspended:
            self = .runningBackgroundSuspended
        case .runningBackground:
            self = .runningBackground
        case .runningForeground:
            self = .runningForeground
        case .unknown:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }

    /// Convert to XCUIApplication.State
    public var xcuiState: XCUIApplication.State {
        switch self {
        case .unknown:
            return .unknown
        case .notRunning:
            return .notRunning
        case .runningBackgroundSuspended:
            return .runningBackgroundSuspended
        case .runningBackground:
            return .runningBackground
        case .runningForeground:
            return .runningForeground
        }
    }

    /// Check if app is running
    public var isRunning: Bool {
        return self == .runningForeground ||
               self == .runningBackground ||
               self == .runningBackgroundSuspended
    }

    /// Check if app is in foreground
    public var isForeground: Bool {
        return self == .runningForeground
    }

    /// Check if app is in background
    public var isBackground: Bool {
        return self == .runningBackground || self == .runningBackgroundSuspended
    }

    /// Check if app is healthy
    public var isHealthy: Bool {
        return self == .runningForeground
    }

    /// Human-readable description
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .notRunning:
            return "Not Running"
        case .runningBackgroundSuspended:
            return "Running Background (Suspended)"
        case .runningBackground:
            return "Running Background"
        case .runningForeground:
            return "Running Foreground"
        }
    }
}
