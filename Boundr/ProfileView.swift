import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var store: VisaStore
    @EnvironmentObject var auth: AuthManager
    @State private var showEditProfile = false
    @State private var showAbout = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Profile").font(.largeTitle).fontWeight(.bold)
                        .padding(.horizontal).padding(.top)

                    userCard
                    statsRow
                    profileDetails
                    actionsList
                    logOutButton.padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileView(user: store.user)
            }
            .navigationDestination(isPresented: $showAbout) {
                AboutView()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: User Card

    private var displayName: String {
        auth.currentUser?.displayName ?? store.user.fullName
    }

    private var profileSubtitle: String {
        let country = store.user.nationalities.first ?? store.user.homeCountry
        return "\(country) · \(store.user.age)"
    }

    private var userCard: some View {
        HStack(spacing: 16) {
            Circle().fill(Color.black).frame(width: 60, height: 60)
                .overlay(
                    Text(String(displayName.prefix(1)).uppercased())
                        .font(.title2).fontWeight(.semibold).foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(displayName).font(.headline).fontWeight(.semibold)
                Text(profileSubtitle)
                    .font(.subheadline).foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(dot: .green, label: "Eligible",   value: "\(store.eligibleVisas.count)")
            statCard(dot: .red,   label: "Not yet",    value: "\(store.ineligibleVisas.count)")
            statCard(dot: .blue,  label: "No visa needed", value: "\(store.exemptVisas.count)")
        }
        .padding(.horizontal)
    }

    private func statCard(dot: Color, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Circle().fill(dot).frame(width: 7, height: 7)
                Text(label).font(.caption).foregroundColor(.secondary)
            }
            Text(value).font(.title2).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }

    // MARK: Profile Details

    private var profileDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your profile").font(.headline).fontWeight(.bold).padding(.horizontal)

            VStack(spacing: 0) {
                detailRow(icon: "book",                      label: "Education",  value: store.user.educationDisplay)
                Divider().padding(.leading, 44)
                detailRow(icon: "briefcase",                 label: "Occupation", value: store.user.occupation)
                Divider().padding(.leading, 44)
                detailRow(icon: "chart.line.uptrend.xyaxis", label: "Experience", value: "\(store.user.experienceYears) years")
                Divider().padding(.leading, 44)
                detailRow(icon: "heart",                     label: "Marital status", value: store.user.maritalStatusDisplay)
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 15)).foregroundColor(.secondary).frame(width: 24)
            Text(label).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.semibold)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: Actions

    private var actionsList: some View {
        VStack(spacing: 0) {
            Button { showEditProfile = true } label: {
                actionRow(icon: "pencil", title: "Edit profile", subtitle: "Update what we match against")
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 56)
            Button { showSettings = true } label: {
                actionRow(icon: "gearshape", title: "Settings", subtitle: "Notifications, privacy & more")
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 56)
            Button { showAbout = true } label: {
                actionRow(icon: "info.circle", title: "About Boundr", subtitle: "Version 1.0")
            }
            .buttonStyle(.plain)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func actionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16)).foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6)).cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.semibold)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(Color(.systemGray3))
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: Log Out

    private var logOutButton: some View {
        Button { try? auth.signOut() } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 15))
                Text("Log out").font(.subheadline).fontWeight(.semibold)
            }
            .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
}

#Preview {
    ProfileView().environmentObject(VisaStore()).environmentObject(AuthManager())
}
