import SwiftUI
import Charts

struct StepPieChartView: View {
    var stepsData: [String: Int] // Dictionary to hold step data categorized by day

    var body: some View {
        VStack {
            Text("Steps Distribution")
                .font(.headline)
                .padding()

            PieChart(stepsData: stepsData)
                .frame(height: 300)
                .padding()
        }
    }
}

struct PieChart: View {
    var stepsData: [String: Int]

    var body: some View {
        Chart {
            ForEach(stepsData.sorted(by: { $0.value > $1.value }), id: \.key) { day, steps in
                Sector(data: steps, label: day)
            }
        }
        .chartStyle(ChartStyle())
    }
}

struct ChartStyle: ChartStyle {
    var backgroundColor: Color = Color.white
    var foregroundColor: Color = Color.blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
    }
}

struct StepPieChartView_Previews: PreviewProvider {
    static var previews: some View {
        StepPieChartView(stepsData: ["Monday": 3000, "Tuesday": 5000, "Wednesday": 7000])
    }
}