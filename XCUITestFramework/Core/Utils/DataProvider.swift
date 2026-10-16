//
//  DataProvider.swift
//  XCUITestFramework
//
//  Data provider pattern for data-driven testing
//

import Foundation

/// Protocol for data providers
public protocol DataProvider {
    associatedtype DataType
    func provideData() throws -> [DataType]
}

/// JSON-based data provider
public class JSONDataProvider<T: Decodable>: DataProvider {
    public typealias DataType = T

    private let fileName: String
    private let bundle: Bundle

    public init(fileName: String, bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }

    public func provideData() throws -> [T] {
        return try JSONReader.decode(fileName: fileName, as: [T].self, bundle: bundle)
    }
}

/// CSV-based data provider
public class CSVDataProvider: DataProvider {
    public typealias DataType = [String: String]

    private let fileName: String
    private let bundle: Bundle
    private let delimiter: String

    public init(fileName: String, delimiter: String = ",", bundle: Bundle = .main) {
        self.fileName = fileName
        self.delimiter = delimiter
        self.bundle = bundle
    }

    public func provideData() throws -> [[String: String]] {
        guard let filePath = bundle.path(forResource: fileName, ofType: "csv") else {
            throw NSError(domain: "DataProvider", code: 404, userInfo: [NSLocalizedDescriptionKey: "CSV file '\(fileName).csv' not found"])
        }

        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

        guard let headerLine = lines.first else {
            throw NSError(domain: "DataProvider", code: 400, userInfo: [NSLocalizedDescriptionKey: "CSV file is empty"])
        }

        let headers = headerLine.components(separatedBy: delimiter)
        var result: [[String: String]] = []

        for line in lines.dropFirst() {
            let values = line.components(separatedBy: delimiter)
            var row: [String: String] = [:]

            for (index, header) in headers.enumerated() where index < values.count {
                row[header] = values[index]
            }

            result.append(row)
        }

        return result
    }
}

/// In-memory data provider
public class InMemoryDataProvider<T>: DataProvider {
    public typealias DataType = T

    private let data: [T]

    public init(data: [T]) {
        self.data = data
    }

    public func provideData() throws -> [T] {
        return data
    }
}

/// Data-driven test runner
public class DataDrivenTestRunner {

    /// Run test with data from provider
    /// - Parameters:
    ///   - provider: Data provider
    ///   - testBlock: Test block to execute for each data item
    public static func run<P: DataProvider>(with provider: P, testBlock: (P.DataType, Int) throws -> Void) throws {
        do {
            let data = try provider.provideData()
            print("📊 [DataProvider] Running test with \(data.count) data sets")

            for (index, item) in data.enumerated() {
                print("  ▶️  Data set \(index + 1)/\(data.count)")
                try testBlock(item, index)
            }

            print("✅ [DataProvider] All data-driven tests completed")
        } catch {
            print("❌ [DataProvider] Failed to load test data: \(error.localizedDescription)")
            throw error
        }
    }

    /// Run test with JSON data
    /// - Parameters:
    ///   - fileName: JSON file name
    ///   - testBlock: Test block to execute for each data item
    public static func runWithJSON<T: Decodable>(fileName: String, testBlock: (T, Int) throws -> Void) throws {
        let provider = JSONDataProvider<T>(fileName: fileName)
        try run(with: provider, testBlock: testBlock)
    }

    /// Run test with CSV data
    /// - Parameters:
    ///   - fileName: CSV file name
    ///   - testBlock: Test block to execute for each row
    public static func runWithCSV(fileName: String, testBlock: ([String: String], Int) throws -> Void) throws {
        let provider = CSVDataProvider(fileName: fileName)
        try run(with: provider, testBlock: testBlock)
    }
}
