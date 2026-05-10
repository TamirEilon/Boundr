import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct BoundrApp: App {
    @StateObject private var store = VisaStore()
    @StateObject private var auth  = AuthManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if store.isLoading {
                    ZStack {
                        Color(.systemBackground).ignoresSafeArea()
                        VStack(spacing: 16) {
                            Image("BoundrLogo")
                                .resizable().scaledToFit()
                                .frame(width: 64, height: 64)
                                .cornerRadius(16)
                            ProgressView()
                                .scaleEffect(1.2)
                        }
                    }
                } else if auth.isSignedIn {
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
            .onAppear {
                if let uid = auth.currentUser?.uid {
                    store.loadProfile(for: uid)
                    if let name = auth.currentUser?.displayName, !name.isEmpty {
                        store.user.fullName = name
                    }
                }
            }
            .onChange(of: auth.currentUser?.uid) { _, uid in
                guard let uid else { return }
                store.loadProfile(for: uid)
                if let name = auth.currentUser?.displayName, !name.isEmpty {
                    store.user.fullName = name
                }
            }
        }
    }
}
