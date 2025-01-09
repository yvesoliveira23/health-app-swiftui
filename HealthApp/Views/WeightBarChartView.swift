import SwiftUI
import Charts

struct WeightBarChartView: View {
    @Binding var weightData: [Double]
    @Binding var dates: [Date]

    var body: some View {
        VStack {
            Text("Weight Over Time")
                .font(.headline)
                .padding()

            Chart {
                ForEach(Array(zip(dates, weightData)), id: \.0) { date, weight in
                    BarMark(
                        x: .value("Date", date, unit: .day),
                        y: .value("Weight", weight)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                }
            }
            .padding()
        }
    }
}