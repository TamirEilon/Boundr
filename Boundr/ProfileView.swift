import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: VisaStore
    @State private var showEditProfile = false

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
        }
    }

    // MARK: User Card

    private var userCard: some View {
        HStack(spacing: 16) {
            Circle().fill(Color.black).frame(width: 60, height: 60)
                .overlay(
                    Text(String(store.user.fullName.prefix(1)))
                        .font(.title2).fontWeight(.semibold).foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(store.user.fullName).font(.headline).fontWeight(.semibold)
                Text("\(store.user.homeCountry) · \(store.user.age)")
                    .font(.subheadline).foregroundColor(.secondary)
            }

            Spacer()

            Button { showEditProfile = true } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 15)).foregroundColor(.primary)
                    .padding(10).background(Color(.systemGray6)).clipShape(Circle())
            }
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
            statCard(dot: .blue,  label: "Saved",      value: "\(store.savedVisas.count)")
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }

    // MARK: Profile Details

    private var profileDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your profile").font(.headline).fontWeight(.bold).padding(.horizontal)

            VStack(spacing: 0) {
                detailRow(icon: "book",                   label: "Education",  value: store.user.educationDisplay)
                Divider().padding(.leading, 44)
                detailRow(icon: "briefcase",              label: "Occupation", value: store.user.occupation)
                Divider().padding(.leading, 44)
                detailRow(icon: "chart.line.uptrend.xyaxis", label: "Experience", value: "\(store.user.experienceYears) years")
                Divider().padding(.leading, 44)
                detailRow(icon: "creditcard",             label: "Income",     value: store.user.incomeDisplay)
                Divider().padding(.leading, 44)
                detailRow(icon: "character.book.closed",  label: "Languages",  value: store.user.languages)
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
                actionRow(icon: "pencil", title: "Edit profile", subtitle: "Update what we match against", badge: nil)
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 56)
            actionRow(icon: "bell",         title: "Notifications",         subtitle: "3 new alerts",                  badge: 3)
            Divider().padding(.leading, 56)
            actionRow(icon: "gearshape",    title: "Settings & Preferences", subtitle: "Currency, units, language",    badge: nil)
            Divider().padding(.leading, 56)
            actionRow(icon: "shield",       title: "Privacy & Data",         subtitle: "Control what we store",        badge: nil)
            Divider().padding(.leading, 56)
            actionRow(icon: "info.circle",  title: "About Boundr",           subtitle: "Version 1.0",                  badge: nil)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func actionRow(icon: String, title: String, subtitle: String, badge: Int?) -> some View {
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

            if let badge {
                Text("\(badge)")
                    .font(.caption).fontWeight(.bold).foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.blue).clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(Color(.systemGray3))
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: Log Out

    private var logOutButton: some View {
        Button {} label: {
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
    ProfileView().environmentObject(VisaStore())
}
