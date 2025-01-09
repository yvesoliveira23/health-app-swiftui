class HealthDataModel: Identifiable, Codable {
    var id: UUID
    var steps: Int
    var weight: Double
    var date: Date

    init(id: UUID = UUID(), steps: Int, weight: Double, date: Date) {
        self.id = id
        self.steps = steps
        self.weight = weight
        self.date = date
    }
}