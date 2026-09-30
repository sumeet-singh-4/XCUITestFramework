//
//  DeviceOrientation.swift
//  XCUITestFramework
//
//  Enumeration for device orientations
//

import Foundation
import XCTest

/// Represents device orientation states
public enum DeviceOrientation: String, CaseIterable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case faceUp
    case faceDown
    case unknown

    /// Convert to UIDeviceOrientation
    public var uiDeviceOrientation: UIDeviceOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .faceUp: return .faceUp
        case .faceDown: return .faceDown
        case .unknown: return .unknown
        }
    }

    /// Check if orientation is landscape
    public var isLandscape: Bool {
        return self == .landscapeLeft || self == .landscapeRight
    }

    /// Check if orientation is portrait
    public var isPortrait: Bool {
        return self == .portrait || self == .portraitUpsideDown
    }

    /// Check if orientation is flat
    public var isFlat: Bool {
        return self == .faceUp || self == .faceDown
    }

    /// Human-readable description
    public var description: String {
        switch self {
        case .portraitUpsideDown:
            return "Portrait Upside Down"
        case .landscapeLeft:
            return "Landscape Left"
        case .landscapeRight:
            return "Landscape Right"
        case .faceUp:
            return "Face Up"
        case .faceDown:
            return "Face Down"
        default:
            return rawValue.capitalized
        }
    }
}
