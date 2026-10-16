//
//  TableView.swift
//  XCUITestFramework
//
//  Reusable TableView component for list interactions
//

import Foundation
import XCTest

/// Reusable TableView component for table/list interactions
public class TableView {

    // MARK: - Properties

    private let element: XCUIElement
    private let identifier: String
    private let timeout: TimeInterval

    // MARK: - Initialization

    public init(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        self.identifier = identifier
        self.element = app.tables[identifier]
        self.timeout = timeout
    }

    public init(element: XCUIElement, timeout: TimeInterval = 10) {
        self.element = element
        self.identifier = element.identifier
        self.timeout = timeout
    }

    // MARK: - Existence

    public var exists: Bool {
        return element.exists
    }

    public func waitForExistence(timeout: TimeInterval? = nil) -> Bool {
        return element.waitForExistence(timeout: timeout ?? self.timeout)
    }

    // MARK: - State

    public var cells: XCUIElementQuery {
        return element.cells
    }

    public var cellCount: Int {
        return cells.count
    }

    public var isEmpty: Bool {
        return cellCount == 0
    }

    // MARK: - Cell Access

    public func cell(at index: Int) -> XCUIElement {
        return cells.element(boundBy: index)
    }

    public func cell(withIdentifier identifier: String) -> XCUIElement {
        return cells[identifier]
    }

    public func cellContaining(text: String) -> XCUIElement {
        return cells.containing(NSPredicate(format: "label CONTAINS[c] %@", text)).element
    }

    // MARK: - Actions

    @discardableResult
    public func tap() -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found for tap")
            return self
        }
        print("✅ Tapping table view: \(identifier)")
        element.tap()
        return self
    }

    @discardableResult
    public func tapCell(at index: Int) -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found")
            return self
        }

        guard index < cellCount else {
            print("❌ Cell index \(index) out of bounds (count: \(cellCount))")
            return self
        }

        print("✅ Tapping cell at index: \(index)")
        cell(at: index).tap()
        return self
    }

    @discardableResult
    public func tapCell(withIdentifier identifier: String) -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(self.identifier)' not found")
            return self
        }

        let cell = cell(withIdentifier: identifier)
        guard cell.exists else {
            print("❌ Cell '\(identifier)' not found")
            return self
        }

        print("✅ Tapping cell: \(identifier)")
        cell.tap()
        return self
    }

    @discardableResult
    public func tapCellContaining(text: String) -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found")
            return self
        }

        let cell = cellContaining(text: text)
        guard cell.exists else {
            print("❌ Cell containing '\(text)' not found")
            return self
        }

        print("✅ Tapping cell containing: \(text)")
        cell.tap()
        return self
    }

    @discardableResult
    public func swipeUp() -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found for swipe up")
            return self
        }
        print("✅ Swiping up on table view: \(identifier)")
        element.swipeUp()
        return self
    }

    @discardableResult
    public func swipeDown() -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found for swipe down")
            return self
        }
        print("✅ Swiping down on table view: \(identifier)")
        element.swipeDown()
        return self
    }

    @discardableResult
    public func scrollToTop() -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found")
            return self
        }

        print("✅ Scrolling to top of table view: \(identifier)")
        if cellCount > 0 {
            cell(at: 0).coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).tap()
        }
        return self
    }

    @discardableResult
    public func scrollToBottom() -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found")
            return self
        }

        print("✅ Scrolling to bottom of table view: \(identifier)")
        var previousCount = 0
        var currentCount = cellCount

        while currentCount > previousCount {
            swipeUp()
            previousCount = currentCount
            currentCount = cellCount
        }

        return self
    }

    @discardableResult
    public func pullToRefresh() -> TableView {
        guard waitForExistence() else {
            print("❌ TableView '\(identifier)' not found for pull to refresh")
            return self
        }

        print("✅ Pulling to refresh table view: \(identifier)")
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: end)

        return self
    }

    // MARK: - Verification

    @discardableResult
    public func verifyExists(timeout: TimeInterval? = nil) -> TableView {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "TableView '\(identifier)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyNotExists(timeout: TimeInterval? = nil) -> TableView {
        XCTAssertFalse(
            element.waitForExistence(timeout: timeout ?? 2),
            "TableView '\(identifier)' should not exist"
        )
        return self
    }

    @discardableResult
    public func verifyCellCount(_ expected: Int) -> TableView {
        XCTAssertEqual(
            cellCount,
            expected,
            "TableView '\(identifier)' should have \(expected) cells but has \(cellCount)"
        )
        return self
    }

    @discardableResult
    public func verifyCellExists(at index: Int) -> TableView {
        XCTAssertTrue(
            index < cellCount,
            "Cell at index \(index) should exist (count: \(cellCount))"
        )
        return self
    }

    @discardableResult
    public func verifyCellExists(withIdentifier identifier: String) -> TableView {
        XCTAssertTrue(
            cell(withIdentifier: identifier).exists,
            "Cell '\(identifier)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyCellContains(text: String) -> TableView {
        XCTAssertTrue(
            cellContaining(text: text).exists,
            "Cell containing '\(text)' should exist"
        )
        return self
    }

    @discardableResult
    public func verifyEmpty() -> TableView {
        XCTAssertTrue(isEmpty, "TableView '\(identifier)' should be empty")
        return self
    }

    @discardableResult
    public func verifyNotEmpty() -> TableView {
        XCTAssertFalse(isEmpty, "TableView '\(identifier)' should not be empty")
        return self
    }

    // MARK: - Screenshot

    @discardableResult
    public func takeScreenshot(name: String? = nil) -> TableView {
        let screenshotName = name ?? "tableview_\(identifier)"
        let screenshot = element.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = screenshotName
        attachment.lifetime = .keepAlways
        XCTContext.runActivity(named: "Screenshot: \(screenshotName)") { activity in
            activity.add(attachment)
        }
        return self
    }
}
