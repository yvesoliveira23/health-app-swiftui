import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: HealthDataViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Health Dashboard")
                    .font(.largeTitle)
                    .padding()

                // Display health metrics here
                HStack {
                    // Placeholder for step count
                    Text("Steps: \(viewModel.totalSteps)")
                    Spacer()
                    // Placeholder for weight
                    Text("Weight: \(viewModel.averageWeight, specifier: "%.1f") kg")
                }
                .padding()

                // Navigation to other views
                NavigationLink(destination: DataListView(viewModel: viewModel)) {
                    Text("View Data List")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Add more navigation links as needed
            }
            .navigationTitle("Dashboard")
        }
    }
}