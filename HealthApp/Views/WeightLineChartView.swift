import SwiftUI
import Charts

struct WeightLineChartView: View {
    let weightEntries: [HealthDataPoint] // Expect HealthDataPoint array

    private var yDomain: ClosedRange<Double> {
        if weightEntries.isEmpty {
            return 0...100 // Default domain for an empty chart
        }
        let values = weightEntries.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 100
        // Add some padding to the domain
        return (minValue - (maxValue - minValue)*0.1)...(maxValue + (maxValue - minValue)*0.1)
    }

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
                .frame(minHeight: 200)
            } else {
                Text("Weight Trend")
                    .font(.headline)
                    .padding(.bottom, 5)

                Chart(weightEntries) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight (\(entry.unit))", entry.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.orange) // Consistent color for weight
                    .symbol(Circle().strokeBorder(lineWidth: 2)) // Add symbols at data points


                    // Optionally add PointMarks for better visibility of individual points
                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight (\(entry.unit))", entry.value)
                    )
                    .foregroundStyle(.orange)
                    .annotation(position: .top, alignment: .center) {
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
                    AxisMarks { value in // Let the chart determine optimal Y-axis values based on domain
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: yDomain) // Apply the calculated or default domain
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.gray.opacity(0.05))
                        .border(Color.gray.opacity(0.2))
                }
                .padding()
            }
        }
        .navigationTitle("Weight History (Line)")
        .padding(.vertical)
    }
}

struct WeightLineChartView_Previews: PreviewProvider {
    static func previewWeightData(days: Int, includeFluctuations: Bool = true) -> [HealthDataPoint] {
        let calendar = Calendar.current
        var data: [HealthDataPoint] = []
        let baseWeight = 70.0
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            var weight = baseWeight
            if includeFluctuations {
                weight += Double.random(in: -1.5...1.5)
            } else { // For a smoother line preview
                 weight += sin(Double(i) / Double(days) * Double.pi * 2) * 2.0 // Gentle sine wave
            }
            data.append(HealthDataPoint(date: date, value: weight, unit: "kg"))
        }
        return data.sorted(by: { $0.date < $1.date }) // Ensure data is sorted by date
    }

    static var previews: some View {
        Group {
            NavigationView {
                WeightLineChartView(weightEntries: previewWeightData(days: 7))
            }
            .previewDisplayName("7 Days Data (Fluctuations)")

            NavigationView {
                WeightLineChartView(weightEntries: previewWeightData(days: 30, includeFluctuations: false))
            }
            .previewDisplayName("30 Days Data (Smoother)")

            NavigationView {
                WeightLineChartView(weightEntries: [])
            }
            .previewDisplayName("Empty Data")
        }
    }
}