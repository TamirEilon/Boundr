import SwiftUI

@main
struct BoundrApp: App {
    @StateObject private var store = VisaStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
