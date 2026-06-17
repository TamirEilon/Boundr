import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var email        = ""
    @State private var password     = ""
    @State private var showPassword = false
    @State private var rememberMe   = false
    @State private var isLoading    = false
    @State private var errorMessage: String?
    @State private var showSignUp   = false

    private let brandBlue = Color(red: 38/255, green: 99/255, blue: 235/255)

    private var formValid: Bool {
        email.contains("@") && password.count >= 6
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Title
                (Text("Welcome ")
                    .font(Font.custom("InstrumentSerif-Regular", size: 42))
                 + Text("back")
                    .font(Font.custom("InstrumentSerif-Italic", size: 42))
                    .foregroundColor(brandBlue)
                 + Text(".")
                    .font(Font.custom("InstrumentSerif-Regular", size: 42)))
                    .padding(.top, 8)

                Text("Sign in to see today's matches and pick up where you left off.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .padding(.top, 8).padding(.bottom, 28)

                // Apple
                SignInWithAppleButton(.signIn) { request in
                    auth.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await handleApple(result) }
                }
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .signInWithAppleButtonStyle(.black)

                orDivider.padding(.vertical, 20)

                // Fields
                VStack(spacing: 12) {
                    labeledField("EMAIL", placeholder: "you@email.com", text: $email,
                                 keyboard: .emailAddress, contentType: .emailAddress)

                    labeledSecureField("PASSWORD", placeholder: "••••••••",
                                       text: $password, isShowing: $showPassword,
                                       contentType: .password)
                }

                // Remember me + Forgot password
                HStack {
                    Button { rememberMe.toggle() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .font(.system(size: 18))
                                .foregroundColor(rememberMe ? brandBlue : Color(.systemGray3))
                            Text("Remember me")
                                .font(.subheadline).foregroundColor(.primary)
                        }
                    }
                    Spacer()
                    Button("Forgot password?") { }
                        .font(.subheadline).foregroundColor(brandBlue)
                }
                .padding(.top, 16)

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
                        if isLoading { ProgressView().tint(.white) }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(formValid ? brandBlue : Color(red: 0.70, green: 0.76, blue: 0.95))
                    .cornerRadius(16)
                }
                .disabled(!formValid || isLoading)
                .padding(.top, 24)

                // Footer
                HStack(spacing: 4) {
                    Text("New to Boundr?").foregroundColor(.secondary)
                    Button("Create account") { showSignUp = true }
                        .fontWeight(.semibold).foregroundColor(brandBlue)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.87, green: 0.91, blue: 0.97),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showSignUp) { SignUpView() }
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

    private var orDivider: some View {
        HStack {
            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
            Text("OR WITH EMAIL")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .fixedSize()
                .padding(.horizontal, 8)
            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
        }
    }

    private func labeledField(_ label: String,
                               placeholder: String,
                               text: Binding<String>,
                               keyboard: UIKeyboardType = .default,
                               contentType: UITextContentType? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.6)
            TextField(placeholder, text: text)
                .font(.subheadline)
                .keyboardType(keyboard)
                .textContentType(contentType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }

    private func labeledSecureField(_ label: String,
                                    placeholder: String,
                                    text: Binding<String>,
                                    isShowing: Binding<Bool>,
                                    contentType: UITextContentType? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.6)
            HStack {
                Group {
                    if isShowing.wrappedValue {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .font(.subheadline)
                .textContentType(contentType)
                Button(isShowing.wrappedValue ? "Hide" : "Show") {
                    isShowing.wrappedValue.toggle()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}
