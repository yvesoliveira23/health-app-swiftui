import Foundation
import HealthKit

/// A service class to interact with HealthKit, providing methods to request authorization,
/// fetch, and save health data like steps and weight.
class HealthKitService {
    private let healthStore = HKHealthStore()

    // MARK: - Object Types

    /// The HealthKit type for step count. This will fatalError if the type is unavailable,
    /// as it's fundamental to the app's operation with steps.
    private static var stepCountType: HKQuantityType = {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("Step count type is no longer available in HealthKit.")
        }
        return type
    }()

    /// The HealthKit type for body mass (weight). This will fatalError if the type is unavailable,
    /// as it's fundamental to the app's operation with weight.
    private static var bodyMassType: HKQuantityType = {
        guard let type = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("Body mass type is no longer available in HealthKit.")
        }
        return type
    }()

    // MARK: - Authorization

    /// Requests authorization from the user to read and share specified HealthKit data types.
    /// - Parameter completion: A closure called upon completion:
    ///   - `success`: A boolean indicating if authorization was granted for all requested types.
    ///   - `error`: An optional `Error` (e.g., `HealthKitError.unauthorized` or a system error) if authorization failed.
    func requestAuthorization(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let stepType = Self.stepCountType
        let weightType = Self.bodyMassType

        // Define types to share (write) and read.
        // Assuming sharing/writing for both, as per original logic.
        // This can be refined if, e.g., step data is only read.
        let typesToShare: Set<HKSampleType> = [stepType, weightType]
        let typesToRead: Set<HKObjectType> = [stepType, weightType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error = error {
                // If there's a system error during the authorization process
                completion(false, error)
                return
            }
            if !success {
                // If authorization was explicitly denied or failed without a system error
                completion(false, HealthKitError.unauthorized)
                return
            }
            // Authorization successful for all requested types
            completion(true, nil)
        }
    }

    // MARK: - Data Fetching

    /// Fetches step count samples from HealthKit.
    /// - Parameters:
    ///   - predicate: An optional `NSPredicate` to filter the samples (e.g., by date range). Defaults to `nil` (all samples).
    ///   - sortDescriptors: An optional array of `NSSortDescriptor` to sort the samples (e.g., by date). Defaults to `nil`.
    ///   - limit: The maximum number of samples to return. Defaults to `HKObjectQueryNoLimit`.
    ///   - completion: A closure called upon completion:
    ///     - `samples`: An optional array of `HKQuantitySample` for steps.
    ///     - `error`: An optional `Error` (e.g., `HealthKitError.fetchFailed`) if the fetch fails.
    func fetchSteps(predicate: NSPredicate? = nil,
                    sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)],
                    limit: Int = HKObjectQueryNoLimit,
                    completion: @escaping (_ samples: [HKQuantitySample]?, _ error: Error?) -> Void) {
        let stepType = Self.stepCountType
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors) { _, results, error in
            if let error = error {
                completion(nil, HealthKitError.fetchFailed(error))
                return
            }
            completion(results as? [HKQuantitySample], nil)
        }
        healthStore.execute(query)
    }

    /// Fetches weight samples (body mass) from HealthKit.
    /// - Parameters:
    ///   - predicate: An optional `NSPredicate` to filter the samples. Defaults to `nil`.
    ///   - sortDescriptors: An optional array of `NSSortDescriptor` to sort the samples. Defaults to `nil`.
    ///   - limit: The maximum number of samples to return. Defaults to `HKObjectQueryNoLimit`.
    ///   - completion: A closure called upon completion:
    ///     - `samples`: An optional array of `HKQuantitySample` for weight.
    ///     - `error`: An optional `Error` (e.g., `HealthKitError.fetchFailed`) if the fetch fails.
    func fetchWeight(predicate: NSPredicate? = nil,
                     sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)],
                     limit: Int = HKObjectQueryNoLimit,
                     completion: @escaping (_ samples: [HKQuantitySample]?, _ error: Error?) -> Void) {
        let weightType = Self.bodyMassType
        let query = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors) { _, results, error in
            if let error = error {
                completion(nil, HealthKitError.fetchFailed(error))
                return
            }
            completion(results as? [HKQuantitySample], nil)
        }
        healthStore.execute(query)
    }

    // MARK: - Data Saving

    /// Saves a step count sample to HealthKit.
    /// - Parameters:
    ///   - steps: The number of steps (as a `Double`) to save.
    ///   - date: The date and time for the step sample. The start and end date of the sample will be this date.
    ///   - completion: A closure called upon completion:
    ///     - `success`: A boolean indicating if the save was successful.
    ///     - `error`: An optional `Error` (e.g., `HealthKitError.saveFailed`) if saving fails.
    func saveSteps(steps: Double, date: Date, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let stepType = Self.stepCountType
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
        let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: date, end: date)

        healthStore.save(stepSample) { success, error in
            if let error = error {
                completion(false, HealthKitError.saveFailed(error))
                return
            }
            // If 'error' is nil, 'success' reflects the outcome of the save operation.
            completion(success, nil)
        }
    }

    /// Saves a weight sample (body mass) to HealthKit.
    /// Note: This method saves weight in pounds, consistent with the original implementation.
    /// The ViewModel or calling code should handle any necessary conversions if the app's standard unit is different (e.g., kilograms).
    /// - Parameters:
    ///   - weightInPounds: The weight value in pounds.
    ///   - date: The date and time for the weight sample. The start and end date of the sample will be this date.
    ///   - completion: A closure called upon completion:
    ///     - `success`: A boolean indicating if the save was successful.
    ///     - `error`: An optional `Error` (e.g., `HealthKitError.saveFailed`) if saving fails.
    func saveWeight(weightInPounds: Double, date: Date, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let weightType = Self.bodyMassType
        let weightQuantity = HKQuantity(unit: HKUnit.pound(), doubleValue: weightInPounds) // Storing as pounds
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: date, end: date)

        healthStore.save(weightSample) { success, error in
            if let error = error {
                completion(false, HealthKitError.saveFailed(error))
                return
            }
            completion(success, nil)
        }
    }
}