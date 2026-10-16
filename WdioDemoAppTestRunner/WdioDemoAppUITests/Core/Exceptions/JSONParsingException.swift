//
//  JSONParsingException.swift
//  XCUITestFramework
//
//  Exception for JSON parsing and reading errors
//

import Foundation

/// Exception thrown when JSON parsing or reading fails
public class JSONParsingException: FrameworkException {

    // MARK: - Properties

    public let fileName: String?
    public let jsonPath: String?

    // MARK: - Initialization

    public init(
        _ message: String,
        fileName: String? = nil,
        jsonPath: String? = nil,
        underlyingError: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.fileName = fileName
        self.jsonPath = jsonPath
        super.init(message, underlyingError: underlyingError, file: file, function: function, line: line)
    }

    // MARK: - Factory Methods

    /// JSON file not found
    public static func fileNotFound(_ fileName: String) -> JSONParsingException {
        return JSONParsingException("JSON file '\(fileName)' not found", fileName: fileName)
    }

    /// JSON file is invalid or corrupted
    public static func invalidJSON(_ fileName: String, underlyingError: Error? = nil) -> JSONParsingException {
        return JSONParsingException(
            "Failed to parse JSON file '\(fileName)'. File may be corrupted or contain invalid JSON.",
            fileName: fileName,
            underlyingError: underlyingError
        )
    }

    /// JSON key not found
    public static func keyNotFound(_ key: String, in fileName: String) -> JSONParsingException {
        return JSONParsingException(
            "Key '\(key)' not found in JSON file '\(fileName)'",
            fileName: fileName,
            jsonPath: key
        )
    }

    /// JSON key path not found
    public static func keyPathNotFound(_ keyPath: String, in fileName: String) -> JSONParsingException {
        return JSONParsingException(
            "Key path '\(keyPath)' not found in JSON file '\(fileName)'",
            fileName: fileName,
            jsonPath: keyPath
        )
    }

    /// JSON type mismatch
    public static func typeMismatch(
        _ key: String,
        expected: String,
        actual: String,
        in fileName: String
    ) -> JSONParsingException {
        return JSONParsingException(
            "Type mismatch for key '\(key)' in '\(fileName)'. Expected '\(expected)' but got '\(actual)'",
            fileName: fileName,
            jsonPath: key
        )
    }

    /// Failed to decode JSON to model
    public static func decodingFailed<T>(
        _ type: T.Type,
        fileName: String,
        underlyingError: Error
    ) -> JSONParsingException {
        return JSONParsingException(
            "Failed to decode JSON file '\(fileName)' to type '\(String(describing: type))'",
            fileName: fileName,
            underlyingError: underlyingError
        )
    }

    /// JSON data is empty
    public static func emptyData(_ fileName: String) -> JSONParsingException {
        return JSONParsingException("JSON file '\(fileName)' is empty", fileName: fileName)
    }
}
