import SwiftUI

struct ContentView: View {
    // Initialize HealthDataViewModel as a @StateObject here.
    // This ensures the ViewModel's lifecycle is tied to ContentView,
    // and it will be persisted across view updates.
    @StateObject private var viewModel = HealthDataViewModel()

    var body: some View {
        NavigationView {
            // Pass the viewModel to DashboardView.
            // DashboardView will use @ObservedObject to observe it.
            DashboardView(viewModel: viewModel)
            // The navigationTitle should be set on the content view (DashboardView)
            // rather than on the NavigationView container directly for more conventional behavior.
            // However, setting it here is also common if DashboardView is the primary view.
            // Let's move it to DashboardView for better encapsulation.
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a mock or preview-specific ViewModel if needed for complex previews.
        ContentView()
    }
}