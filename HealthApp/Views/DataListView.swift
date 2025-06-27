import SwiftUI

struct DataListView: View {
    @ObservedObject var viewModel: HealthDataViewModel

    var body: some View {
        List {
            Section(header: Text("Step Counts").font(.title2).padding(.vertical)) {
                if viewModel.stepData.isEmpty {
                    Text("No step data available.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.stepData.sorted(by: { $0.date > $1.date })) { dataPoint in
                        HStack {
                            Text(dataPoint.date, style: .date)
                            Spacer()
                            Text("\(Int(dataPoint.value)) \(dataPoint.unit)")
                        }
                    }
                }
            }

            Section(header: Text("Weight Records").font(.title2).padding(.vertical)) {
                if viewModel.weightData.isEmpty {
                    Text("No weight data available.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.weightData.sorted(by: { $0.date > $1.date })) { dataPoint in
                        HStack {
                            Text(dataPoint.date, style: .date)
                            Spacer()
                            Text(String(format: "%.1f %@", dataPoint.value, dataPoint.unit))
                        }
                    }
                }
            }
        }
        .navigationTitle("All Health Data")
        // .onAppear {} // Data should be loaded by DashboardView or via pull-to-refresh if implemented
    }

    // DateFormatter is no longer needed here as Text(date, style: .date) is used.
}

struct DataListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = HealthDataViewModel()
        // Populate with some mock data for preview
        mockViewModel.stepData = [
            HealthDataPoint(date: Date().addingTimeInterval(-86400*2), value: 5234, unit: "steps"),
            HealthDataPoint(date: Date().addingTimeInterval(-86400), value: 7012, unit: "steps"),
            HealthDataPoint(date: Date(), value: 1203, unit: "steps")
        ]
        mockViewModel.weightData = [
            HealthDataPoint(date: Date().addingTimeInterval(-86400*7), value: 70.5, unit: "kg"),
            HealthDataPoint(date: Date().addingTimeInterval(-86400*1), value: 70.1, unit: "kg")
        ]

        return NavigationView { // For preview context
            DataListView(viewModel: mockViewModel)
        }
    }
}