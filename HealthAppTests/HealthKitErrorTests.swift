import XCTest
@testable import HealthApp

/// Test suite for HealthKitError validation
final class HealthKitErrorTests: XCTestCase {
        
        private var sut: HealthKitError!
        
        override func setUp() {
            super.setUp()
        }
        
        override func tearDown() {
            sut = nil
            super.tearDown()
        }
        
        // MARK: - Availability Tests
        
        func testErrorDescription_WhenTypeNotAvailable_ShouldReturnCorrectDescription() {
            // Given
            sut = .typeNotAvailable
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertEqual(description, "HealthKit type not available")
        }

        // MARK: - Authorization Tests
        
        func testErrorDescription_WhenUnauthorized_ShouldReturnCorrectDescription() {
            // Given
            sut = .unauthorized
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertEqual(description, "HealthKit access not authorized")
        }
        
        // MARK: - Fetch Error Tests
        
        func testErrorDescription_WhenFetchFailedWithUnderlyingError_ShouldReturnCorrectDescription() {
            // Given
            let underlyingError = createTestError(description: "Test error")
            sut = .fetchFailed(underlyingError)
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertEqual(description, "Failed to fetch HealthKit data: Test error")
            XCTAssertTrue(description!.contains("Test error"))
        }
        
        func testErrorDescription_WhenFetchFailedWithNil_ShouldReturnUnknownErrorDescription() {
            // Given
            sut = .fetchFailed(nil)
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertEqual(description, "Failed to fetch HealthKit data: Unknown error")
            XCTAssertTrue(description!.contains("Unknown error"))
        }
        
        func testErrorDescription_WhenFetchFailedWithEmptyError_ShouldReturnDefaultErrorDescription() {
            // Given
            let underlyingError = createTestError(description: nil)
            sut = .fetchFailed(underlyingError)
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertTrue(description!.contains("TestDomain error 1"))
        }
        
        // MARK: - Save Error Tests
        
        func testErrorDescription_WhenSaveFailedWithUnderlyingError_ShouldReturnCorrectDescription() {
            // Given 
            let underlyingError = createTestError(description: "Test error")
            sut = .saveFailed(underlyingError)
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertEqual(description, "Failed to save HealthKit data: Test error")
            XCTAssertTrue(description!.contains("Test error"))
        }
        
        func testErrorDescription_WhenSaveFailedWithNil_ShouldReturnUnknownErrorDescription() {
            // Given
            sut = .saveFailed(nil)
            
            // When
            let description = sut.errorDescription
            
            // Then  
            XCTAssertNotNil(description)
            XCTAssertEqual(description, "Failed to save HealthKit data: Unknown error")
            XCTAssertTrue(description!.contains("Unknown error"))
        }
        
        func testErrorDescription_WhenSaveFailedWithEmptyError_ShouldReturnDefaultErrorDescription() {
            // Given
            let underlyingError = createTestError(description: nil)
            sut = .saveFailed(underlyingError)
            
            // When
            let description = sut.errorDescription
            
            // Then
            XCTAssertNotNil(description)
            XCTAssertTrue(description!.contains("TestDomain error 1"))
        }
        
        // MARK: - Helper Methods
        
        private func verifyErrorDescription(for error: HealthKitError, expectedDescription: String) {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
        
        private func createTestError(description: String?) -> NSError {
            return NSError(
                domain: "TestDomain",
                code: 1,
                userInfo: description != nil ? [NSLocalizedDescriptionKey: description!] : [:]
            )
        }
    }
