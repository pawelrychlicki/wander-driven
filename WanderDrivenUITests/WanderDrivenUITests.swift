import XCTest

final nonisolated class WanderDrivenUITests: XCTestCase {
    @MainActor
    func testLaunchShowsProjectName() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["WanderDriven"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDiscoverNavigatesAndPersistsFavorite() {
        let app = launch(scenario: "discover")
        let favoriteButton = app.buttons["sdui.lisbon-card.favorite"]
        let openButton = app.buttons["sdui.lisbon-card.open"]

        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))
        XCTAssertTrue(openButton.waitForExistence(timeout: 5))
        XCTAssertEqual(favoriteButton.value as? String, "Not a favorite")

        favoriteButton.tap()
        XCTAssertEqual(favoriteButton.value as? String, "Favorite")

        app.swipeDown()

        openButton.tap()
        XCTAssertTrue(app.navigationBars["Destination Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Lisbon"].waitForExistence(timeout: 5))

        let saveNoteButton = app.buttons["sdui.lisbon-save-note"]
        XCTAssertTrue(saveNoteButton.waitForExistence(timeout: 5))
        saveNoteButton.tap()
        XCTAssertTrue(app.alerts["Saved locally"].waitForExistence(timeout: 5))
        app.alerts.buttons["OK"].tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))
        XCTAssertEqual(favoriteButton.value as? String, "Favorite")
    }

    @MainActor
    func testDiagnosticsKeepValidSiblingVisible() {
        let app = launch(scenario: "diagnostics")

        XCTAssertTrue(
            app.descendants(matching: .any)["diagnostics.overlay"]
                .waitForExistence(timeout: 5)
        )
        for _ in 0 ..< 3 {
            app.swipeUp()
        }

        XCTAssertTrue(
            app.descendants(matching: .any)["sdui.diagnostics-valid-sibling"]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["diagnostic.diagnostics-unknown"]
                .waitForExistence(timeout: 5)
        )
    }

    @MainActor
    private func launch(scenario: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestScenario", scenario]
        app.launch()
        return app
    }
}
