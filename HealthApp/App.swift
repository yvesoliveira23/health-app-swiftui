import SwiftUI

@main
struct HealthApp: App {
    // Initialize the HealthDataViewModel as a StateObject here if ContentView
    // is the root view that needs it, or if multiple scenes might share it.
    // For a simple single-scene app, initializing in ContentView is also fine.
    // Let's keep it in ContentView for now as per typical SwiftUI single view setup.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}