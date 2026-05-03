import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct BoundrApp: App {
    @StateObject private var store   = VisaStore()
    @StateObject private var auth    = AuthManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isSignedIn {
                    if auth.onboardingComplete {
                        ContentView()
                            .environmentObject(store)
                            .environmentObject(auth)
                    } else {
                        OnboardingView()
                            .environmentObject(store)
                            .environmentObject(auth)
                    }
                } else {
                    WelcomeView()
                        .environmentObject(auth)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: auth.isSignedIn)
            .animation(.easeInOut(duration: 0.3), value: auth.onboardingComplete)
            .onChange(of: auth.currentUser?.uid) { _, _ in
                if let name = auth.currentUser?.displayName, !name.isEmpty {
                    store.user.fullName = name
                }
            }
        }
    }
}
