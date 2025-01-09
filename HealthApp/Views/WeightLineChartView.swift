import SwiftUI
import Charts

struct WeightLineChartView: View {
    @Binding var weightData: [Double]
    @Binding var dates: [Date]

    var body: some View {
        LineChart(data: weightData, dates: dates)
            .padding()
            .navigationTitle("Weight Over Time")
    }
}

struct LineChart: View {
    var data: [Double]
    var dates: [Date]

    var body: some View {
        Chart {
            ForEach(Array(zip(dates, data)), id: \.0) { date, weight in
                LineMark(
                    x: .value("Date", date),
                    y: .value("Weight", weight)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) { value in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYScale(domain: 0...data.max()!)
    }
}