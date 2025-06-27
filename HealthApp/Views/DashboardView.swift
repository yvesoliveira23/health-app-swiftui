import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: HealthDataViewModel
    @State private var showingErrorAlert = false

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading && viewModel.stepData.isEmpty && viewModel.weightData.isEmpty {
                ProgressView("Loading Health Data...")
                    .padding()
            } else {
                // Main content
                VStack(alignment: .leading, spacing: 25) {
                    Text("Activity Summary")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)

                    MetricView(label: "Steps Today",
                               value: "\(viewModel.totalStepsToday)",
                               unit: viewModel.totalStepsToday == 1 ? "step" : "steps",
                               systemImageName: "figure.walk",
                               color: .green)

                    MetricView(label: "Latest Weight",
                               value: viewModel.latestWeightInKg != nil ? String(format: "%.1f", viewModel.latestWeightInKg!) : "N/A",
                               unit: viewModel.latestWeightInKg != nil ? (viewModel.latestWeightUnit ?? "kg") : "",
                               systemImageName: "scalemass.fill",
                               color: .orange)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                .padding(.horizontal)


                NavigationLink(destination: DataListView(viewModel: viewModel)) {
                    Text("View Detailed Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                // Potentially add links to chart views here as well
                // Example:
                // NavigationLink("View Step Chart", destination: StepBarChartView(stepsData: viewModel.stepData.map { ($0.date, Int($0.value)) }))
                // NavigationLink("View Weight Chart", destination: WeightLineChartView(weightData: viewModel.weightData.map { ($0.date, $0.value) }))


                Spacer() // Pushes content to the top
            }
        }
        .navigationTitle("Health Dashboard")
        .onAppear {
            viewModel.loadInitialDataIfNeeded()
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if newValue != nil {
                showingErrorAlert = true
            }
        }
        .alert(isPresented: $showingErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil // Clear the error message
                }
            )
        }
    }
}

// A helper view for displaying individual metrics consistently
struct MetricView: View {
    let label: String
    let value: String
    let unit: String
    let systemImageName: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title3)
                    .fontWeight(.medium)
            }

            if !unit.isEmpty {
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
            Spacer()
        }
    }
}

// Preview needs a ViewModel instance
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Add NavigationView for preview context
            DashboardView(viewModel: HealthDataViewModel())
        }
    }
}