//
//  LoggingListener.swift
//  XCUITestFramework
//
//  Listener for logging test lifecycle events
//

import Foundation
import XCTest

/// Logs test lifecycle events to console
public class LoggingListener: TestLifecycleListener {

    // MARK: - Properties

    private let verbose: Bool
    private var testStartTime: Date?
    private var suiteStartTime: Date?

    // MARK: - Initialization

    public init(verbose: Bool = true) {
        self.verbose = verbose
    }

    // MARK: - TestLifecycleListener

    public func testSuiteWillStart(_ suite: XCTestSuite) {
        suiteStartTime = Date()
        print("\n" + String(repeating: "=", count: 80))
        print("🏁 Test Suite Starting: \(suite.name)")
        print("   Test Count: \(suite.testCaseCount)")
        print(String(repeating: "=", count: 80) + "\n")
    }

    public func testSuiteDidFinish(_ suite: XCTestSuite, result: TestResult) {
        let duration = suiteStartTime.map { Date().timeIntervalSince($0) } ?? 0

        print("\n" + String(repeating: "=", count: 80))
        print(resultIcon(for: result) + " Test Suite Finished: \(suite.name)")
        print("   Result: \(resultDescription(for: result))")
        print("   Duration: \(String(format: "%.2f", duration)) seconds")
        print(String(repeating: "=", count: 80) + "\n")
    }

    public func testCaseWillStart(_ testCase: XCTestCase) {
        testStartTime = Date()
        if verbose {
            print("\n" + String(repeating: "-", count: 80))
            print("▶️  Test Starting: \(testCase.name)")
            print(String(repeating: "-", count: 80))
        }
    }

    public func testCaseDidFinish(_ testCase: XCTestCase, result: TestResult) {
        let duration = testStartTime.map { Date().timeIntervalSince($0) } ?? 0

        print(resultIcon(for: result) + " Test Finished: \(testCase.name)")
        print("   Result: \(resultDescription(for: result))")
        print("   Duration: \(String(format: "%.2f", duration)) seconds")

        if verbose {
            print(String(repeating: "-", count: 80) + "\n")
        }
    }

    public func testCaseDidFail(_ testCase: XCTestCase, failure: TestFailure) {
        print("\n❌ TEST FAILURE")
        print("   Test: \(testCase.name)")
        print("   Message: \(failure.message)")
        print("   Location: \(failure.file):\(failure.line)")
        print("   Time: \(failure.timestamp)\n")
    }

    public func testCaseDidSkip(_ testCase: XCTestCase, reason: String?) {
        print("⏭️  Test Skipped: \(testCase.name)")
        if let reason = reason {
            print("   Reason: \(reason)")
        }
    }

    public func testMethodWillStart(_ testCase: XCTestCase, method: String) {
        if verbose {
            print("   🔹 Method Starting: \(method)")
        }
    }

    public func testMethodDidFinish(_ testCase: XCTestCase, method: String, result: TestResult) {
        if verbose {
            print("   \(resultIcon(for: result)) Method Finished: \(method)")
        }
    }

    // MARK: - Helper Methods

    private func resultIcon(for result: TestResult) -> String {
        switch result {
        case .passed:
            return "✅"
        case .failed:
            return "❌"
        case .skipped:
            return "⏭️"
        case .error:
            return "🔥"
        }
    }

    private func resultDescription(for result: TestResult) -> String {
        switch result {
        case .passed:
            return "PASSED"
        case .failed(let reason):
            return "FAILED - \(reason)"
        case .skipped(let reason):
            return "SKIPPED" + (reason.map { " - \($0)" } ?? "")
        case .error(let error):
            return "ERROR - \(error.localizedDescription)"
        }
    }
}
