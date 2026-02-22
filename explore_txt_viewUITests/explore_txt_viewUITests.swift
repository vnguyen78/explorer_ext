import XCTest

final class explore_txt_viewUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testNavigationBackAndForwardUI() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the navigation buttons are present
        let backButton = app.buttons["chevron.left"]
        let forwardButton = app.buttons["chevron.right"]
        let upButton = app.buttons["arrow.up"]
        
        XCTAssertTrue(backButton.exists, "Back button should exist in the UI")
        XCTAssertTrue(forwardButton.exists, "Forward button should exist in the UI")
        XCTAssertTrue(upButton.exists, "Up button should exist in the UI")
        
        // Initially they should be disabled because no history exists
        XCTAssertFalse(backButton.isEnabled, "Back button should be disabled initially")
        XCTAssertFalse(forwardButton.isEnabled, "Forward button should be disabled initially")
        XCTAssertFalse(upButton.isEnabled, "Up button should be disabled initially")
    }
}
