import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    private let privacyURL    = URL(string: "https://imaginative-status-057532.framer.app/privacy-policy")!
    private let termsURL      = URL(string: "https://imaginative-status-057532.framer.app/terms-and-condition")!
    private let aiURL         = URL(string: "https://imaginative-status-057532.framer.app/ai-disclaimer")!
    private let refundURL     = URL(string: "https://imaginative-status-057532.framer.app/refund-policy")!
    private let contactURL    = URL(string: "https://imaginative-status-057532.framer.app/contact")!

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Image("BoundrLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .cornerRadius(16)
                    .padding(.top, 24)
                    .padding(.bottom, 24)

                Text("Visas, simplified.")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .padding(.bottom, 16)

                Text("Boundr helps you discover visa opportunities based on your profile, goals, and future plans — all in one place. We simplify the complex world of immigration by turning scattered requirements into clear, personalized insights you can understand in minutes.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding(.bottom, 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Version")
                        .font(.caption).foregroundColor(.secondary)
                    Text("\(appVersion) · Build \(buildNumber)")
                        .font(.subheadline).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .padding(.bottom, 16)

                VStack(spacing: 0) {
                    linkRow("Privacy Policy")     { UIApplication.shared.open(privacyURL) }
                    Divider().padding(.leading, 16)
                    linkRow("Terms & Conditions") { UIApplication.shared.open(termsURL) }
                    Divider().padding(.leading, 16)
                    linkRow("AI Disclaimer")      { UIApplication.shared.open(aiURL) }
                    Divider().padding(.leading, 16)
                    linkRow("Refund Policy")      { UIApplication.shared.open(refundURL) }
                    Divider().padding(.leading, 16)
                    linkRow("Contact us")         { UIApplication.shared.open(contactURL) }
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 38, height: 38)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
        }
    }

    private func linkRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(.subheadline).foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption).foregroundColor(Color(.systemGray3))
            }
            .padding(.horizontal, 16).padding(.vertical, 16)
        }
    }
}

#Preview {
    NavigationStack { AboutView() }
}
