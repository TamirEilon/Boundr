import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var firstName     = ""
    @State private var lastName      = ""
    @State private var email         = ""
    @State private var password      = ""
    @State private var showPassword  = false
    @State private var agreedToTerms = false
    @State private var isLoading     = false
    @State private var errorMessage: String?
    @State private var showSignIn    = false

    private let brandBlue = Color(red: 38/255, green: 99/255, blue: 235/255)

    private var passwordStrength: Int {
        var score = 0
        if password.count >= 8                                               { score += 1 }
        if password.contains(where: { $0.isUppercase })                      { score += 1 }
        if password.contains(where: { $0.isNumber })                         { score += 1 }
        if password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,./<>?".contains($0) }) { score += 1 }
        return score
    }

    private var strengthColor: Color {
        switch passwordStrength {
        case 1:  return .red
        case 2:  return Color(red: 1.0, green: 0.55, blue: 0.0)
        case 3:  return Color(red: 1.0, green: 0.75, blue: 0.0)
        case 4:  return .green
        default: return Color(.systemGray4)
        }
    }

    private var strengthLabel: String {
        switch passwordStrength {
        case 1:  return "Weak"
        case 2:  return "Fair"
        case 3:  return "Good"
        case 4:  return "Strong"
        default: return ""
        }
    }

    private var formValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 8 &&
        agreedToTerms
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Title
                (Text("Find your ")
                    .font(Font.custom("InstrumentSerif-Regular", size: 42))
                 + Text("next")
                    .font(Font.custom("InstrumentSerif-Italic", size: 42))
                    .foregroundColor(brandBlue)
                 + Text(" country.")
                    .font(Font.custom("InstrumentSerif-Regular", size: 42)))
                    .padding(.top, 8)

                Text("Free to start. We'll match you to visas based on your real profile.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .padding(.top, 8).padding(.bottom, 28)

                // Apple
                SignInWithAppleButton(.signUp) { request in
                    auth.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await handleApple(result) }
                }
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .signInWithAppleButtonStyle(.black)

                orDivider.padding(.vertical, 20)

                // Fields
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 10) {
                        labeledField("FIRST NAME", placeholder: "Morgan", text: $firstName, capitalize: true)
                        labeledField("LAST NAME",  placeholder: "Lee",    text: $lastName,  capitalize: true)
                    }

                    labeledField("EMAIL", placeholder: "you@email.com", text: $email,
                                 keyboard: .emailAddress, contentType: .emailAddress)

                    VStack(alignment: .leading, spacing: 8) {
                        labeledSecureField("PASSWORD", placeholder: "At least 8 characters",
                                           text: $password, isShowing: $showPassword,
                                           contentType: .newPassword)

                        HStack(spacing: 4) {
                            ForEach(0..<4) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(i < passwordStrength ? strengthColor : Color(.systemGray4))
                                    .frame(height: 4)
                                    .animation(.easeInOut(duration: 0.2), value: passwordStrength)
                            }
                        }
                        if !strengthLabel.isEmpty {
                            Text(strengthLabel)
                                .font(.caption2)
                                .foregroundColor(strengthColor)
                                .animation(.easeInOut, value: passwordStrength)
                        }
                    }
                }

                // Error
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption).foregroundColor(.red)
                        .padding(.top, 12)
                }

                // Terms
                HStack(alignment: .center, spacing: 10) {
                    Button { agreedToTerms.toggle() } label: {
                        Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                            .font(.system(size: 16))
                            .foregroundColor(agreedToTerms ? brandBlue : Color(.systemGray3))
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)

                    Text(termsText)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 20)

                // Create account button
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
                    .background(formValid ? brandBlue : Color(red: 0.70, green: 0.76, blue: 0.95))
                    .cornerRadius(16)
                }
                .disabled(!formValid || isLoading)
                .padding(.top, 20)

                // Footer
                HStack(spacing: 4) {
                    Text("Already have an account?").foregroundColor(.secondary)
                    Button("Sign in") { showSignIn = true }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.ink)
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
                               contentType: UITextContentType? = nil,
                               capitalize: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.6)
            TextField(placeholder, text: text)
                .font(.subheadline)
                .keyboardType(keyboard)
                .textContentType(contentType)
                .autocapitalization(capitalize ? .words : .none)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var termsText: AttributedString {
        var str     = AttributedString("I agree to Boundr's ")
        str.foregroundColor = .secondary

        var terms   = AttributedString("Terms and Conditions")
        terms.foregroundColor = brandBlue
        terms.underlineStyle  = .single
        terms.link = URL(string: "https://imaginative-status-057532.framer.app/terms-and-condition")

        var and     = AttributedString(" and ")
        and.foregroundColor = .secondary

        var privacy = AttributedString("Privacy Policy")
        privacy.foregroundColor = brandBlue
        privacy.underlineStyle  = .single
        privacy.link = URL(string: "https://imaginative-status-057532.framer.app/privacy-policy")

        var period  = AttributedString(".")
        period.foregroundColor = .secondary

        return str + terms + and + privacy + period
    }
}
