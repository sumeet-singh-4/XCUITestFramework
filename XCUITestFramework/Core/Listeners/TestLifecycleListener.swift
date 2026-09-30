//
//  TestLifecycleListener.swift
//  XCUITestFramework
//
//  Protocol for test lifecycle event listeners
//

import Foundation
import XCTest

/// Protocol for listening to test lifecycle events
public protocol TestLifecycleListener: AnyObject {

    /// Called before a test suite begins
    func testSuiteWillStart(_ suite: XCTestSuite)

    /// Called after a test suite completes
    func testSuiteDidFinish(_ suite: XCTestSuite, result: TestResult)

    /// Called before a test case begins
    func testCaseWillStart(_ testCase: XCTestCase)

    /// Called after a test case completes
    func testCaseDidFinish(_ testCase: XCTestCase, result: TestResult)

    /// Called when a test case fails
    func testCaseDidFail(_ testCase: XCTestCase, failure: TestFailure)

    /// Called when a test case is skipped
    func testCaseDidSkip(_ testCase: XCTestCase, reason: String?)

    /// Called before each test method
    func testMethodWillStart(_ testCase: XCTestCase, method: String)

    /// Called after each test method
    func testMethodDidFinish(_ testCase: XCTestCase, method: String, result: TestResult)
}

// MARK: - Default Implementation (Optional Methods)

public extension TestLifecycleListener {

    func testSuiteWillStart(_ suite: XCTestSuite) {}

    func testSuiteDidFinish(_ suite: XCTestSuite, result: TestResult) {}

    func testCaseWillStart(_ testCase: XCTestCase) {}

    func testCaseDidFinish(_ testCase: XCTestCase, result: TestResult) {}

    func testCaseDidFail(_ testCase: XCTestCase, failure: TestFailure) {}

    func testCaseDidSkip(_ testCase: XCTestCase, reason: String?) {}

    func testMethodWillStart(_ testCase: XCTestCase, method: String) {}

    func testMethodDidFinish(_ testCase: XCTestCase, method: String, result: TestResult) {}
}

// MARK: - Supporting Types

/// Test execution result
public enum TestResult {
    case passed
    case failed(reason: String)
    case skipped(reason: String?)
    case error(error: Error)

    public var isPassed: Bool {
        if case .passed = self { return true }
        return false
    }

    public var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    public var isSkipped: Bool {
        if case .skipped = self { return true }
        return false
    }

    public var isError: Bool {
        if case .error = self { return true }
        return false
    }
}

/// Test failure information
public struct TestFailure {
    public let message: String
    public let file: String
    public let line: Int
    public let timestamp: Date

    public init(message: String, file: String, line: Int, timestamp: Date = Date()) {
        self.message = message
        self.file = file
        self.line = line
        self.timestamp = timestamp
    }
}

/// Test lifecycle listener manager
public class TestLifecycleListenerManager {

    // MARK: - Singleton

    public static let shared = TestLifecycleListenerManager()

    // MARK: - Properties

    private var listeners: [TestLifecycleListener] = []
    private let queue = DispatchQueue(label: "com.xcuitestframework.listeners", attributes: .concurrent)

    private init() {}

    // MARK: - Registration

    public func register(_ listener: TestLifecycleListener) {
        queue.async(flags: .barrier) {
            self.listeners.append(listener)
            print("✅ Registered test lifecycle listener: \(type(of: listener))")
        }
    }

    public func unregister(_ listener: TestLifecycleListener) {
        queue.async(flags: .barrier) {
            self.listeners.removeAll { $0 === listener }
            print("✅ Unregistered test lifecycle listener: \(type(of: listener))")
        }
    }

    public func unregisterAll() {
        queue.async(flags: .barrier) {
            self.listeners.removeAll()
            print("✅ Unregistered all test lifecycle listeners")
        }
    }

    // MARK: - Notification Methods

    public func notifyTestSuiteWillStart(_ suite: XCTestSuite) {
        queue.async {
            self.listeners.forEach { $0.testSuiteWillStart(suite) }
        }
    }

    public func notifyTestSuiteDidFinish(_ suite: XCTestSuite, result: TestResult) {
        queue.async {
            self.listeners.forEach { $0.testSuiteDidFinish(suite, result: result) }
        }
    }

    public func notifyTestCaseWillStart(_ testCase: XCTestCase) {
        queue.async {
            self.listeners.forEach { $0.testCaseWillStart(testCase) }
        }
    }

    public func notifyTestCaseDidFinish(_ testCase: XCTestCase, result: TestResult) {
        queue.async {
            self.listeners.forEach { $0.testCaseDidFinish(testCase, result: result) }
        }
    }

    public func notifyTestCaseDidFail(_ testCase: XCTestCase, failure: TestFailure) {
        queue.async {
            self.listeners.forEach { $0.testCaseDidFail(testCase, failure: failure) }
        }
    }

    public func notifyTestCaseDidSkip(_ testCase: XCTestCase, reason: String?) {
        queue.async {
            self.listeners.forEach { $0.testCaseDidSkip(testCase, reason: reason) }
        }
    }

    public func notifyTestMethodWillStart(_ testCase: XCTestCase, method: String) {
        queue.async {
            self.listeners.forEach { $0.testMethodWillStart(testCase, method: method) }
        }
    }

    public func notifyTestMethodDidFinish(_ testCase: XCTestCase, method: String, result: TestResult) {
        queue.async {
            self.listeners.forEach { $0.testMethodDidFinish(testCase, method: method, result: result) }
        }
    }
}
