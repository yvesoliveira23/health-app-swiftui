import Foundation

/// Represents errors that can occur during HealthKit operations
///
/// This enumeration provides specific error cases for common HealthKit-related failures
/// and implements `LocalizedError` to provide user-friendly error messages.
enum HealthKitError: LocalizedError {
    /// The requested HealthKit data type is not supported on this device
    case typeNotAvailable
    
    /// The app lacks required HealthKit permissions
    case unauthorized
    
    /// A HealthKit data fetch operation failed
    /// - Parameter error: Optional underlying system error
    case fetchFailed(Error?)
    
    /// A HealthKit data save operation failed
    /// - Parameter error: Optional underlying system error
    case saveFailed(Error?)
    
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .typeNotAvailable:
            return "HealthKit type not available"
        case .unauthorized:
            return "HealthKit access not authorized"
        case .fetchFailed(let error):
            return "Failed to fetch HealthKit data: \(error?.localizedDescription ?? "Unknown error")"
        case .saveFailed(let error):
            return "Failed to save HealthKit data: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
}
        