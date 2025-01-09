import XCTest

final class HealthDataUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }

    func testDashboardViewLoads() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.navigationBars["Dashboard"].exists, "Dashboard view should be loaded.")
    }

    func testDataListViewDisplaysData() throws {
        let app = XCUIApplication()
        app.tabBars.buttons["Data List"].tap()
        XCTAssertTrue(app.tables["HealthDataList"].exists, "Data List view should display health data.")
    }

    func testStepBarChartViewDisplays() throws {
        let app = XCUIApplication()
        app.tabBars.buttons["Step Chart"].tap()
        XCTAssertTrue(app.otherElements["StepBarChart"].exists, "Step Bar Chart should be displayed.")
    }

    func testWeightLineChartViewDisplays() throws {
        let app = XCUIApplication()
        app.tabBars.buttons["Weight Chart"].tap()
        XCTAssertTrue(app.otherElements["WeightLineChart"].exists, "Weight Line Chart should be displayed.")
    }

    func testErrorHandlingViewDisplays() throws {
        let app = XCUIApplication()
        app.tabBars.buttons["Error Handling"].tap()
        XCTAssertTrue(app.alerts["Error"].exists, "Error Handling view should display an error alert if applicable.")
    }
}