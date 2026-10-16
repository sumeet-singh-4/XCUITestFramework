//
//  ScreenshotListener.swift
//  XCUITestFramework
//
//  Listener for automatic screenshot capture on test events
//

import Foundation
import XCTest

/// Automatically captures screenshots on test failures and other events
public class ScreenshotListener: TestLifecycleListener {

    // MARK: - Configuration

    public enum CaptureMode {
        case onFailure
        case onFinish
        case always
        case never
    }

    // MARK: - Properties

    private let captureMode: CaptureMode
    private let app: XCUIApplication?

    // MARK: - Initialization

    public init(captureMode: CaptureMode = .onFailure, app: XCUIApplication? = nil) {
        self.captureMode = captureMode
        self.app = app
    }

    // MARK: - TestLifecycleListener

    public func testCaseWillStart(_ testCase: XCTestCase) {
        if captureMode == .always {
            captureScreenshot(name: "\(testCase.name)_start")
        }
    }

    public func testCaseDidFinish(_ testCase: XCTestCase, result: TestResult) {
        if captureMode == .onFinish || captureMode == .always {
            captureScreenshot(name: "\(testCase.name)_finish")
        }
    }

    public func testCaseDidFail(_ testCase: XCTestCase, failure: TestFailure) {
        if captureMode == .onFailure || captureMode == .always {
            captureScreenshot(name: "\(testCase.name)_failure")
        }
    }

    // MARK: - Screenshot Capture

    private func captureScreenshot(name: String) {
        guard captureMode != .never else { return }

        let screenshot: XCUIScreenshot

        if let app = app {
            screenshot = app.screenshot()
        } else {
            screenshot = XCUIScreen.main.screenshot()
        }

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways

        XCTContext.runActivity(named: "Screenshot: \(name)") { activity in
            activity.add(attachment)
        }

        print("📸 Screenshot captured: \(name)")
    }
}
