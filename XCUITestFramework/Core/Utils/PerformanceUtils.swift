//
//  PerformanceUtils.swift
//  XCUITestFramework
//
//  Utility for performance testing and baseline management
//

import Foundation
import XCTest

/// Performance testing utility with baseline management
public class PerformanceUtils {

    // MARK: - Baseline Storage

    private static var baselines: [String: TimeInterval] = [:]
    private static let baselinesFileName = "performance_baselines.json"

    // MARK: - Performance Measurement

    /// Measure execution time of a block
    /// - Parameters:
    ///   - name: Name of the measurement
    ///   - block: Block to measure
    /// - Returns: Execution time in seconds
    @discardableResult
    public static func measure(name: String, block: () throws -> Void) rethrows -> TimeInterval {
        let startTime = Date()
        try block()
        let duration = Date().timeIntervalSince(startTime)

        print("⏱️ [Performance] \(name): \(String(format: "%.3f", duration))s")

        return duration
    }

    /// Measure execution time and compare with baseline
    /// - Parameters:
    ///   - name: Name of the measurement
    ///   - baseline: Expected baseline time
    ///   - tolerance: Acceptable tolerance (0.1 = 10%)
    ///   - block: Block to measure
    /// - Returns: Execution time in seconds
    @discardableResult
    public static func measureWithBaseline(
        name: String,
        baseline: TimeInterval,
        tolerance: Double = 0.1,
        block: () throws -> Void
    ) rethrows -> TimeInterval {
        let duration = try measure(name: name, block: block)

        let difference = abs(duration - baseline)
        let percentDiff = difference / baseline

        if percentDiff > tolerance {
            print("⚠️ [Performance] '\(name)' exceeded baseline by \(String(format: "%.1f", percentDiff * 100))%")
            print("   Expected: \(String(format: "%.3f", baseline))s")
            print("   Actual: \(String(format: "%.3f", duration))s")
        } else {
            print("✅ [Performance] '\(name)' within acceptable range")
        }

        XCTAssertLessThanOrEqual(
            percentDiff,
            tolerance,
            "Performance regression: '\(name)' took \(String(format: "%.3f", duration))s, expected ~\(String(format: "%.3f", baseline))s"
        )

        return duration
    }

    /// Measure and save as baseline
    /// - Parameters:
    ///   - name: Name of the measurement
    ///   - block: Block to measure
    /// - Returns: Execution time in seconds
    @discardableResult
    public static func measureAndSaveBaseline(name: String, block: () throws -> Void) rethrows -> TimeInterval {
        let duration = try measure(name: name, block: block)
        saveBaseline(name: name, time: duration)
        return duration
    }

    /// Measure against stored baseline
    /// - Parameters:
    ///   - name: Name of the measurement
    ///   - tolerance: Acceptable tolerance (0.1 = 10%)
    ///   - block: Block to measure
    /// - Returns: Execution time in seconds
    @discardableResult
    public static func measureAgainstStoredBaseline(
        name: String,
        tolerance: Double = 0.1,
        block: () throws -> Void
    ) rethrows -> TimeInterval {
        loadBaselines()

        guard let baseline = baselines[name] else {
            print("⚠️ [Performance] No baseline found for '\(name)', creating new baseline")
            return try measureAndSaveBaseline(name: name, block: block)
        }

        return try measureWithBaseline(name: name, baseline: baseline, tolerance: tolerance, block: block)
    }

    // MARK: - App Launch Performance

    /// Measure app launch time
    /// - Parameters:
    ///   - app: Application to measure
    ///   - name: Name of the measurement
    /// - Returns: Launch time in seconds
    @discardableResult
    public static func measureAppLaunch(app: XCUIApplication, name: String = "App Launch") -> TimeInterval {
        return measure(name: name) {
            app.launch()
        }
    }

    /// Measure screen load time
    /// - Parameters:
    ///   - screenElement: Element that indicates screen is loaded
    ///   - name: Name of the measurement
    ///   - action: Action that triggers screen load
    /// - Returns: Load time in seconds
    @discardableResult
    public static func measureScreenLoad(
        screenElement: XCUIElement,
        name: String = "Screen Load",
        action: () -> Void
    ) -> TimeInterval {
        return measure(name: name) {
            action()
            _ = screenElement.waitForExistence(timeout: 30)
        }
    }

    // MARK: - Baseline Management

    /// Save performance baseline
    /// - Parameters:
    ///   - name: Name of the baseline
    ///   - time: Execution time
    public static func saveBaseline(name: String, time: TimeInterval) {
        baselines[name] = time
        saveBaselines()
        print("💾 [Performance] Saved baseline '\(name)': \(String(format: "%.3f", time))s")
    }

    /// Get baseline for measurement
    /// - Parameter name: Name of the baseline
    /// - Returns: Baseline time or nil if not found
    public static func getBaseline(name: String) -> TimeInterval? {
        loadBaselines()
        return baselines[name]
    }

    /// Clear all baselines
    public static func clearBaselines() {
        baselines.removeAll()
        saveBaselines()
        print("🗑️ [Performance] Cleared all baselines")
    }

    /// List all baselines
    public static func listBaselines() {
        loadBaselines()
        print("📋 [Performance] Stored baselines:")
        for (name, time) in baselines.sorted(by: { $0.key < $1.key }) {
            print("   - \(name): \(String(format: "%.3f", time))s")
        }
    }

    // MARK: - Persistence

    private static func saveBaselines() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.currentDirectoryPath
        let filePath = "\(documentsPath)/\(baselinesFileName)"

        do {
            let data = try JSONSerialization.data(withJSONObject: baselines, options: [.prettyPrinted])
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch {
            print("❌ [Performance] Failed to save baselines: \(error.localizedDescription)")
        }
    }

    private static func loadBaselines() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.currentDirectoryPath
        let filePath = "\(documentsPath)/\(baselinesFileName)"

        guard fileManager.fileExists(atPath: filePath) else { return }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if let loaded = try JSONSerialization.jsonObject(with: data) as? [String: TimeInterval] {
                baselines = loaded
            }
        } catch {
            print("❌ [Performance] Failed to load baselines: \(error.localizedDescription)")
        }
    }

    // MARK: - XCTest Integration

    /// Wrapper for XCTest's measure block with custom metrics
    /// - Parameters:
    ///   - name: Name of the measurement
    ///   - metrics: XCTest metrics to measure
    ///   - block: Block to measure
    public static func measureWithMetrics(
        name: String,
        metrics: [XCTMetric] = [XCTClockMetric()],
        block: () throws -> Void
    ) rethrows {
        let options = XCTMeasureOptions()
        options.iterationCount = 5

        XCTContext.runActivity(named: name) { _ in
            measure(metrics: metrics, options: options) {
                try? block()
            }
        }
    }
}
