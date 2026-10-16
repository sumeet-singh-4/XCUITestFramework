import XCTest

/// Basic Test - Verify wdiodemoapp launches and basic elements are accessible
class WdioDemoAppBasicTest: BaseTest {

    // MARK: - Test Cases

    /// Test that the app launches successfully
    func testAppLaunches() {
        logStep("Test: Verify wdiodemoapp launches")

        // The app should already be launched by BaseTest
        XCTAssertTrue(app.exists, "App should exist")
        XCTAssertTrue(app.state == .runningForeground, "App should be running in foreground")

        logInfo("App launched successfully")
    }

    /// Test that we can access app elements
    func testCanAccessAppElements() {
        logStep("Test: Verify we can access app elements")

        // Wait a bit for app to fully load
        wait(2.0)

        // Print app hierarchy for debugging
        print("📱 App hierarchy:")
        print(app.debugDescription)

        // Check for common UI elements
        let buttons = app.buttons.allElementsBoundByIndex
        let textFields = app.textFields.allElementsBoundByIndex
        let staticTexts = app.staticTexts.allElementsBoundByIndex

        print("Found \(buttons.count) buttons")
        print("Found \(textFields.count) text fields")
        print("Found \(staticTexts.count) static texts")

        // At least the app should have some UI elements
        let totalElements = buttons.count + textFields.count + staticTexts.count
        XCTAssertGreaterThan(totalElements, 0, "App should have at least some UI elements")

        logInfo("Successfully accessed app elements")
    }

    /// Test app navigation tabs (if they exist)
    func testAppTabs() {
        logStep("Test: Check for app tabs")

        wait(2.0)

        // Check for tab bar
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let tabs = tabBar.buttons.allElementsBoundByIndex
            print("Found \(tabs.count) tabs:")
            for (index, tab) in tabs.enumerated() {
                print("  Tab \(index): \(tab.label)")
            }

            XCTAssertGreaterThan(tabs.count, 0, "Should have at least one tab")
            logInfo("Found \(tabs.count) tabs in the app")
        } else {
            print("No tab bar found in the app")
            logInfo("App doesn't have a tab bar")
        }
    }

    /// Test tapping the first button in the app
    func testTapFirstButton() {
        logStep("Test: Tap first button if available")

        wait(2.0)

        let buttons = app.buttons.allElementsBoundByIndex
        if buttons.count > 0 {
            let firstButton = buttons[0]
            print("First button label: \(firstButton.label)")

            if firstButton.isHittable {
                firstButton.tap()
                logInfo("Successfully tapped first button: \(firstButton.label)")

                // Wait to see what happens
                wait(1.0)

                // Verify app still exists after tap
                XCTAssertTrue(app.exists, "App should still exist after tapping button")
            } else {
                print("First button is not hittable")
            }
        } else {
            print("No buttons found in the app")
        }
    }
}
