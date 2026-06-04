import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var store: VisaStore
    @Environment(\.dismiss) var dismiss

    @State private var showDeleteConfirm    = false
    @State private var showExportSheet      = false
    @State private var showFAQ             = false
    @State private var exportURL: URL?
    @State private var deleteError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Notifications
                settingsSection(title: "Notifications") {
                    Button {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        actionRow(icon: "bell", iconColor: .red, title: "Notification settings")
                    }
                    .buttonStyle(.plain)
                }

                // Privacy
                settingsSection(title: "Privacy") {
                    Button { exportData() } label: {
                        actionRow(icon: "square.and.arrow.up", iconColor: .green, title: "Export my data")
                    }
                    .buttonStyle(.plain)
                }

                // About
                settingsSection(title: "About") {
                    Button { showFAQ = true } label: {
                        actionRow(icon: "questionmark.circle", iconColor: .purple, title: "FAQ")
                    }
                    .buttonStyle(.plain)
                }

                // Delete account
                Button {
                    showDeleteConfirm = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                        Text("Delete my account")
                            .font(.subheadline).fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(14)
                }

                if let deleteError {
                    Text(deleteError)
                        .font(.caption).foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarItem(placement: .principal) {
                Text("Settings").font(.headline).fontWeight(.bold)
            }
        }
        .navigationDestination(isPresented: $showFAQ) { FAQView() }
        .alert("Delete account?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { deleteAccount() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your Boundr account. This cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color(.systemGray))
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
        }
    }

    private func toggleRow(icon: String, iconColor: Color, title: String, toggle: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Text(title)
                .font(.subheadline).fontWeight(.semibold)

            Spacer()

            Toggle("", isOn: toggle)
                .labelsHidden()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func actionRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Text(title)
                .font(.subheadline).fontWeight(.semibold)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(Color(.systemGray3))
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: - Actions

    private func exportData() {
        let user = store.user
        let dict: [String: Any] = [
            "nationalities":      user.nationalities,
            "homeCountry":        user.homeCountry,
            "age":                user.age,
            "educationLevel":     user.educationLevel,
            "occupation":         user.occupation,
            "experienceYears":    user.experienceYears,
            "relationshipStatus": user.relationshipStatus,
            "numberOfKids":       user.numberOfKids
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("boundr_profile.json")
        try? data.write(to: url)
        exportURL = url
        showExportSheet = true
    }

    private func deleteAccount() {
        Task {
            do {
                try await auth.currentUser?.delete()
                try? auth.signOut()
            } catch {
                deleteError = error.localizedDescription
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView().environmentObject(VisaStore()).environmentObject(AuthManager())
    }
}
