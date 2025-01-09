import SwiftUI
import Charts

struct StepBarChartView: View {
    var stepsData: [(date: Date, steps: Int)]

    var body: some View {
        VStack {
            Text("Steps Over Time")
                .font(.headline)
                .padding()
            
            Chart(stepsData, id: \.date) { dataPoint in
                BarMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Steps", dataPoint.steps)
                )
                .foregroundStyle(.blue)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.month().day())
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

struct StepBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        StepBarChartView(stepsData: [
            (date: Date(), steps: 5000),
            (date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, steps: 7000),
            (date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, steps: 8000)
        ])
    }
}