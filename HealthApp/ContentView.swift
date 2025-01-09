import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            DashboardView()
                .navigationTitle("Health Dashboard")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}