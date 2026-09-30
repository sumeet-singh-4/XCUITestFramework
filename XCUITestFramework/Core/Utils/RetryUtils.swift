import Foundation

/// Utility class for retry operations with various strategies
public class RetryUtils {

    // MARK: - Basic Retry

    /// Retry an operation with specified attempts and delay
    /// - Parameters:
    ///   - attempts: Maximum number of attempts
    ///   - delay: Delay between attempts in seconds
    ///   - operation: The operation to retry (returns Bool for success/failure)
    /// - Returns: True if operation succeeded, false otherwise
    @discardableResult
    public static func retry(attempts: Int = 3, delay: TimeInterval = 1.0, operation: () -> Bool) -> Bool {
        var currentAttempt = 0

        while currentAttempt < attempts {
            currentAttempt += 1
            print("🔄 [Retry] Attempt \(currentAttempt)/\(attempts)")

            if operation() {
                print("✅ [Retry] Operation succeeded on attempt \(currentAttempt)")
                return true
            }

            if currentAttempt < attempts {
                print("⏳ [Retry] Waiting \(delay)s before next attempt...")
                Thread.sleep(forTimeInterval: delay)
            }
        }

        print("❌ [Retry] Operation failed after \(attempts) attempts")
        return false
    }

    // MARK: - Retry with Exponential Backoff

    /// Retry an operation with exponential backoff
    /// - Parameters:
    ///   - attempts: Maximum number of attempts
    ///   - initialDelay: Initial delay in seconds
    ///   - maxDelay: Maximum delay in seconds
    ///   - multiplier: Delay multiplier for each retry
    ///   - operation: The operation to retry
    /// - Returns: True if operation succeeded, false otherwise
    @discardableResult
    public static func retryWithExponentialBackoff(
        attempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        multiplier: Double = 2.0,
        operation: () -> Bool
    ) -> Bool {
        var currentAttempt = 0
        var currentDelay = initialDelay

        while currentAttempt < attempts {
            currentAttempt += 1
            print("🔄 [Retry] Attempt \(currentAttempt)/\(attempts)")

            if operation() {
                print("✅ [Retry] Operation succeeded on attempt \(currentAttempt)")
                return true
            }

            if currentAttempt < attempts {
                let delayToUse = min(currentDelay, maxDelay)
                print("⏳ [Retry] Waiting \(delayToUse)s before next attempt (exponential backoff)...")
                Thread.sleep(forTimeInterval: delayToUse)
                currentDelay *= multiplier
            }
        }

        print("❌ [Retry] Operation failed after \(attempts) attempts")
        return false
    }

    // MARK: - Retry Until Condition

    /// Retry until a condition is met or timeout occurs
    /// - Parameters:
    ///   - timeout: Maximum time to retry in seconds
    ///   - interval: Check interval in seconds
    ///   - condition: The condition to check
    /// - Returns: True if condition was met, false if timeout
    @discardableResult
    public static func retryUntil(
        timeout: TimeInterval,
        interval: TimeInterval = 0.5,
        condition: () -> Bool
    ) -> Bool {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                print("✅ [Retry] Condition met")
                return true
            }
            Thread.sleep(forTimeInterval: interval)
        }

        print("❌ [Retry] Condition not met within \(timeout)s timeout")
        return false
    }

    // MARK: - Retry with Exception Handling

    /// Retry an operation that can throw exceptions
    /// - Parameters:
    ///   - attempts: Maximum number of attempts
    ///   - delay: Delay between attempts in seconds
    ///   - operation: The operation to retry (can throw)
    /// - Returns: Result of the operation
    /// - Throws: The last error if all attempts fail
    public static func retryWithExceptionHandling<T>(
        attempts: Int = 3,
        delay: TimeInterval = 1.0,
        operation: () throws -> T
    ) throws -> T {
        var currentAttempt = 0
        var lastError: Error?

        while currentAttempt < attempts {
            currentAttempt += 1
            print("🔄 [Retry] Attempt \(currentAttempt)/\(attempts)")

            do {
                let result = try operation()
                print("✅ [Retry] Operation succeeded on attempt \(currentAttempt)")
                return result
            } catch {
                lastError = error
                print("⚠️ [Retry] Error on attempt \(currentAttempt): \(error.localizedDescription)")

                if currentAttempt < attempts {
                    print("⏳ [Retry] Waiting \(delay)s before next attempt...")
                    Thread.sleep(forTimeInterval: delay)
                }
            }
        }

        print("❌ [Retry] Operation failed after \(attempts) attempts")
        throw lastError ?? NSError(domain: "RetryUtils", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
    }

    // MARK: - Retry with Custom Success Criteria

    /// Retry an operation with custom success criteria
    /// - Parameters:
    ///   - attempts: Maximum number of attempts
    ///   - delay: Delay between attempts in seconds
    ///   - successCriteria: Function to determine if result is successful
    ///   - operation: The operation to retry
    /// - Returns: The successful result, or nil if all attempts fail
    public static func retryWithCriteria<T>(
        attempts: Int = 3,
        delay: TimeInterval = 1.0,
        successCriteria: (T) -> Bool,
        operation: () -> T?
    ) -> T? {
        var currentAttempt = 0

        while currentAttempt < attempts {
            currentAttempt += 1
            print("🔄 [Retry] Attempt \(currentAttempt)/\(attempts)")

            if let result = operation() {
                if successCriteria(result) {
                    print("✅ [Retry] Operation succeeded with valid result on attempt \(currentAttempt)")
                    return result
                } else {
                    print("⚠️ [Retry] Result did not meet success criteria on attempt \(currentAttempt)")
                }
            } else {
                print("⚠️ [Retry] Operation returned nil on attempt \(currentAttempt)")
            }

            if currentAttempt < attempts {
                print("⏳ [Retry] Waiting \(delay)s before next attempt...")
                Thread.sleep(forTimeInterval: delay)
            }
        }

        print("❌ [Retry] Operation failed to meet criteria after \(attempts) attempts")
        return nil
    }

    // MARK: - Retry for Void Operations

    /// Retry a void operation (operation with no return value)
    /// - Parameters:
    ///   - attempts: Maximum number of attempts
    ///   - delay: Delay between attempts in seconds
    ///   - shouldRetry: Function to determine if retry should continue after each attempt
    ///   - operation: The void operation to retry
    /// - Returns: True if operation completed without requesting retry, false otherwise
    @discardableResult
    public static func retryVoidOperation(
        attempts: Int = 3,
        delay: TimeInterval = 1.0,
        shouldRetry: () -> Bool,
        operation: () -> Void
    ) -> Bool {
        var currentAttempt = 0

        while currentAttempt < attempts {
            currentAttempt += 1
            print("🔄 [Retry] Attempt \(currentAttempt)/\(attempts)")

            operation()

            if !shouldRetry() {
                print("✅ [Retry] Operation completed successfully on attempt \(currentAttempt)")
                return true
            }

            if currentAttempt < attempts {
                print("⏳ [Retry] Waiting \(delay)s before next attempt...")
                Thread.sleep(forTimeInterval: delay)
            }
        }

        print("❌ [Retry] Operation still requires retry after \(attempts) attempts")
        return false
    }
}
