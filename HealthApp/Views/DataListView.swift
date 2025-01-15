import SwiftUI

struct DataListView: View {
    @StateObject var viewModel = HealthDataViewModel()

    var body: some View {
        List(viewModel.healthDataEntries) { entry in
            HStack {
                Text(entry.date, formatter: dateFormatter)
                Spacer()
                Text("\(entry.steps) steps")
                Spacer()
                Text("\(entry.weight, specifier: "%.1f") kg")
            }
        }
        .navigationTitle("Health Data")
        .onAppear {
            viewModel.fetchHealthData()
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}