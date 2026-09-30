//
//  DeepLinkUtils.swift
//  XCUITestFramework
//
//  Utility class for testing deep links and universal links
//

import Foundation
import XCTest

/// Utility for deep link testing
public class DeepLinkUtils {

    // MARK: - Properties

    private let app: XCUIApplication

    // MARK: - Initialization

    public init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Deep Link Opening

    /// Open a deep link URL
    /// - Parameters:
    ///   - urlString: The deep link URL to open
    ///   - waitForLaunch: Whether to wait for app to launch
    ///   - timeout: Timeout for app launch
    /// - Returns: True if successful
    @discardableResult
    public func openDeepLink(_ urlString: String, waitForLaunch: Bool = true, timeout: TimeInterval = 10) -> Bool {
        guard let url = URL(string: urlString) else {
            print("❌ [DeepLink] Invalid URL: \(urlString)")
            return false
        }

        print("🔗 [DeepLink] Opening: \(urlString)")

        // Use Safari or springboard to open the URL
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        // Type URL in address bar
        if safari.textFields["Address"].exists {
            safari.textFields["Address"].tap()
            safari.textFields["Address"].typeText(urlString + "\n")
        } else if safari.textFields["URL"].exists {
            safari.textFields["URL"].tap()
            safari.textFields["URL"].typeText(urlString + "\n")
        }

        // Wait for "Open" button if it appears
        if safari.buttons["Open"].waitForExistence(timeout: 3) {
            safari.buttons["Open"].tap()
        }

        if waitForLaunch {
            return app.wait(for: .runningForeground, timeout: timeout)
        }

        return true
    }

    /// Open deep link with parameters
    /// - Parameters:
    ///   - baseURL: Base URL scheme (e.g., "myapp://")
    ///   - path: Path component
    ///   - parameters: Query parameters
    /// - Returns: True if successful
    @discardableResult
    public func openDeepLink(baseURL: String, path: String = "", parameters: [String: String] = [:]) -> Bool {
        var urlString = baseURL
        if !path.isEmpty {
            urlString += path
        }

        if !parameters.isEmpty {
            let queryString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }

        return openDeepLink(urlString)
    }

    /// Open universal link
    /// - Parameters:
    ///   - urlString: Universal link URL
    ///   - waitForLaunch: Whether to wait for app to launch
    /// - Returns: True if successful
    @discardableResult
    public func openUniversalLink(_ urlString: String, waitForLaunch: Bool = true) -> Bool {
        print("🌐 [UniversalLink] Opening: \(urlString)")
        return openDeepLink(urlString, waitForLaunch: waitForLaunch)
    }

    // MARK: - Parameter Extraction

    /// Extract query parameters from URL
    /// - Parameter urlString: URL string
    /// - Returns: Dictionary of parameters
    public static func extractParameters(from urlString: String) -> [String: String] {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }

    /// Extract path from URL
    /// - Parameter urlString: URL string
    /// - Returns: Path component
    public static func extractPath(from urlString: String) -> String {
        guard let url = URL(string: urlString) else {
            return ""
        }
        return url.path
    }

    // MARK: - Verification

    /// Verify app opened with deep link
    /// - Parameters:
    ///   - expectedScreen: Expected screen identifier
    ///   - timeout: Timeout for verification
    /// - Returns: True if on expected screen
    @discardableResult
    public func verifyDeepLinkOpened(expectedScreen: String, timeout: TimeInterval = 10) -> Bool {
        let element = app.otherElements[expectedScreen]
        let exists = element.waitForExistence(timeout: timeout)

        if exists {
            print("✅ [DeepLink] Successfully opened to screen: \(expectedScreen)")
        } else {
            print("❌ [DeepLink] Failed to open to expected screen: \(expectedScreen)")
        }

        return exists
    }
}
