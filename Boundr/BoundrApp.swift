import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct BoundrApp: App {
    @StateObject private var store = VisaStore()
    @StateObject private var auth  = AuthManager()
    @State private var animationSettled = false

    init() {
        FirebaseApp.configure()
        NotificationManager.shared.setup()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if store.isLoading || !animationSettled {
                    SplashView(onSettled: { animationSettled = true })
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
            .preferredColorScheme(.light)
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
                guard let uid else {
                    store.reset()
                    return
                }
                store.loadProfile(for: uid)
                if let name = auth.currentUser?.displayName, !name.isEmpty {
                    store.user.fullName = name
                }
            }
            // Request permission once onboarding is complete, then keep schedule fresh
            .onChange(of: auth.onboardingComplete) { _, complete in
                guard complete else { return }
                Task {
                    await NotificationManager.shared.requestPermission()
                    await NotificationManager.shared.scheduleAll(topMatch: store.topMatch)
                }
            }
            // Reschedule whenever top match updates (visas loaded from Firebase)
            .onChange(of: store.topMatch?.id) { _, _ in
                guard auth.onboardingComplete else { return }
                Task {
                    await NotificationManager.shared.scheduleAll(topMatch: store.topMatch)
                }
            }
        }
    }
}
