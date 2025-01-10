import Foundation

enum HealthKitError: LocalizedError {
    case typeNotAvailable
    case unauthorized
    case fetchFailed(Error?)
    case saveFailed(Error?)

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
        