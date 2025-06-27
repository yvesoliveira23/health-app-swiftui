import SwiftUI
import Charts

struct WeightBarChartView: View {
    let weightEntries: [HealthDataPoint] // Expect HealthDataPoint array

    var body: some View {
        VStack(alignment: .leading) {
            if weightEntries.isEmpty {
                VStack {
                    Spacer()
                    Text("No weight data available to display.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                .frame(minHeight: 200) // Ensure empty state has some visible height
            } else {
                Text("Weight Readings") // More descriptive title within the view
                    .font(.headline)
                    .padding(.bottom, 5)

                Chart(weightEntries) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight (\(entry.unit))", entry.value) // Y-axis label includes unit
                    )
                    .foregroundStyle(.orange) // Consistent color for weight
                    .annotation(position: .top) {
                        Text(String(format: "%.1f", entry.value))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel() // Automatically determines appropriate labels
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.gray.opacity(0.05))
                        .border(Color.gray.opacity(0.2))
                }
                .padding()
            }
        }
        .navigationTitle("Weight History (Bar)")
        .padding(.vertical)
    }
}

struct WeightBarChartView_Previews: PreviewProvider {
    static func previewWeightData(days: Int) -> [HealthDataPoint] {
        let calendar = Calendar.current
        var data: [HealthDataPoint] = []
        let baseWeight = 70.0
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            // Simulate some weight fluctuation
            let weight = baseWeight + Double.random(in: -1.5...1.5)
            data.append(HealthDataPoint(date: date, value: weight, unit: "kg"))
        }
        return data.sorted(by: { $0.date < $1.date }) // Ensure data is sorted by date
    }

    static var previews: some View {
        Group {
            NavigationView {
                WeightBarChartView(weightEntries: previewWeightData(days: 7))
            }
            .previewDisplayName("7 Days Weight Data")

            NavigationView {
                WeightBarChartView(weightEntries: previewWeightData(days: 30))
            }
            .previewDisplayName("30 Days Weight Data")

            NavigationView {
                WeightBarChartView(weightEntries: [])
            }
            .previewDisplayName("Empty Weight Data")
        }
    }
}