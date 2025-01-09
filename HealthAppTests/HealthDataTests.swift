import XCTest
@testable import PortfolioPiece

class HealthDataTests: XCTestCase {

    var healthDataModel: HealthDataModel!

    override func setUpWithError() throws {
        super.setUp()
        healthDataModel = HealthDataModel(steps: 0, weight: 0.0)
    }

    override func tearDownWithError() throws {
        healthDataModel = nil
        super.tearDown()
    }

    func testInitialHealthData() throws {
        XCTAssertEqual(healthDataModel.steps, 0)
        XCTAssertEqual(healthDataModel.weight, 0.0)
    }

    func testUpdateSteps() throws {
        healthDataModel.updateSteps(100)
        XCTAssertEqual(healthDataModel.steps, 100)
    }

    func testUpdateWeight() throws {
        healthDataModel.updateWeight(70.5)
        XCTAssertEqual(healthDataModel.weight, 70.5)
    }

    func testHealthDataModelPerformance() throws {
        self.measure {
            for _ in 0..<1000 {
                healthDataModel.updateSteps(1)
                healthDataModel.updateWeight(70.0)
            }
        }
    }
}