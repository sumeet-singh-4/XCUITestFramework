//
//  BiometricUtils.swift
//  XCUITestFramework
//
//  Utility class for testing biometric authentication (Face ID, Touch ID)
//

import Foundation
import XCTest

/// Utility for biometric authentication testing
public class BiometricUtils {

    // MARK: - Biometric Types

    public enum BiometricType {
        case faceID
        case touchID
    }

    public enum BiometricResult {
        case success
        case failure
        case cancel
    }

    // MARK: - Properties

    private static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    // MARK: - Biometric Simulation

    /// Simulate successful biometric authentication
    /// - Parameter type: Type of biometric (Face ID or Touch ID)
    public static func simulateSuccessfulAuth(type: BiometricType = .faceID) {
        print("✅ [Biometric] Simulating successful \(type == .faceID ? "Face ID" : "Touch ID") authentication")

        // Wait for biometric prompt
        let prompt = springboard.otherElements["Face ID"].firstMatch
        if prompt.waitForExistence(timeout: 5) {
            // In simulator, biometric can be triggered via Xcode or command line
            // This is a placeholder for the UI interaction
            print("ℹ️ [Biometric] Biometric prompt detected")
        }

        // Note: Actual biometric simulation requires:
        // - Simulator: Hardware > Face ID/Touch ID > Enrolled + Matching Face/Finger
        // - Device: Physical biometric interaction
    }

    /// Simulate failed biometric authentication
    /// - Parameter type: Type of biometric (Face ID or Touch ID)
    public static func simulateFailedAuth(type: BiometricType = .faceID) {
        print("❌ [Biometric] Simulating failed \(type == .faceID ? "Face ID" : "Touch ID") authentication")

        // Note: Requires simulator configuration:
        // Hardware > Face ID/Touch ID > Non-matching Face/Finger
        let prompt = springboard.otherElements["Face ID"].firstMatch
        if prompt.waitForExistence(timeout: 5) {
            print("ℹ️ [Biometric] Biometric prompt detected for failure simulation")
        }
    }

    /// Enroll biometric (simulator only)
    /// - Parameter type: Type of biometric to enroll
    public static func enrollBiometric(type: BiometricType = .faceID) {
        print("📱 [Biometric] Enrolling \(type == .faceID ? "Face ID" : "Touch ID")")
        print("ℹ️ [Biometric] This should be done via Simulator menu: Hardware > Face ID/Touch ID > Enrolled")

        // In automated tests, this is typically configured before test execution
        // via simulator settings or test setup
    }

    /// Unenroll biometric (simulator only)
    /// - Parameter type: Type of biometric to unenroll
    public static func unenrollBiometric(type: BiometricType = .faceID) {
        print("📱 [Biometric] Unenrolling \(type == .faceID ? "Face ID" : "Touch ID")")
        print("ℹ️ [Biometric] This should be done via Simulator menu: Hardware > Face ID/Touch ID > Not Enrolled")
    }

    // MARK: - Prompt Handling

    /// Wait for biometric prompt to appear
    /// - Parameters:
    ///   - timeout: Timeout to wait for prompt
    /// - Returns: True if prompt appeared
    @discardableResult
    public static func waitForBiometricPrompt(timeout: TimeInterval = 5) -> Bool {
        // Check for system biometric prompt
        let faceIDPrompt = springboard.otherElements["Face ID"]
        let touchIDPrompt = springboard.otherElements["Touch ID"]

        let exists = faceIDPrompt.waitForExistence(timeout: timeout) ||
                     touchIDPrompt.waitForExistence(timeout: timeout)

        if exists {
            print("✅ [Biometric] Biometric prompt appeared")
        } else {
            print("❌ [Biometric] Biometric prompt did not appear within \(timeout) seconds")
        }

        return exists
    }

    /// Cancel biometric authentication
    public static func cancelBiometricAuth() {
        print("🚫 [Biometric] Canceling biometric authentication")

        if springboard.buttons["Cancel"].exists {
            springboard.buttons["Cancel"].tap()
        } else if springboard.buttons["Enter Password"].exists {
            springboard.buttons["Enter Password"].tap()
        }
    }

    /// Use password fallback
    /// - Parameter password: Password to enter
    public static func usePasswordFallback(password: String) {
        print("🔑 [Biometric] Using password fallback")

        if springboard.buttons["Enter Password"].waitForExistence(timeout: 2) {
            springboard.buttons["Enter Password"].tap()

            // Wait for password field
            if let passwordField = springboard.secureTextFields.firstMatch as? XCUIElement,
               passwordField.waitForExistence(timeout: 2) {
                passwordField.tap()
                passwordField.typeText(password)
            }
        }
    }

    // MARK: - Verification

    /// Verify biometric prompt is displayed
    /// - Parameter timeout: Timeout for verification
    @discardableResult
    public static func verifyBiometricPromptDisplayed(timeout: TimeInterval = 5) -> Bool {
        let result = waitForBiometricPrompt(timeout: timeout)
        XCTAssertTrue(result, "Biometric prompt should be displayed")
        return result
    }

    /// Verify biometric authentication succeeded
    /// - Parameters:
    ///   - expectedElement: Element that should appear after success
    ///   - timeout: Timeout for verification
    @discardableResult
    public static func verifyAuthSuccess(expectedElement: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let exists = expectedElement.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Expected element should appear after successful authentication")

        if exists {
            print("✅ [Biometric] Authentication successful")
        } else {
            print("❌ [Biometric] Authentication did not succeed")
        }

        return exists
    }

    /// Verify biometric authentication failed
    /// - Parameters:
    ///   - errorMessage: Expected error message element
    ///   - timeout: Timeout for verification
    @discardableResult
    public static func verifyAuthFailed(errorMessage: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let exists = errorMessage.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Error message should appear after failed authentication")

        if exists {
            print("✅ [Biometric] Authentication failed as expected")
        } else {
            print("❌ [Biometric] Expected authentication failure not detected")
        }

        return exists
    }

    // MARK: - Helper Methods

    /// Check if biometric is available on device/simulator
    /// - Returns: True if biometric is available
    public static func isBiometricAvailable() -> Bool {
        // This is a simplified check
        // In real implementation, you might check LAContext.canEvaluatePolicy
        print("ℹ️ [Biometric] Checking biometric availability")
        return true // Placeholder
    }

    /// Get biometric type available on device
    /// - Returns: BiometricType or nil if not available
    public static func getBiometricType() -> BiometricType? {
        // This would typically check LAContext.biometryType
        // For simulator testing, we default to Face ID
        return .faceID
    }
}
