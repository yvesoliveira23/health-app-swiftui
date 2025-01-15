import XCTest
@testable import HealthApp

final class HealthDataUITests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: XCUIApplication!
    
    // MARK: - Lifecycle Methods
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        sut = XCUIApplication()
        sut.launch()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - View Loading Tests
    
    func testDashboardView_whenAppLaunches_shouldDisplayDashboard() throws {
        // Given
        let navigationBar = sut.navigationBars["Dashboard"]
        
        // When
        let exists = navigationBar.exists
        
        // Then
        XCTAssertTrue(exists, "Dashboard view should be loaded.")
    }
    
    // MARK: - Navigation Tests
    
    func testDataListView_whenNavigatingToDataList_shouldDisplayHealthData() throws {
        // Given
        sut.tabBars.buttons["Data List"].tap()
        
        // When
        let exists = sut.tables["HealthDataList"].exists
        
        // Then
        XCTAssertTrue(exists, "Data List view should display health data.")
    }
    
    // MARK: - Chart Display Tests
    
    func testStepBarChart_whenNavigatingToStepChart_shouldDisplayChart() throws {
        // Given
        sut.tabBars.buttons["Step Chart"].tap()
        
        // When
        let exists = sut.otherElements["StepBarChart"].exists
        
        // Then
        XCTAssertTrue(exists, "Step Bar Chart should be displayed.")
    }
    
    func testWeightLineChart_whenNavigatingToWeightChart_shouldDisplayChart() throws {
        // Given
        sut.tabBars.buttons["Weight Chart"].tap()
        
        // When
        let exists = sut.otherElements["WeightLineChart"].exists
        
        // Then
        XCTAssertTrue(exists, "Weight Line Chart should be displayed.")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling_whenNavigatingToErrorView_shouldDisplayAlert() throws {
        // Given
        sut.tabBars.buttons["Error Handling"].tap()
        
        // When
        let exists = sut.alerts["Error"].exists
        
        // Then
        XCTAssertTrue(exists, "Error Handling view should display an error alert if applicable.")
    }
}