import Foundation
import HealthKit
import Combine

/// Represents a single data point for a health metric (e.g., steps, weight), suitable for UI display and charting.
struct HealthDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
    let unit: String // e.g., "steps", "kg"
}

class HealthDataViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var stepData: [HealthDataPoint] = []
    @Published var weightData: [HealthDataPoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil // For displaying user-facing error messages

    // MARK: - Computed Properties for Dashboard
    
    /// Calculates total steps for today from the `stepData` array.
    var totalStepsToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return stepData
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + Int($1.value) }
    }

    /// Provides the latest recorded weight value in kilograms.
    var latestWeightInKg: Double? {
        weightData
            .sorted(by: { $0.date > $1.date })
            .first?
            .value
    }
    
    /// Provides the unit for the latest weight, typically "kg".
    var latestWeightUnit: String? {
        weightData
            .sorted(by: { $0.date > $1.date })
            .first?
            .unit
    }

    // MARK: - Private Properties
    private let healthKitService: HealthKitService
    private var cancellables = Set<AnyCancellable>() // For future Combine pipelines if needed

    // MARK: - Initialization
    init(healthKitService: HealthKitService = HealthKitService()) {
        self.healthKitService = healthKitService
        // Authorization and initial data fetch are now typically triggered by a UI action,
        // such as a View's .onAppear modifier calling `loadInitialDataIfNeeded`.
    }

    // MARK: - Public Methods

    /// Requests HealthKit authorization if not already determined, then fetches initial data.
    /// This method ensures that authorization is requested only once unless status is undetermined.
    func loadInitialDataIfNeeded() {
        let status = HKHealthStore().authorizationStatus(for: HealthKitService.stepCountType) // Check for one type is enough
        
        switch status {
        case .notDetermined:
            isLoading = true
            errorMessage = nil
            healthKitService.requestAuthorization { [weak self] success, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if success {
                        self.fetchAllHealthData()
                    } else {
                        self.errorMessage = error?.localizedDescription ?? "HealthKit authorization was denied."
                        self.isLoading = false
                    }
                }
            }
        case .sharingAuthorized:
            // If already authorized, just fetch data.
            // Check if data is already loaded to prevent redundant fetches if called multiple times.
            if stepData.isEmpty && weightData.isEmpty {
                 fetchAllHealthData()
            }
        case .sharingDenied:
            DispatchQueue.main.async {
                self.errorMessage = "HealthKit access was previously denied. Please enable it in Settings."
                self.isLoading = false
            }
        @unknown default:
            DispatchQueue.main.async {
                self.errorMessage = "Unknown HealthKit authorization status."
                self.isLoading = false
            }
        }
    }
    
    /// Fetches both step and weight data from HealthKit.
    /// This is typically called after successful authorization.
    func fetchAllHealthData() {
        isLoading = true
        errorMessage = nil // Clear previous errors

        let group = DispatchGroup()
        var encounteredError: Error? = nil

        group.enter()
        healthKitService.fetchSteps { [weak self] samples, error in
            defer { group.leave() }
            guard let self = self else { return }
            if let error = error {
                encounteredError = error
                return
            }
            if let samples = samples {
                DispatchQueue.main.async {
                    self.stepData = samples.map { sample in
                        HealthDataPoint(date: sample.startDate,
                                        value: sample.quantity.doubleValue(for: .count()),
                                        unit: "steps")
                    }
                }
            }
        }

        group.enter()
        healthKitService.fetchWeight { [weak self] samples, error in
            defer { group.leave() }
            guard let self = self else { return }
            if let error = error {
                encounteredError = error
                return
            }
            if let samples = samples {
                DispatchQueue.main.async {
                    // Assuming HealthKitService.fetchWeight returns samples that can be directly converted to kilograms.
                    // The HKUnit for weight samples from HealthKit can vary based on user's locale or how data was entered.
                    // It's robust to always ask for a specific unit (e.g., .gramUnit(with: .kilo)) when creating the HKQuantitySample.
                    // The HealthKitService.fetchWeight doesn't currently specify units, so we assume values are in user's preferred unit
                    // and convert to KG here. For display consistency, it's better if HealthKitService provided data in KG.
                    // For now, we request .gramUnit(with: .kilo) for consistency.
                    self.weightData = samples.map { sample in
                        HealthDataPoint(date: sample.startDate,
                                        value: sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)),
                                        unit: "kg")
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            if let error = encounteredError {
                self.errorMessage = "Error fetching health data: \(error.localizedDescription)"
            }
        }
    }
    
    /// Refreshes step data from HealthKit.
    func refreshStepData() {
        isLoading = true
        healthKitService.fetchSteps { [weak self] samples, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error refreshing steps: \(error.localizedDescription)"
                    return
                }
                if let samples = samples {
                    self.stepData = samples.map { sample in
                        HealthDataPoint(date: sample.startDate,
                                        value: sample.quantity.doubleValue(for: .count()),
                                        unit: "steps")
                    }
                }
            }
        }
    }

    /// Refreshes weight data from HealthKit. Data is converted to kilograms.
    func refreshWeightData() {
        isLoading = true
        healthKitService.fetchWeight { [weak self] samples, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error refreshing weight: \(error.localizedDescription)"
                    return
                }
                if let samples = samples {
                    self.weightData = samples.map { sample in
                        HealthDataPoint(date: sample.startDate,
                                        value: sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)),
                                        unit: "kg")
                    }
                }
            }
        }
    }

    /// Writes step data to HealthKit.
    /// - Parameters:
    ///   - steps: The number of steps (integer) to write.
    ///   - date: The date for the step entry.
    ///   - completion: Optional closure called on completion with success status and any error.
    func writeStepData(steps: Int, date: Date, completion: ((Bool, Error?) -> Void)? = nil) {
        healthKitService.saveSteps(steps: Double(steps), date: date) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.refreshStepData() // Refresh data on successful save
                } else if let error = error {
                    self?.errorMessage = "Error saving steps: \(error.localizedDescription)"
                }
                completion?(success, error)
            }
        }
    }

    /// Writes weight data to HealthKit.
    /// Assumes input weight is in kilograms; converts to pounds for saving via `HealthKitService` (as per service's current implementation).
    /// - Parameters:
    ///   - weightInKg: The weight in kilograms to write.
    ///   - date: The date for the weight entry.
    ///   - completion: Optional closure called on completion with success status and any error.
    func writeWeightData(weightInKg: Double, date: Date, completion: ((Bool, Error?) -> Void)? = nil) {
        let weightInPounds = weightInKg * 2.20462262185 // kg to lbs conversion factor
        healthKitService.saveWeight(weightInPounds: weightInPounds, date: date) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.refreshWeightData() // Refresh data on successful save
                } else if let error = error {
                    self?.errorMessage = "Error saving weight: \(error.localizedDescription)"
                }
                completion?(success, error)
            }
        }
    }
}