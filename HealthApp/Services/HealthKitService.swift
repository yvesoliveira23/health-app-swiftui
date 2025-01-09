import Foundation
import HealthKit

class HealthKitService {
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(false, nil)
            return
        }

        let typesToShare: Set = [stepType, weightType]
        let typesToRead: Set = [stepType, weightType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }

    func fetchSteps(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, nil)
            return
        }

        let query = HKSampleQuery(sampleType: stepType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            completion(results as? [HKQuantitySample], error)
        }

        healthStore.execute(query)
    }

    func fetchWeight(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil, nil)
            return
        }

        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            completion(results as? [HKQuantitySample], error)
        }

        healthStore.execute(query)
    }

    func saveSteps(steps: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, nil)
            return
        }

        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
        let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: date, end: date)

        healthStore.save(stepSample) { success, error in
            completion(success, error)
        }
    }

    func saveWeight(weight: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            completion(false, nil)
            return
        }

        let weightQuantity = HKQuantity(unit: HKUnit.pound(), doubleValue: weight)
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: date, end: date)

        healthStore.save(weightSample) { success, error in
            completion(success, error)
        }
    }
}