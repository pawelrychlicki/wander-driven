import XCTest

final nonisolated class WanderDrivenUITests: XCTestCase {
    @MainActor
    func testLaunchShowsProjectName() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["WanderDriven"].waitForExistence(timeout: 5))
    }
}
