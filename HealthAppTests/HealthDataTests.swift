import XCTest
@testable import HealthApp

final class HealthDataTests: XCTestCase {

    private var healthDataModel: HealthDataModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        healthDataModel = HealthDataModel(steps: 0, weight: 0.0)
    }

    override func tearDownWithError() throws {
        healthDataModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Initial State Tests

    func testInitialHealthData_ShouldHaveZeroStepsAndWeight() throws {
        XCTAssertEqual(healthDataModel.steps, 0)
        XCTAssertEqual(healthDataModel.weight, 0.0)
    }

    // MARK: - Update Tests

    func testUpdateSteps_ShouldUpdateStepsCorrectly() throws {
        // Given
        let newSteps = 100
        
        // When
        healthDataModel.updateSteps(newSteps)
        
        // Then
        XCTAssertEqual(healthDataModel.steps, newSteps)
    }

    func testUpdateWeight_ShouldUpdateWeightCorrectly() throws {
        // Given
        let newWeight = 70.5
        
        // When
        healthDataModel.updateWeight(newWeight)
        
        // Then
        XCTAssertEqual(healthDataModel.weight, newWeight)
    }

    // MARK: - Performance Tests

    func testHealthDataModelPerformance_WhenUpdatingStepsAndWeight_ShouldPerformEfficiently() throws {
        measure {
            for _ in 0..<1000 {
                healthDataModel.updateSteps(1)
                healthDataModel.updateWeight(70.0)
            }
        }
    }
}