import XCTest
@testable import HealthApp

// Renaming to reflect that it tests HealthDataModel specifically.
// If HealthDataModel is removed later, these tests would also be removed.
final class HealthDataModelTests: XCTestCase {

    private var healthDataModel: HealthDataModel!
    private var testDate: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()
        testDate = Date() // A consistent date for tests
        // Initialize with some default values as per the model's initializer
        healthDataModel = HealthDataModel(steps: 100, weight: 60.5, date: testDate)
    }

    override func tearDownWithError() throws {
        healthDataModel = nil
        testDate = nil
        try super.tearDownWithError()
    }

    // MARK: - Initial State Tests

    func testHealthDataModelInitialization_ShouldStoreValuesCorrectly() throws {
        XCTAssertEqual(healthDataModel.steps, 100)
        XCTAssertEqual(healthDataModel.weight, 60.5)
        XCTAssertEqual(healthDataModel.date, testDate)
        XCTAssertNotNil(healthDataModel.id) // ID should be auto-generated
    }

    func testHealthDataModelInitialization_WithSpecificID_ShouldStoreValuesCorrectly() throws {
        let specificID = UUID()
        let modelWithID = HealthDataModel(id: specificID, steps: 200, weight: 70.0, date: testDate)
        
        XCTAssertEqual(modelWithID.id, specificID)
        XCTAssertEqual(modelWithID.steps, 200)
        XCTAssertEqual(modelWithID.weight, 70.0)
        XCTAssertEqual(modelWithID.date, testDate)
    }

    // The methods `updateSteps` and `updateWeight` are not part of the
    // HealthDataModel definition read previously.
    // Therefore, tests for those methods are removed.
    // Performance tests based on those methods are also removed.
    // If HealthDataModel is intended to be mutable with update methods,
    // those methods should be added to the model and then tested here.
}