//
//  SwipeDirection.swift
//  XCUITestFramework
//
//  Enumeration for swipe directions
//

import Foundation

/// Represents the direction of a swipe gesture
public enum SwipeDirection: String, CaseIterable {
    case up
    case down
    case left
    case right

    /// Opposite direction
    public var opposite: SwipeDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    /// Human-readable description
    public var description: String {
        return rawValue.capitalized
    }
}
