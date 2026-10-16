import Foundation

/// Utility class for reading JSON test data files
public class JSONReader {

    // MARK: - Read JSON File

    /// Read JSON file and return as Dictionary
    /// - Parameter filename: Name of the JSON file (without extension)
    /// - Returns: Dictionary representation of JSON, or empty dictionary if error
    public static func readJSON(filename: String) -> [String: Any] {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("❌ [JSONReader] File not found: \(filename).json")
            return [:]
        }

        return readJSON(atPath: path)
    }

    /// Read JSON file at specific path and return as Dictionary
    /// - Parameter path: Full path to JSON file
    /// - Returns: Dictionary representation of JSON, or empty dictionary if error
    public static func readJSON(atPath path: String) -> [String: Any] {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let json = try JSONSerialization.jsonObject(with: data, options: [])

            if let dictionary = json as? [String: Any] {
                print("✅ [JSONReader] Successfully read JSON from: \(path)")
                return dictionary
            } else {
                print("❌ [JSONReader] JSON is not a dictionary: \(path)")
                return [:]
            }
        } catch {
            print("❌ [JSONReader] Error reading JSON: \(error.localizedDescription)")
            return [:]
        }
    }

    // MARK: - Read JSON as Array

    /// Read JSON file and return as Array
    /// - Parameter filename: Name of the JSON file (without extension)
    /// - Returns: Array representation of JSON, or empty array if error
    public static func readJSONArray(filename: String) -> [[String: Any]] {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("❌ [JSONReader] File not found: \(filename).json")
            return []
        }

        return readJSONArray(atPath: path)
    }

    /// Read JSON file at specific path and return as Array
    /// - Parameter path: Full path to JSON file
    /// - Returns: Array representation of JSON, or empty array if error
    public static func readJSONArray(atPath path: String) -> [[String: Any]] {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let json = try JSONSerialization.jsonObject(with: data, options: [])

            if let array = json as? [[String: Any]] {
                print("✅ [JSONReader] Successfully read JSON array from: \(path)")
                return array
            } else {
                print("❌ [JSONReader] JSON is not an array: \(path)")
                return []
            }
        } catch {
            print("❌ [JSONReader] Error reading JSON array: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Read and Decode to Codable

    /// Read JSON file and decode to Codable type
    /// - Parameters:
    ///   - filename: Name of the JSON file (without extension)
    ///   - type: The Decodable type to decode to
    /// - Returns: Decoded object or nil if error
    public static func readAndDecode<T: Decodable>(filename: String, as type: T.Type) -> T? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("❌ [JSONReader] File not found: \(filename).json")
            return nil
        }

        return readAndDecode(atPath: path, as: type)
    }

    /// Read JSON file at specific path and decode to Codable type
    /// - Parameters:
    ///   - path: Full path to JSON file
    ///   - type: The Decodable type to decode to
    /// - Returns: Decoded object or nil if error
    public static func readAndDecode<T: Decodable>(atPath path: String, as type: T.Type) -> T? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(type, from: data)
            print("✅ [JSONReader] Successfully decoded JSON to \(type) from: \(path)")
            return decoded
        } catch {
            print("❌ [JSONReader] Error decoding JSON: \(error.localizedDescription)")
            return nil
        }
    }

    /// Decode JSON file (throws version for DataProvider)
    /// - Parameters:
    ///   - filename: Name of the JSON file (without extension)
    ///   - type: The Decodable type to decode to
    ///   - bundle: Bundle to search for the file (defaults to main)
    /// - Returns: Decoded object
    /// - Throws: Error if file not found or decoding fails
    public static func decode<T: Decodable>(fileName: String, as type: T.Type, bundle: Bundle = .main) throws -> T {
        guard let path = bundle.path(forResource: fileName, ofType: "json") else {
            throw NSError(domain: "JSONReader", code: 404, userInfo: [NSLocalizedDescriptionKey: "JSON file '\(fileName).json' not found"])
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(type, from: data)
        print("✅ [JSONReader] Successfully decoded JSON to \(type) from: \(fileName).json")
        return decoded
    }

    // MARK: - Get Value by Key Path

    /// Get value from JSON using key path (e.g., "user.credentials.username")
    /// - Parameters:
    ///   - json: JSON dictionary
    ///   - keyPath: Dot-separated key path
    /// - Returns: Value at key path or nil if not found
    public static func getValue(from json: [String: Any], keyPath: String) -> Any? {
        let keys = keyPath.split(separator: ".").map(String.init)
        var current: Any? = json

        for key in keys {
            if let dict = current as? [String: Any] {
                current = dict[key]
            } else {
                print("⚠️ [JSONReader] Key path not found: \(keyPath)")
                return nil
            }
        }

        return current
    }

    /// Get string value from JSON using key path
    /// - Parameters:
    ///   - json: JSON dictionary
    ///   - keyPath: Dot-separated key path
    /// - Returns: String value or empty string if not found
    public static func getString(from json: [String: Any], keyPath: String) -> String {
        return getValue(from: json, keyPath: keyPath) as? String ?? ""
    }

    /// Get integer value from JSON using key path
    /// - Parameters:
    ///   - json: JSON dictionary
    ///   - keyPath: Dot-separated key path
    /// - Returns: Integer value or 0 if not found
    public static func getInt(from json: [String: Any], keyPath: String) -> Int {
        return getValue(from: json, keyPath: keyPath) as? Int ?? 0
    }

    /// Get boolean value from JSON using key path
    /// - Parameters:
    ///   - json: JSON dictionary
    ///   - keyPath: Dot-separated key path
    /// - Returns: Boolean value or false if not found
    public static func getBool(from json: [String: Any], keyPath: String) -> Bool {
        return getValue(from: json, keyPath: keyPath) as? Bool ?? false
    }

    // MARK: - Pretty Print JSON

    /// Pretty print JSON dictionary
    /// - Parameter json: JSON dictionary
    public static func prettyPrint(_ json: [String: Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let string = String(data: data, encoding: .utf8) {
            print("📄 [JSONReader] JSON Content:\n\(string)")
        }
    }
}
