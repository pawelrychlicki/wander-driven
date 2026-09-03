import XCTest

final class WanderDrivenUITests: XCTestCase {
    func testLaunchShowsProjectName() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["WanderDriven"].waitForExistence(timeout: 5))
    }
}
