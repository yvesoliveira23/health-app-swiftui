import XCTest
import Combine
import HealthKit // Required for HKQuantitySample if used in mock
@testable import HealthApp

// MARK: - Mock HealthKitService
class MockHealthKitService: HealthKitService {
    var requestAuthorizationShouldSucceed: Bool = true
    var requestAuthorizationError: Error? = nil
    var fetchStepsShouldSucceed: Bool = true
    var fetchStepsData: [HKQuantitySample]? = nil
    var fetchStepsError: Error? = nil
    var fetchWeightShouldSucceed: Bool = true
    var fetchWeightData: [HKQuantitySample]? = nil
    var fetchWeightError: Error? = nil
    var saveShouldSucceed: Bool = true
    var saveError: Error? = nil

    var authorizationRequested = false
    var stepsFetched = false
    var weightsFetched = false
    var stepsSaved = false
    var weightSaved = false
    var lastSavedWeightInPounds: Double? = nil


    override func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        authorizationRequested = true
        if requestAuthorizationShouldSucceed {
            completion(true, nil)
        } else {
            completion(false, requestAuthorizationError ?? TestError.authorizationFailed)
        }
    }

    override func fetchSteps(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = HKObjectQueryNoLimit, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        stepsFetched = true
        if fetchStepsShouldSucceed {
            completion(fetchStepsData, nil)
        } else {
            completion(nil, fetchStepsError ?? TestError.fetchFailed)
        }
    }

    override func fetchWeight(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int = HKObjectQueryNoLimit, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        weightsFetched = true
        if fetchWeightShouldSucceed {
            completion(fetchWeightData, nil)
        } else {
            completion(nil, fetchWeightError ?? TestError.fetchFailed)
        }
    }

    override func saveSteps(steps: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        stepsSaved = true
        if saveShouldSucceed {
            completion(true, nil)
        } else {
            completion(false, saveError ?? TestError.saveFailed)
        }
    }

    override func saveWeight(weightInPounds: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        weightSaved = true
        lastSavedWeightInPounds = weightInPounds
        if saveShouldSucceed {
            completion(true, nil)
        } else {
            completion(false, saveError ?? TestError.saveFailed)
        }
    }

    // Helper to create HKQuantitySample for testing
    static func createSample(value: Double, unit: HKUnit, date: Date = Date()) -> HKQuantitySample {
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        // For HKQuantityType, we need a valid identifier.
        // This is a bit of a hack for mocking as HKQuantityType isn't easily mockable itself for samples.
        // In a real advanced test setup, you might need more sophisticated mocking or sample generation.
        var type: HKQuantityType!
        if unit == .count() {
            type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        } else if unit == .gramUnit(with: .kilo) || unit == .pound() {
            type = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        } else {
            // Fallback, though tests should use specific units.
            type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        }
        return HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
    }
}

enum TestError: Error, LocalizedError {
    case authorizationFailed
    case fetchFailed
    case saveFailed
    var errorDescription: String? {
        switch self {
        case .authorizationFailed: return "Mock Auth Failed"
        case .fetchFailed: return "Mock Fetch Failed"
        case .saveFailed: return "Mock Save Failed"
        }
    }
}


// MARK: - HealthDataViewModelTests
final class HealthDataViewModelTests: XCTestCase {
    var viewModel: HealthDataViewModel!
    var mockService: MockHealthKitService!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockService = MockHealthKitService()
        viewModel = HealthDataViewModel(healthKitService: mockService)
        cancellables = []
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testInitialization_PropertiesAreInInitialState() {
        XCTAssertTrue(viewModel.stepData.isEmpty)
        XCTAssertTrue(viewModel.weightData.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadInitialDataIfNeeded_WhenAuthNotDetermined_RequestsAuthAndFetchesDataOnSuccess() {
        // Given
        mockService.requestAuthorizationShouldSucceed = true
        // Mock HKHealthStore status - this is hard to directly mock, so we rely on service's behavior
        // Assume service correctly calls completion for success.

        let expectation = XCTestExpectation(description: "Fetch all health data after successful authorization")

        viewModel.$isLoading.dropFirst().sink { isLoading in
            if !isLoading && self.mockService.stepsFetched && self.mockService.weightsFetched {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        viewModel.loadInitialDataIfNeeded() // This will internally check auth status (which we can't easily mock here)
                                      // and then call requestAuthorization on the mock service.

        // Then
        XCTAssertTrue(mockService.authorizationRequested)
        // Wait for async operations
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockService.stepsFetched)
        XCTAssertTrue(mockService.weightsFetched)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadInitialDataIfNeeded_WhenAuthNotDetermined_SetsErrorOnAuthFailure() {
        // Given
        mockService.requestAuthorizationShouldSucceed = false
        mockService.requestAuthorizationError = TestError.authorizationFailed

        let expectation = XCTestExpectation(description: "Error message is set on authorization failure")

        viewModel.$errorMessage.dropFirst().sink { errorMessage in
            if errorMessage != nil {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        viewModel.loadInitialDataIfNeeded()

        // Then
        XCTAssertTrue(mockService.authorizationRequested)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, TestError.authorizationFailed.localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(mockService.stepsFetched) // Data fetch should not happen
    }

    func testFetchAllHealthData_PopulatesStepAndWeightDataOnSuccess() {
        // Given
        let stepSampleDate = Date().addingTimeInterval(-1000)
        let weightSampleDate = Date().addingTimeInterval(-2000)
        mockService.fetchStepsData = [MockHealthKitService.createSample(value: 100, unit: .count(), date: stepSampleDate)]
        mockService.fetchWeightData = [MockHealthKitService.createSample(value: 70, unit: .gramUnit(with: .kilo), date: weightSampleDate)]

        let expectation = XCTestExpectation(description: "Step and weight data are populated")

        Publishers.Zip(viewModel.$stepData.dropFirst(), viewModel.$weightData.dropFirst())
            .sink { steps, weights in
                if !steps.isEmpty && !weights.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchAllHealthData()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.stepData.count, 1)
        XCTAssertEqual(viewModel.stepData.first?.value, 100)
        XCTAssertEqual(viewModel.stepData.first?.date, stepSampleDate)
        XCTAssertEqual(viewModel.weightData.count, 1)
        XCTAssertEqual(viewModel.weightData.first?.value, 70)
        XCTAssertEqual(viewModel.weightData.first?.date, weightSampleDate)
    }

    func testFetchAllHealthData_SetsErrorMessageOnFetchFailure() {
        // Given
        mockService.fetchStepsShouldSucceed = false
        mockService.fetchStepsError = TestError.fetchFailed

        let expectation = XCTestExpectation(description: "Error message is set on fetch failure")
        viewModel.$errorMessage.dropFirst().sink { errorMessage in
            if errorMessage != nil {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        viewModel.fetchAllHealthData()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.stepData.isEmpty)
        XCTAssertTrue(viewModel.weightData.isEmpty) // Assuming weight fetch might also "fail" or not complete if one part fails
    }

    func testWriteWeightData_CallsServiceWithCorrectConversion() {
        // Given
        let weightInKg = 75.0
        let expectedWeightInPounds = weightInKg * 2.20462262185
        let testDate = Date()

        let expectation = XCTestExpectation(description: "Weight data is saved and refreshed")
        // We expect saveWeight to be called, then fetchWeight
        var saveCalled = false
        viewModel.$weightData.dropFirst().sink { data in
            if saveCalled && !data.isEmpty { // Check if refreshed
                 expectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        viewModel.writeWeightData(weightInKg: weightInKg, date: testDate) { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            saveCalled = true // Mark that save completed
        }

        // Then
        wait(for: [expectation], timeout: 2.0) // Increased timeout for save then fetch
        XCTAssertTrue(mockService.weightSaved)
        XCTAssertNotNil(mockService.lastSavedWeightInPounds)
        XCTAssertEqual(mockService.lastSavedWeightInPounds!, expectedWeightInPounds, accuracy: 0.001)
        XCTAssertTrue(mockService.weightsFetched) // Due to refresh
    }

    func testComputedProperty_totalStepsToday() {
        // Given
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        viewModel.stepData = [
            HealthDataPoint(date: today, value: 100, unit: "steps"),
            HealthDataPoint(date: today, value: 200, unit: "steps"),
            HealthDataPoint(date: yesterday, value: 500, unit: "steps")
        ]

        // When
        let totalSteps = viewModel.totalStepsToday

        // Then
        XCTAssertEqual(totalSteps, 300)
    }

    func testComputedProperty_latestWeightInKg() {
        // Given
        let date1 = Date().addingTimeInterval(-10000)
        let date2 = Date() // More recent

        viewModel.weightData = [
            HealthDataPoint(date: date1, value: 70.0, unit: "kg"),
            HealthDataPoint(date: date2, value: 71.5, unit: "kg")
        ]

        // When
        let latestWeight = viewModel.latestWeightInKg
        let latestUnit = viewModel.latestWeightUnit

        // Then
        XCTAssertEqual(latestWeight, 71.5)
        XCTAssertEqual(latestUnit, "kg")
    }
}

// Note: Testing the exact authorization status logic in `loadInitialDataIfNeeded`
// is tricky without directly mocking HKHealthStore().authorizationStatus.
// The current tests for it rely on the mock service's requestAuthorization path.
// For a production app, more focused tests on this specific logic might be desired
// if HKHealthStore could be more easily mocked or wrapped.
```
