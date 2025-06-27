import SwiftUI
import Charts

// Define a structure for the data points the pie chart will consume
struct PieChartDataPoint: Identifiable {
    let id = UUID()
    var name: String // e.g., "Day of Week", "Category"
    var value: Double
    var color: Color = .gray // Default color, can be customized
}

struct StepPieChartView: View {
    var chartTitle: String = "Steps Distribution"
    var dataPoints: [PieChartDataPoint]

    var body: some View {
        VStack(alignment: .leading) {
            if dataPoints.isEmpty {
                VStack {
                    Spacer()
                    Text("No data available for \(chartTitle).")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(height: 300) // Give some frame for empty state
            } else {
                Text(chartTitle)
                    .font(.headline)
                    .padding(.bottom, 5)

                Chart(dataPoints) { dataPoint in
                    SectorMark(
                        angle: .value("Steps", dataPoint.value),
                        innerRadius: .ratio(0.618), // Example: Donut chart
                        angularInset: 1.5 // Adds a little space between sectors
                    )
                    .foregroundStyle(dataPoint.color)
                    .cornerRadius(5)
                    .annotation(position: .overlay) {
                        // Avoid cluttering if too many small segments
                        if dataPoint.value / dataPoints.reduce(0, { $0 + $1.value }) > 0.05 { // Show label for segments > 5%
                            Text("\(dataPoint.name)\n\(Int(dataPoint.value))")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white) // Adjust color for readability based on sector color
                                .bold()
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .center, spacing: 10) {
                     // Custom legend if needed, or rely on automatic if .foregroundStyle(by:) is used.
                     // For this example, we use explicit colors in PieChartDataPoint.
                     // A more dynamic legend could be built here.
                     HStack {
                         ForEach(dataPoints) { dataPoint in
                             HStack {
                                 Rectangle().fill(dataPoint.color).frame(width: 10, height: 10)
                                 Text(dataPoint.name)
                                     .font(.caption)
                             }
                         }
                     }
                }
                .frame(height: 300) // Give the chart a decent frame
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        // .navigationTitle(chartTitle) // If used in navigation context
    }
}

struct StepPieChartView_Previews: PreviewProvider {
    static func getSampleData() -> [PieChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var sampleData: [PieChartDataPoint] = []
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow]

        for i in 0..<7 { // Last 7 days
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEE" // e.g., "Mon"
                let dayName = dayFormatter.string(from: date)
                sampleData.append(PieChartDataPoint(name: dayName, value: Double.random(in: 1000...10000), color: colors[i % colors.count]))
            }
        }
        return sampleData.sorted(by: { $0.value > $1.value }) // Example sort
    }

    static var previews: some View {
        Group {
            StepPieChartView(chartTitle: "Last 7 Days Steps", dataPoints: getSampleData())
                .previewDisplayName("With Data")

            StepPieChartView(chartTitle: "Last 7 Days Steps", dataPoints: [])
                .previewDisplayName("Empty Data")

            // Example of how it might look in a list
            NavigationView {
                VStack {
                    StepPieChartView(chartTitle: "Daily Steps Mix", dataPoints: getSampleData())
                    // Other content
                    Spacer()
                }
                .navigationTitle("Activity Breakdown")
            }
            .previewDisplayName("In Navigation")
        }
    }
}