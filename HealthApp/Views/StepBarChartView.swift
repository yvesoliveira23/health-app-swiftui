import SwiftUI
import Charts

struct StepBarChartView: View {
    var stepsData: [(date: Date, steps: Int)] // Expect pre-processed data

    // Group data by a larger unit (e.g., week or month) if many days are present
    // For simplicity, this example assumes a reasonable number of days for daily bars.
    // Consider aggregation for longer periods in a real app.

    var body: some View {
        VStack(alignment: .leading) {
            if stepsData.isEmpty {
                VStack {
                    Spacer()
                    Text("No step data available to display.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            } else {
                Chart(stepsData, id: \.date) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Steps", dataPoint.steps)
                    )
                    .foregroundStyle(by: .value("Date", dataPoint.date.formatted(.dateTime.weekday(.wide)))) // Example: color by weekday
                    .annotation(position: .top, alignment: .center) {
                        if dataPoint.steps > 0 { // Only show annotation if steps > 0
                            Text("\(dataPoint.steps)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .chartXAxis {
                    // Show fewer labels if there's a lot of data to avoid clutter
                    // This depends on the expected date range. For a week, daily is fine.
                    AxisMarks(values: .stride(by: .day, count: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in // Default Y-axis marks
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.gray.opacity(0.05))
                        .border(Color.gray.opacity(0.2))
                }
                .padding()
                // Add a legend if .foregroundStyle(by:) is used meaningfully
                // .chartLegend(position: .top, alignment: .trailing)
            }
        }
        .navigationTitle("Daily Steps") // Appropriate if this view is pushed into navigation
        .padding(.vertical)
    }
}

struct StepBarChartView_Previews: PreviewProvider {
    static func previewData(days: Int) -> [(Date, Int)] {
        let calendar = Calendar.current
        return (0..<days).map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let steps = Int.random(in: 2000...15000)
            return (date, steps)
        }.sorted(by: { $0.0 < $1.0 }) // Ensure data is sorted by date for the chart
    }

    static var previews: some View {
        Group {
            NavigationView {
                StepBarChartView(stepsData: previewData(days: 7))
            }
            .previewDisplayName("7 Days Data")

            NavigationView {
                StepBarChartView(stepsData: previewData(days: 30))
            }
            .previewDisplayName("30 Days Data (Needs X-axis adjustment for many days)")

            NavigationView {
                StepBarChartView(stepsData: [])
            }
            .previewDisplayName("Empty Data")
        }
    }
}