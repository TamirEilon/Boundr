import SwiftUI
import FirebaseAuth

struct ManageAccountView: View {
    @EnvironmentObject var store: VisaStore
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false
    @State private var showExportSheet   = false
    @State private var exportURL: URL?
    @State private var deleteError: String?

    private let ink      = Color(red: 51/255,  green: 54/255,  blue: 63/255)   // #33363F
    private let arrow    = Color(red: 173/255, green: 173/255, blue: 173/255)  // #ADADAD
    private let hairline = Color.black.opacity(0.07)

    private func dm(_ size: CGFloat, _ semibold: Bool = false) -> Font {
        Font.custom(semibold ? "DMSans-SemiBold" : "DMSans-Regular", size: size)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Button { exportData() } label: {
                    row(icon: "arrow.triangle.2.circlepath", title: "Export my data")
                }
                .buttonStyle(.plain)

                divider

                Button { showDeleteConfirm = true } label: {
                    row(icon: "trash", title: "Delete account")
                }
                .buttonStyle(.plain)

                divider

                if let deleteError {
                    Text(deleteError)
                        .font(dm(13))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 14)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ink)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Manage Account").font(dm(18, true)).foregroundColor(ink)
            }
        }
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

    // MARK: - Row

    private func row(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(ink)
                .frame(width: 22, alignment: .center)
            Text(title)
                .font(dm(15, true))
                .foregroundColor(ink)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(arrow)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 23)
        .contentShape(Rectangle())
    }

    private var divider: some View {
        Rectangle().fill(hairline).frame(height: 1).padding(.horizontal, 20)
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

#Preview {
    NavigationStack {
        ManageAccountView().environmentObject(VisaStore()).environmentObject(AuthManager())
    }
}
