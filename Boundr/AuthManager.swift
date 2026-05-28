import Foundation
import Combine
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class AuthManager: ObservableObject {
    @Published var currentUser: FirebaseAuth.User? = nil
    @Published var onboardingComplete: Bool = false

    private var stateHandle: AuthStateDidChangeListenerHandle?
    private(set) var currentNonce: String?

    init() {
        stateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                if let uid = user?.uid {
                    self?.onboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_\(uid)")
                } else {
                    self?.onboardingComplete = false
                }
            }
        }
    }

    func completeOnboarding() {
        guard let uid = currentUser?.uid else { return }
        UserDefaults.standard.set(true, forKey: "onboarding_\(uid)")
        onboardingComplete = true
    }

    deinit {
        if let stateHandle { Auth.auth().removeStateDidChangeListener(stateHandle) }
    }

    var isSignedIn: Bool { currentUser != nil }

    // MARK: - Email / Password

    func signUp(name: String, email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let request = result.user.createProfileChangeRequest()
        request.displayName = name
        try await request.commitChanges()
        DispatchQueue.main.async {
            self.currentUser = Auth.auth().currentUser
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Sign in with Apple

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let raw = randomNonceString()
        currentNonce = raw
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(raw)
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        let auth = try result.get()
        guard
            let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = appleCredential.identityToken,
            let token = String(data: tokenData, encoding: .utf8)
        else { throw AppleAuthError.missingToken }

        let credential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )
        let authResult = try await Auth.auth().signIn(with: credential)

        // Apple only sends the name on the very first sign-in — save it immediately
        if let fullName = appleCredential.fullName {
            let given  = fullName.givenName  ?? ""
            let family = fullName.familyName ?? ""
            let name   = [given, family].filter { !$0.isEmpty }.joined(separator: " ")
            if !name.isEmpty {
                let request = authResult.user.createProfileChangeRequest()
                request.displayName = name
                try await request.commitChanges()
            }
        }
        DispatchQueue.main.async {
            self.currentUser = Auth.auth().currentUser
        }
    }

    // MARK: - Helpers

    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var bytes = [UInt8](repeating: 0, count: 16)
            SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            bytes.forEach { byte in
                guard remaining > 0, byte < charset.count else { return }
                result.append(charset[Int(byte)])
                remaining -= 1
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }

    enum AppleAuthError: LocalizedError {
        case missingToken
        var errorDescription: String? { "Apple Sign In failed. Please try again." }
    }
}
