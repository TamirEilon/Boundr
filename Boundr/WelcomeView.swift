import SwiftUI

struct WelcomeView: View {
    @State private var showSignUp = false
    @State private var showSignIn = false

    private let brandBlue = Color(red: 0.28, green: 0.40, blue: 0.92)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Logo
                    Image("BoundrLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .cornerRadius(16)
                        .padding(.top, 64)

                    Spacer().frame(height: 36)

                    // Headline
                    Group {
                        Text("Where in the\nworld ")
                            .font(.system(size: 42, weight: .regular, design: .serif))
                        + Text("can you")
                            .font(.system(size: 42, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(brandBlue)
                        + Text(" go?")
                            .font(.system(size: 42, weight: .regular, design: .serif))
                    }
                    .lineSpacing(4)

                    Spacer().frame(height: 28)

                    // Subtitle
                    Text("Boundr matches you to visas you actually qualify for — based on your real profile.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(3)

                    Spacer()

                    // CTAs
                    VStack(spacing: 14) {
                        Button {
                            showSignUp = true
                        } label: {
                            Text("Get started")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(brandBlue)
                                .cornerRadius(16)
                        }

                        Button {
                            showSignIn = true
                        } label: {
                            Text("I already have an account")
                                .font(.subheadline).fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)

                        // Legal footer
                        HStack(spacing: 4) {
                            Text("By continuing you agree to our")
                            Button("Terms") {}
                            Text("·")
                            Button("Privacy Policy") {}
                        }
                        .font(.caption2)
                        .foregroundColor(Color(.systemGray3))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 28)
            }
            .navigationDestination(isPresented: $showSignUp) { SignUpView() }
            .navigationDestination(isPresented: $showSignIn) { SignInView() }
        }
    }
}

#Preview {
    WelcomeView().environmentObject(AuthManager())
}
