import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var email    = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let brandBlue = Color(red: 0.28, green: 0.40, blue: 0.92)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Text("Welcome back")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .padding(.top, 16)

                Text("Sign in to your Boundr account.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .padding(.top, 6).padding(.bottom, 36)

                // Fields
                VStack(spacing: 14) {
                    authField(icon: "envelope", placeholder: "Email", text: $email,
                              keyboard: .emailAddress, contentType: .emailAddress)
                    authField(icon: "lock", placeholder: "Password", text: $password,
                              isSecure: true, contentType: .password)
                }

                // Error
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption).foregroundColor(.red)
                        .padding(.top, 12)
                }

                // Sign in button
                Button {
                    Task { await signIn() }
                } label: {
                    ZStack {
                        Text("Sign in")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.white)
                            .opacity(isLoading ? 0 : 1)
                        if isLoading {
                            ProgressView().tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(formValid ? brandBlue : Color(.systemGray4))
                    .cornerRadius(16)
                }
                .disabled(!formValid || isLoading)
                .padding(.top, 28)

                divider.padding(.vertical, 24)

                // Apple
                SignInWithAppleButton(.signIn) { request in
                    auth.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await handleApple(result) }
                }
                .frame(height: 54)
                .cornerRadius(14)
                .signInWithAppleButtonStyle(.black)

                // Footer
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign up") { dismiss() }
                        .fontWeight(.semibold).foregroundColor(brandBlue)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 28)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
        }
    }

    // MARK: - Logic

    private var formValid: Bool {
        email.contains("@") && password.count >= 6
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await auth.signIn(email: email.trimmingCharacters(in: .whitespaces),
                                  password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        do {
            try await auth.handleAppleCompletion(result)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Subviews

    private var divider: some View {
        HStack {
            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
            Text("or").font(.caption).foregroundColor(.secondary).padding(.horizontal, 8)
            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
        }
    }

    private func authField(icon: String,
                           placeholder: String,
                           text: Binding<String>,
                           keyboard: UIKeyboardType = .default,
                           isSecure: Bool = false,
                           contentType: UITextContentType? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.subheadline)
                    .textContentType(contentType)
            } else {
                TextField(placeholder, text: text)
                    .font(.subheadline)
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
    }
}
