import Foundation

/// Configuration reader with multi-environment support
/// Supports environment-specific configurations with priority system:
/// 1. Environment Variable (ENV)
/// 2. Default config.plist
public class ConfigReader {

    // MARK: - Properties

    private static var sharedInstance: ConfigReader?
    private var config: [String: Any] = [:]
    private let environment: String
    private var loadError: ConfigurationException?

    // MARK: - Initialization

    private init() {
        // Determine environment from ENV variable or default to "default"
        self.environment = ProcessInfo.processInfo.environment["ENV"] ?? "default"
        do {
            try loadConfiguration()
        } catch let error as ConfigurationException {
            self.loadError = error
            error.log()
        } catch {
            let wrappedError = ConfigurationException("Failed to load configuration", underlyingError: error)
            self.loadError = wrappedError
            wrappedError.log()
        }
    }

    public static var shared: ConfigReader {
        if sharedInstance == nil {
            sharedInstance = ConfigReader()
        }
        return sharedInstance!
    }

    // MARK: - Configuration Loading

    private func loadConfiguration() throws {
        let configFileName = environment == "default" ? "config" : "config-\(environment)"

        guard let configPath = Bundle.main.path(forResource: configFileName, ofType: "plist") else {
            // Fallback to default config if environment-specific not found
            if environment != "default" {
                print("⚠️ Config file '\(configFileName).plist' not found. Falling back to default config.")
                try loadDefaultConfig()
            } else {
                throw ConfigurationException.fileNotFound(configFileName + ".plist")
            }
            return
        }

        guard let configData = FileManager.default.contents(atPath: configPath) else {
            throw ConfigurationException.invalidFormat(configFileName + ".plist", reason: "Could not read file contents")
        }

        do {
            guard let plistConfig = try PropertyListSerialization.propertyList(from: configData, options: [], format: nil) as? [String: Any] else {
                throw ConfigurationException.invalidFormat(configFileName + ".plist", reason: "Invalid plist format")
            }
            config = plistConfig
            print("✅ Loaded configuration for environment: \(environment)")
        } catch {
            throw ConfigurationException.invalidFormat(configFileName + ".plist", reason: error.localizedDescription)
        }
    }

    private func loadDefaultConfig() throws {
        guard let configPath = Bundle.main.path(forResource: "config", ofType: "plist") else {
            throw ConfigurationException.fileNotFound("config.plist")
        }

        guard let configData = FileManager.default.contents(atPath: configPath) else {
            throw ConfigurationException.invalidFormat("config.plist", reason: "Could not read file contents")
        }

        do {
            guard let plistConfig = try PropertyListSerialization.propertyList(from: configData, options: [], format: nil) as? [String: Any] else {
                throw ConfigurationException.invalidFormat("config.plist", reason: "Invalid plist format")
            }
            config = plistConfig
        } catch {
            throw ConfigurationException.invalidFormat("config.plist", reason: error.localizedDescription)
        }
    }

    // MARK: - Public Methods

    /// Get string value for key
    /// - Throws: ConfigurationException if key not found or type mismatch
    public func getString(_ key: String) throws -> String {
        guard let value = config[key] else {
            throw ConfigurationException.missingKey(key, in: "config-\(environment).plist")
        }
        guard let stringValue = value as? String else {
            throw ConfigurationException.typeMismatch(key, expected: "String", actual: "\(type(of: value))")
        }
        return stringValue
    }

    /// Get string value with default fallback
    public func getString(_ key: String, default defaultValue: String) -> String {
        return (try? getString(key)) ?? defaultValue
    }

    /// Get integer value for key
    /// - Throws: ConfigurationException if key not found or type mismatch
    public func getInt(_ key: String) throws -> Int {
        guard let value = config[key] else {
            throw ConfigurationException.missingKey(key, in: "config-\(environment).plist")
        }
        guard let intValue = value as? Int else {
            throw ConfigurationException.typeMismatch(key, expected: "Int", actual: "\(type(of: value))")
        }
        return intValue
    }

    /// Get integer value with default fallback
    public func getInt(_ key: String, default defaultValue: Int) -> Int {
        return (try? getInt(key)) ?? defaultValue
    }

    /// Get boolean value for key
    /// - Throws: ConfigurationException if key not found or type mismatch
    public func getBool(_ key: String) throws -> Bool {
        guard let value = config[key] else {
            throw ConfigurationException.missingKey(key, in: "config-\(environment).plist")
        }
        guard let boolValue = value as? Bool else {
            throw ConfigurationException.typeMismatch(key, expected: "Bool", actual: "\(type(of: value))")
        }
        return boolValue
    }

    /// Get boolean value with default fallback
    public func getBool(_ key: String, default defaultValue: Bool) -> Bool {
        return (try? getBool(key)) ?? defaultValue
    }

    /// Get double value for key
    /// - Throws: ConfigurationException if key not found or type mismatch
    public func getDouble(_ key: String) throws -> Double {
        guard let value = config[key] else {
            throw ConfigurationException.missingKey(key, in: "config-\(environment).plist")
        }
        guard let doubleValue = value as? Double else {
            throw ConfigurationException.typeMismatch(key, expected: "Double", actual: "\(type(of: value))")
        }
        return doubleValue
    }

    /// Get double value with default fallback
    public func getDouble(_ key: String, default defaultValue: Double) -> Double {
        return (try? getDouble(key)) ?? defaultValue
    }

    /// Get array value for key
    /// - Throws: ConfigurationException if key not found or type mismatch
    public func getArray(_ key: String) throws -> [Any] {
        guard let value = config[key] else {
            throw ConfigurationException.missingKey(key, in: "config-\(environment).plist")
        }
        guard let arrayValue = value as? [Any] else {
            throw ConfigurationException.typeMismatch(key, expected: "Array", actual: "\(type(of: value))")
        }
        return arrayValue
    }

    /// Get array value with default fallback
    public func getArray(_ key: String, default defaultValue: [Any]) -> [Any] {
        return (try? getArray(key)) ?? defaultValue
    }

    /// Get dictionary value for key
    /// - Throws: ConfigurationException if key not found or type mismatch
    public func getDictionary(_ key: String) throws -> [String: Any] {
        guard let value = config[key] else {
            throw ConfigurationException.missingKey(key, in: "config-\(environment).plist")
        }
        guard let dictValue = value as? [String: Any] else {
            throw ConfigurationException.typeMismatch(key, expected: "Dictionary", actual: "\(type(of: value))")
        }
        return dictValue
    }

    /// Get dictionary value with default fallback
    public func getDictionary(_ key: String, default defaultValue: [String: Any]) -> [String: Any] {
        return (try? getDictionary(key)) ?? defaultValue
    }

    /// Get current environment
    public func getCurrentEnvironment() -> String {
        return environment
    }

    /// Reload configuration (useful for testing)
    public static func reload() {
        sharedInstance = nil
        _ = shared
    }

    /// Print all configuration for debugging
    public func printConfig() {
        print("📋 Current Configuration (Environment: \(environment)):")
        for (key, value) in config {
            print("  \(key): \(value)")
        }
    }

    // MARK: - Common Configuration Getters

    public var appBundleId: String {
        return getString("app.bundleId", default: "")
    }

    public var appPath: String {
        return getString("app.path", default: "")
    }

    public var deviceName: String {
        return getString("device.name", default: "iPhone 15")
    }

    public var platformVersion: String {
        return getString("device.platformVersion", default: "17.0")
    }

    public var implicitWaitTimeout: TimeInterval {
        return TimeInterval(getDouble("wait.implicitTimeout", default: 10.0))
    }

    public var explicitWaitTimeout: TimeInterval {
        return TimeInterval(getDouble("wait.explicitTimeout", default: 30.0))
    }

    public var screenshotOnFailure: Bool {
        return getBool("reporting.screenshotOnFailure", default: true)
    }

    public var videoRecording: Bool {
        return getBool("reporting.videoRecording", default: false)
    }

    public var baseURL: String {
        return getString("app.baseURL", default: "")
    }

    public var testDataPath: String {
        return getString("testData.path", default: "TestData")
    }
}
