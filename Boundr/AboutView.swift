import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showPrivacy  = false
    @State private var showTerms    = false
    @State private var showAI       = false
    @State private var showContact  = false

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

                Text("Visas, demystified.")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .padding(.bottom, 16)

                Text("Boundr turns the most opaque part of moving abroad — the legal one — into something you can scan in under a minute. We pull from official immigration sources across 80+ countries and match them to your real profile.")
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
                    linkRow("Privacy Policy")  { showPrivacy  = true }
                    Divider().padding(.leading, 16)
                    linkRow("Terms of Service") { showTerms   = true }
                    Divider().padding(.leading, 16)
                    linkRow("AI Disclaimer")    { showAI      = true }
                    Divider().padding(.leading, 16)
                    linkRow("Contact us")       { showContact = true }
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
        .navigationDestination(isPresented: $showPrivacy)  { PrivacyPolicyView() }
        .navigationDestination(isPresented: $showTerms)    { TermsOfServiceView() }
        .navigationDestination(isPresented: $showAI)       { AIDisclaimerView() }
        .navigationDestination(isPresented: $showContact)  { ContactUsView() }
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
