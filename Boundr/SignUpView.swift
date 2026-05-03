import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var firstName       = ""
    @State private var lastName        = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var isLoading       = false
    @State private var errorMessage: String?
    @State private var showSignIn      = false

    private let brandBlue = Color(red: 0.28, green: 0.40, blue: 0.92)

    // MARK: - Password rules

    private var hasMinLength:  Bool { password.count >= 8 }
    private var hasUppercase:  Bool { password.contains(where: { $0.isUppercase }) }
    private var hasLowercase:  Bool { password.contains(where: { $0.isLowercase }) }
    private var hasNumber:     Bool { password.contains(where: { $0.isNumber }) }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && password == confirmPassword }

    private var passwordValid: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber
    }

    private var formValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        passwordValid &&
        passwordsMatch
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Text("Create account")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .padding(.top, 16)

                Text("Fill in your details to get started.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .padding(.top, 6).padding(.bottom, 36)

                // Fields
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        authField(icon: "person", placeholder: "First name", text: $firstName)
                        authField(icon: "person", placeholder: "Last name",  text: $lastName)
                    }

                    authField(icon: "envelope", placeholder: "Email", text: $email,
                              keyboard: .emailAddress, contentType: .emailAddress)

                    authField(icon: "lock", placeholder: "Password",
                              text: $password, isSecure: true, contentType: .newPassword)

                    // Password requirements (2×2 grid)
                    if !password.isEmpty {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), alignment: .leading),
                                      GridItem(.flexible(), alignment: .leading)],
                            alignment: .leading, spacing: 8
                        ) {
                            requirementRow("8+ characters",      met: hasMinLength)
                            requirementRow("1 uppercase letter", met: hasUppercase)
                            requirementRow("1 lowercase letter", met: hasLowercase)
                            requirementRow("1 number",           met: hasNumber)
                        }
                        .padding(.top, 2)
                        .transition(.opacity)
                    }

                    authField(icon: "lock", placeholder: "Confirm password",
                              text: $confirmPassword, isSecure: true, contentType: .newPassword)

                    // Passwords match indicator
                    if !confirmPassword.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passwordsMatch ? .green : .red)
                                .font(.caption)
                            Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                .font(.caption)
                                .foregroundColor(passwordsMatch ? .green : .red)
                            Spacer()
                        }
                        .padding(.top, 2)
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: password.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: confirmPassword.isEmpty)

                // Error
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption).foregroundColor(.red)
                        .padding(.top, 12)
                }

                // Create button
                Button {
                    Task { await signUp() }
                } label: {
                    ZStack {
                        Text("Create account")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.white)
                            .opacity(isLoading ? 0 : 1)
                        if isLoading { ProgressView().tint(.white) }
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
                SignInWithAppleButton(.signUp) { request in
                    auth.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await handleApple(result) }
                }
                .frame(height: 54)
                .cornerRadius(14)
                .signInWithAppleButtonStyle(.black)

                // Footer
                HStack(spacing: 4) {
                    Text("Already have an account?").foregroundColor(.secondary)
                    Button("Sign in") { showSignIn = true }
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
        .navigationDestination(isPresented: $showSignIn) { SignInView() }
    }

    // MARK: - Logic

    private func signUp() async {
        isLoading = true
        errorMessage = nil
        let fullName = "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"
        do {
            try await auth.signUp(name: fullName,
                                  email: email.trimmingCharacters(in: .whitespaces),
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

    private func requirementRow(_ label: String, met: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(met ? .green : Color(.systemGray3))
            Text(label)
                .font(.caption)
                .foregroundColor(met ? .primary : .secondary)
        }
    }

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
                    .autocapitalization(keyboard == .emailAddress ? .none : .words)
                    .autocorrectionDisabled(keyboard == .emailAddress)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
    }
}
