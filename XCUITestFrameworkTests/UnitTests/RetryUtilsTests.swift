//
//  RetryUtilsTests.swift
//  XCUITestFrameworkTests
//
//  Unit tests for RetryUtils
//

import XCTest
@testable import XCUITestFramework

class RetryUtilsTests: XCTestCase {

    // MARK: - Test Properties

    var callCount: Int = 0
    var shouldSucceed: Bool = false

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        callCount = 0
        shouldSucceed = false
    }

    // MARK: - Basic Retry Tests

    func testRetrySucceedsOnFirstAttempt() {
        shouldSucceed = true

        let result = RetryUtils.retry(maxAttempts: 3) {
            self.callCount += 1
            return self.shouldSucceed
        }

        XCTAssertTrue(result, "Should succeed on first attempt")
        XCTAssertEqual(callCount, 1, "Should only call once")
    }

    func testRetrySucceedsOnSecondAttempt() {
        let result = RetryUtils.retry(maxAttempts: 3) {
            self.callCount += 1
            if self.callCount >= 2 {
                self.shouldSucceed = true
            }
            return self.shouldSucceed
        }

        XCTAssertTrue(result, "Should succeed on second attempt")
        XCTAssertEqual(callCount, 2, "Should call twice")
    }

    func testRetryFailsAfterMaxAttempts() {
        shouldSucceed = false

        let result = RetryUtils.retry(maxAttempts: 3) {
            self.callCount += 1
            return self.shouldSucceed
        }

        XCTAssertFalse(result, "Should fail after max attempts")
        XCTAssertEqual(callCount, 3, "Should call three times")
    }

    // MARK: - Retry with Delay Tests

    func testRetryWithDelay() {
        let startTime = Date()

        let result = RetryUtils.retry(maxAttempts: 2, delay: 0.1) {
            self.callCount += 1
            return false
        }

        let duration = Date().timeIntervalSince(startTime)

        XCTAssertFalse(result)
        XCTAssertEqual(callCount, 2)
        XCTAssertGreaterThan(duration, 0.1, "Should wait between attempts")
    }

    // MARK: - Exponential Backoff Tests

    func testExponentialBackoff() {
        let startTime = Date()

        let result = RetryUtils.retryWithExponentialBackoff(
            maxAttempts: 3,
            initialDelay: 0.1,
            maxDelay: 1.0
        ) {
            self.callCount += 1
            return false
        }

        let duration = Date().timeIntervalSince(startTime)

        XCTAssertFalse(result)
        XCTAssertEqual(callCount, 3)
        // Initial: 0.1, Second: 0.2, Third: 0.4 = ~0.7 total
        XCTAssertGreaterThan(duration, 0.3, "Should have increasing delays")
    }

    // MARK: - Retry Until Tests

    func testRetryUntilTimeout() {
        let result = RetryUtils.retryUntil(timeout: 0.5, interval: 0.1) {
            self.callCount += 1
            return self.callCount >= 10 // Never reaches 10 in 0.5s
        }

        XCTAssertFalse(result, "Should timeout")
        XCTAssertGreaterThan(callCount, 3, "Should make multiple attempts")
    }

    func testRetryUntilSuccess() {
        let result = RetryUtils.retryUntil(timeout: 1.0, interval: 0.1) {
            self.callCount += 1
            return self.callCount >= 3
        }

        XCTAssertTrue(result, "Should succeed before timeout")
        XCTAssertEqual(callCount, 3)
    }

    // MARK: - Conditional Retry Tests

    func testConditionalRetry() {
        var errorCount = 0

        let result = RetryUtils.retryConditional(
            maxAttempts: 5,
            shouldRetry: { error in
                errorCount += 1
                return errorCount < 3 // Only retry first 2 failures
            }
        ) {
            self.callCount += 1
            if self.callCount < 3 {
                throw NSError(domain: "test", code: 1)
            }
            return true
        }

        XCTAssertTrue(result)
        XCTAssertEqual(callCount, 3)
    }

    // MARK: - Performance Tests

    func testRetryPerformance() {
        measure {
            _ = RetryUtils.retry(maxAttempts: 100) {
                return false
            }
        }
    }

    // MARK: - Edge Cases

    func testRetryWithZeroAttempts() {
        let result = RetryUtils.retry(maxAttempts: 0) {
            self.callCount += 1
            return true
        }

        XCTAssertFalse(result, "Should not execute with 0 attempts")
        XCTAssertEqual(callCount, 0)
    }

    func testRetryWithNegativeAttempts() {
        let result = RetryUtils.retry(maxAttempts: -1) {
            self.callCount += 1
            return true
        }

        XCTAssertFalse(result, "Should not execute with negative attempts")
        XCTAssertEqual(callCount, 0)
    }

    func testRetryWithNegativeDelay() {
        let result = RetryUtils.retry(maxAttempts: 2, delay: -0.1) {
            self.callCount += 1
            return false
        }

        XCTAssertFalse(result)
        XCTAssertEqual(callCount, 2, "Should still execute but without delay")
    }
}
