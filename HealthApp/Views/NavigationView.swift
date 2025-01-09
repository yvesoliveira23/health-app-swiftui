import SwiftUI

struct NavigationView: View {
    var body: some View {
        NavigationView {
            DashboardView()
                .navigationTitle("Health Dashboard")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView()
    }
}