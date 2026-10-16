import XCTest

/// Screen factory for creating and caching page objects
/// Implements singleton pattern with thread-safe caching
public class ScreenFactory {

    // MARK: - Properties

    private static var screenCache: [String: Any] = [:]
    private static let cacheLock = NSLock()

    // MARK: - Factory Methods

    /// Get or create a screen instance
    /// - Parameters:
    ///   - screenType: The type of screen to create
    ///   - app: The XCUIApplication instance
    /// - Returns: An instance of the requested screen type
    public static func getScreen<T: BasePage>(_ screenType: T.Type, app: XCUIApplication) -> T {
        let key = String(describing: screenType)

        cacheLock.lock()
        defer { cacheLock.unlock() }

        if let cachedScreen = screenCache[key] as? T {
            print("ℹ️ [ScreenFactory] Retrieved cached screen: \(key)")
            return cachedScreen
        }

        let newScreen = screenType.init(app: app)
        screenCache[key] = newScreen
        print("✅ [ScreenFactory] Created new screen: \(key)")

        return newScreen
    }

    /// Get or create a screen instance with custom timeout
    /// - Parameters:
    ///   - screenType: The type of screen to create
    ///   - app: The XCUIApplication instance
    ///   - timeout: Custom timeout for the screen
    /// - Returns: An instance of the requested screen type
    public static func getScreen<T: BasePage>(_ screenType: T.Type, app: XCUIApplication, timeout: TimeInterval) -> T {
        let key = String(describing: screenType)

        cacheLock.lock()
        defer { cacheLock.unlock() }

        if let cachedScreen = screenCache[key] as? T {
            print("ℹ️ [ScreenFactory] Retrieved cached screen: \(key)")
            return cachedScreen
        }

        let newScreen = screenType.init(app: app, timeout: timeout)
        screenCache[key] = newScreen
        print("✅ [ScreenFactory] Created new screen: \(key)")

        return newScreen
    }

    /// Clear screen cache
    public static func clearCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        screenCache.removeAll()
        print("🗑️ [ScreenFactory] Cache cleared")
    }

    /// Clear specific screen from cache
    /// - Parameter screenType: The type of screen to clear
    public static func clearScreen<T: BasePage>(_ screenType: T.Type) {
        let key = String(describing: screenType)

        cacheLock.lock()
        defer { cacheLock.unlock() }

        screenCache.removeValue(forKey: key)
        print("🗑️ [ScreenFactory] Cleared screen from cache: \(key)")
    }

    /// Get cache statistics
    public static func getCacheInfo() -> [String: Any] {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        return [
            "cachedScreenCount": screenCache.count,
            "cachedScreens": Array(screenCache.keys)
        ]
    }

    /// Print cache info for debugging
    public static func printCacheInfo() {
        let info = getCacheInfo()
        print("📊 [ScreenFactory] Cache Info:")
        print("  Cached Screens: \(info["cachedScreenCount"] ?? 0)")
        if let screens = info["cachedScreens"] as? [String] {
            for screen in screens {
                print("    - \(screen)")
            }
        }
    }
}
