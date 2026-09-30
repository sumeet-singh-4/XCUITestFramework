//
//  AlertAction.swift
//  XCUITestFramework
//
//  Enumeration for alert actions
//

import Foundation

/// Represents common alert button actions
public enum AlertAction: String, CaseIterable {
    case allow = "Allow"
    case allowOnce = "Allow Once"
    case allowWhileUsing = "Allow While Using App"
    case allowAlways = "Always Allow"
    case dontAllow = "Don't Allow"
    case deny = "Deny"
    case ok = "OK"
    case cancel = "Cancel"
    case yes = "Yes"
    case no = "No"
    case delete = "Delete"
    case dismiss = "Dismiss"
    case close = "Close"
    case continue_ = "Continue"
    case notNow = "Not Now"

    /// Alert button title text
    public var buttonTitle: String {
        return rawValue
    }

    /// Check if action is positive/affirmative
    public var isPositive: Bool {
        switch self {
        case .allow, .allowOnce, .allowWhileUsing, .allowAlways, .ok, .yes, .continue_:
            return true
        default:
            return false
        }
    }

    /// Check if action is negative/dismissive
    public var isNegative: Bool {
        return !isPositive
    }

    /// Check if action is permission-related
    public var isPermission: Bool {
        switch self {
        case .allow, .allowOnce, .allowWhileUsing, .allowAlways, .dontAllow, .deny:
            return true
        default:
            return false
        }
    }
}
