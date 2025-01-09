import Foundation
import HealthKit
import Combine

class HealthDataViewModel: ObservableObject {
    @Published var steps: [Int] = []
    @Published var weights: [Double] = []
    private var healthStore = HKHealthStore()
    
    init() {
        requestAuthorization()
        fetchHealthData()
    }
    
    private func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        
        let typesToShare: Set = [weightType]
        let typesToRead: Set = [stepType, weightType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if !success {
                // Handle error
            }
        }
    }
    
    private func fetchHealthData() {
        fetchSteps()
        fetchWeights()
    }
    
    private func fetchSteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let query = HKSampleQuery(sampleType: stepType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let results = results as? [HKQuantitySample] else { return }
            self.steps = results.map { Int($0.quantity.doubleValue(for: HKUnit.count())) }
        }
        healthStore.execute(query)
    }
    
    private func fetchWeights() {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let results = results as? [HKQuantitySample] else { return }
            self.weights = results.map { $0.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)) }
        }
        healthStore.execute(query)
    }
    
    func writeStepData(steps: Int, completion: @escaping (Bool, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(false, nil)
            return
        }
        
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: Double(steps))
        let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: Date(), end: Date())
        
        healthStore.save(stepSample) { success, error in
            completion(success, error)
        }
    }
    
    func writeWeightData(weight: Double, completion: @escaping (Bool, Error?) -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(false, nil)
            return
        }        

        let weightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: Date(), end: Date())
        
        healthStore.save(weightSample) { success, error in
            completion(success, error)
        }
    }
}