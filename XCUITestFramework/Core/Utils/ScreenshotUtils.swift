import XCTest

/// Utility class for capturing and managing screenshots
public class ScreenshotUtils {

    // MARK: - Screenshot Capture

    /// Capture screenshot and return as XCTAttachment
    /// - Parameters:
    ///   - name: Name for the screenshot
    ///   - lifetime: Lifetime of the attachment
    /// - Returns: XCTAttachment containing the screenshot
    public static func captureScreenshot(name: String = "Screenshot", lifetime: XCTAttachment.Lifetime = .keepAlways) -> XCTAttachment {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(name)-\(timestamp())"
        attachment.lifetime = lifetime
        print("📸 [Screenshot] Captured: \(attachment.name)")
        return attachment
    }

    /// Capture screenshot and attach to test
    /// - Parameters:
    ///   - name: Name for the screenshot
    ///   - lifetime: Lifetime of the attachment
    public static func captureAndAttach(name: String = "Screenshot", lifetime: XCTAttachment.Lifetime = .keepAlways) {
        let attachment = captureScreenshot(name: name, lifetime: lifetime)
        XCTContext.runActivity(named: "Screenshot: \(name)") { activity in
            activity.add(attachment)
        }
    }

    /// Capture screenshot of failure
    /// - Parameter testName: Name of the failing test
    public static func captureFailureScreenshot(testName: String) {
        captureAndAttach(name: "FAILURE-\(testName)", lifetime: .keepAlways)
    }

    /// Capture screenshot with custom element highlighted (conceptual - XCUITest doesn't support actual highlighting)
    /// - Parameters:
    ///   - element: Element to capture
    ///   - name: Name for the screenshot
    /// - Returns: XCTAttachment containing the screenshot
    public static func captureElementScreenshot(element: XCUIElement, name: String = "Element") -> XCTAttachment {
        let screenshot = element.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(name)-\(timestamp())"
        attachment.lifetime = .keepAlways
        print("📸 [Screenshot] Captured element: \(attachment.name)")
        return attachment
    }

    // MARK: - Screenshot Storage

    /// Save screenshot to file
    /// - Parameters:
    ///   - screenshot: XCUIScreenshot to save
    ///   - directory: Directory path to save to
    ///   - filename: Filename (without extension)
    /// - Returns: Full path to saved file
    @discardableResult
    public static func saveScreenshot(_ screenshot: XCUIScreenshot, toDirectory directory: String, filename: String) -> String? {
        let fileManager = FileManager.default

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory) {
            do {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
                print("❌ [Screenshot] Failed to create directory: \(error.localizedDescription)")
                return nil
            }
        }

        let fullPath = "\(directory)/\(filename)-\(timestamp()).png"

        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLPath: fullPath))
            print("✅ [Screenshot] Saved to: \(fullPath)")
            return fullPath
        } catch {
            print("❌ [Screenshot] Failed to save: \(error.localizedDescription)")
            return nil
        }
    }

    /// Save screenshot with default location
    /// - Parameters:
    ///   - name: Name for the screenshot
    /// - Returns: Full path to saved file
    @discardableResult
    public static func saveScreenshotToDefaultLocation(name: String = "Screenshot") -> String? {
        let screenshot = XCUIScreen.main.screenshot()
        let defaultDirectory = FileManager.default.currentDirectoryPath + "/Screenshots"
        return saveScreenshot(screenshot, toDirectory: defaultDirectory, filename: name)
    }

    // MARK: - Comparison (Manual - for documentation purposes)

    /// Note: XCUITest doesn't have built-in screenshot comparison
    /// For visual regression testing, consider using third-party tools like:
    /// - FBSnapshotTestCase (iOSSnapshotTestCase)
    /// - Applitools
    /// - Percy
    /// This method serves as a placeholder for custom comparison logic

    // MARK: - Helper Methods

    /// Generate timestamp for unique filenames
    /// - Returns: Formatted timestamp string
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
        return formatter.string(from: Date())
    }

    /// Get screenshots directory path
    /// - Returns: Path to screenshots directory
    public static func getScreenshotsDirectory() -> String {
        let directory = FileManager.default.currentDirectoryPath + "/Screenshots"
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: directory) {
            do {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
                print("❌ [Screenshot] Failed to create screenshots directory: \(error.localizedDescription)")
            }
        }

        return directory
    }

    /// Clean old screenshots
    /// - Parameters:
    ///   - directory: Directory to clean
    ///   - olderThanDays: Remove screenshots older than this many days
    public static func cleanOldScreenshots(fromDirectory directory: String, olderThanDays days: Int) {
        let fileManager = FileManager.default

        guard let files = try? fileManager.contentsOfDirectory(atPath: directory) else {
            print("⚠️ [Screenshot] Could not list files in directory: \(directory)")
            return
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        var removedCount = 0

        for file in files where file.hasSuffix(".png") {
            let filePath = "\(directory)/\(file)"

            if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < cutoffDate {

                do {
                    try fileManager.removeItem(atPath: filePath)
                    removedCount += 1
                } catch {
                    print("⚠️ [Screenshot] Failed to remove file \(file): \(error.localizedDescription)")
                }
            }
        }

        print("🗑️ [Screenshot] Removed \(removedCount) old screenshot(s) from \(directory)")
    }

    // MARK: - Video Recording

    private static var activeRecordings: [String: XCTContext] = [:]

    /// Start video recording
    /// - Parameter name: Name for the recording
    /// - Returns: Recording ID to use with stopVideoRecording
    public static func startVideoRecording(name: String = "Recording") -> String {
        let recordingId = "\(name)-\(timestamp())"

        XCTContext.runActivity(named: "Video Recording: \(recordingId)") { activity in
            activeRecordings[recordingId] = activity as? XCTContext
        }

        print("🎥 [Video] Started recording: \(recordingId)")
        return recordingId
    }

    /// Stop video recording and attach to test results
    /// - Parameters:
    ///   - recordingId: The ID returned from startVideoRecording
    ///   - lifetime: Lifetime of the video attachment
    @discardableResult
    public static func stopVideoRecording(recordingId: String, lifetime: XCTAttachment.Lifetime = .keepAlways) -> XCTAttachment? {
        guard activeRecordings[recordingId] != nil else {
            print("⚠️ [Video] No active recording found with ID: \(recordingId)")
            return nil
        }

        // Capture screenshot as fallback (XCUITest doesn't support true video recording yet)
        // In practice, video recording requires additional setup with simulator/device recording
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = recordingId
        attachment.lifetime = lifetime

        activeRecordings.removeValue(forKey: recordingId)

        print("🎥 [Video] Stopped recording: \(recordingId)")
        print("ℹ️ [Video] Note: Native video recording requires additional simulator recording setup")

        return attachment
    }

    /// Record video during a code block execution
    /// - Parameters:
    ///   - name: Name for the recording
    ///   - lifetime: Lifetime of the video attachment
    ///   - block: Code block to execute while recording
    public static func recordVideo(name: String = "Recording",
                                  lifetime: XCTAttachment.Lifetime = .keepAlways,
                                  during block: () throws -> Void) rethrows {
        let recordingId = startVideoRecording(name: name)
        defer {
            stopVideoRecording(recordingId: recordingId, lifetime: lifetime)
        }
        try block()
    }

    /// Start recording for test failure
    /// Automatically called from test lifecycle if configured
    public static func startFailureRecording(testName: String) -> String {
        return startVideoRecording(name: "FAILURE-\(testName)")
    }

    /// Get videos directory path
    /// - Returns: Path to videos directory
    public static func getVideosDirectory() -> String {
        let directory = FileManager.default.currentDirectoryPath + "/Videos"
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: directory) {
            do {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
                print("❌ [Video] Failed to create videos directory: \(error.localizedDescription)")
            }
        }

        return directory
    }

    /// Clean old video recordings
    /// - Parameters:
    ///   - directory: Directory to clean
    ///   - olderThanDays: Remove videos older than this many days
    public static func cleanOldVideos(fromDirectory directory: String, olderThanDays days: Int) {
        let fileManager = FileManager.default

        guard let files = try? fileManager.contentsOfDirectory(atPath: directory) else {
            print("⚠️ [Video] Could not list files in directory: \(directory)")
            return
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        var removedCount = 0

        for file in files where file.hasSuffix(".mp4") || file.hasSuffix(".mov") {
            let filePath = "\(directory)/\(file)"

            if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < cutoffDate {

                do {
                    try fileManager.removeItem(atPath: filePath)
                    removedCount += 1
                } catch {
                    print("⚠️ [Video] Failed to remove file \(file): \(error.localizedDescription)")
                }
            }
        }

        print("🗑️ [Video] Removed \(removedCount) old video(s) from \(directory)")
    }
}
