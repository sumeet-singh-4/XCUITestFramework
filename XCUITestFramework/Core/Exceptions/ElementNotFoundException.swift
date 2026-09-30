//
//  ElementNotFoundException.swift
//  XCUITestFramework
//
//  Exception for element not found errors
//

import Foundation
import XCTest

/// Exception thrown when UI element cannot be found or located
public class ElementNotFoundException: FrameworkException {

    // MARK: - Properties

    public let elementIdentifier: String
    public let elementType: String
    public let timeout: TimeInterval

    // MARK: - Initialization

    public init(
        _ elementIdentifier: String,
        type: String = "Unknown",
        timeout: TimeInterval = 0,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.elementIdentifier = elementIdentifier
        self.elementType = type
        self.timeout = timeout

        var message = "Element '\(elementIdentifier)' of type '\(type)' not found"
        if timeout > 0 {
            message += " within \(timeout) seconds"
        }

        super.init(message, file: file, function: function, line: line)
    }

    // MARK: - Factory Methods

    /// Element not found after waiting
    public static func notFoundAfterWait(
        _ elementIdentifier: String,
        type: String = "Unknown",
        timeout: TimeInterval
    ) -> ElementNotFoundException {
        return ElementNotFoundException(elementIdentifier, type: type, timeout: timeout)
    }

    /// Element not found immediately
    public static func notFound(_ elementIdentifier: String, type: String = "Unknown") -> ElementNotFoundException {
        return ElementNotFoundException(elementIdentifier, type: type)
    }

    /// Element found but not hittable
    public static func notHittable(_ elementIdentifier: String, timeout: TimeInterval) -> ElementNotFoundException {
        let exception = ElementNotFoundException(elementIdentifier, timeout: timeout)
        return ElementNotFoundException(
            "Element '\(elementIdentifier)' exists but is not hittable (may be obscured or disabled) after \(timeout) seconds"
        )
    }

    /// Multiple elements found when expecting one
    public static func multipleElementsFound(_ elementIdentifier: String, count: Int) -> ElementNotFoundException {
        return ElementNotFoundException(
            "Expected 1 element with identifier '\(elementIdentifier)' but found \(count)"
        )
    }
}
