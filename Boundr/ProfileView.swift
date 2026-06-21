import SwiftUI
import StoreKit
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var store: VisaStore
    @EnvironmentObject var auth: AuthManager
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @Binding var selectedTab: Int
    @Binding var exploreEligibilityFilter: String

    init(selectedTab: Binding<Int> = .constant(3),
         exploreEligibilityFilter: Binding<String> = .constant("All")) {
        self._selectedTab              = selectedTab
        self._exploreEligibilityFilter = exploreEligibilityFilter
    }

    // MARK: - Design tokens

    private let ink       = Color(red: 51/255,  green: 54/255,  blue: 63/255)   // #33363F
    private let arrow     = Color(red: 173/255, green: 173/255, blue: 173/255)  // #ADADAD
    private let brandBlue = Color(red: 67/255,  green: 122/255, blue: 244/255)  // #437AF4
    private let hairline  = Color.black.opacity(0.07)

    private enum Route: Hashable {
        case editProfile, manageAccount, faq, about, legal
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("Profile")
                        .font(.custom("DMSans-SemiBold", size: 18))
                        .foregroundColor(ink)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    ratingBanner
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        navRow(.editProfile,   icon: "icon-edit",          title: "Edit Profile")
                        divider
                        navRow(.manageAccount, icon: "icon-account",       title: "Manage Account")
                        divider
                        notificationsRow
                        divider
                        contactRow
                        divider
                        navRow(.faq,           icon: "icon-faq",           title: "FAQ")
                        divider
                        navRow(.about,         icon: "icon-about",         title: "About Boundr")
                        divider
                        navRow(.legal,         icon: "icon-legal",         title: "Legal Info")
                        divider
                        logOutRow
                    }
                    .padding(.top, 6)
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .editProfile:   EditProfileView(user: store.user)
                case .manageAccount: ManageAccountView()
                case .faq:           FAQView()
                case .about:         AboutView()
                case .legal:         LegalInfoView()
                }
            }
        }
    }

    // MARK: - Rating banner

    private var ratingBanner: some View {
        Button {
            requestReview()
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Rating is caring")
                        .font(.custom("DMSans-SemiBold", size: 22))
                        .foregroundColor(.white)
                    Text("Help us reach more people by\nrating the app")
                        .font(.custom("DMSans-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                starCluster
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .background(brandBlue)
            .cornerRadius(22)
        }
        .buttonStyle(.plain)
    }

    private var starCluster: some View {
        func star(_ size: CGFloat) -> some View {
            Image("rating-star").resizable().scaledToFit().frame(width: size, height: size)
        }
        return ZStack {
            star(38).rotationEffect(.degrees(-20)).offset(x: -26, y: 9)
            star(38).rotationEffect(.degrees(20)).offset(x: 26, y: 9)
            star(50).offset(y: -5)
        }
        .frame(width: 98, height: 66)
    }

    // MARK: - Rows

    private func navRow(_ route: Route, icon: String, title: String) -> some View {
        NavigationLink(value: route) {
            rowContent(icon: icon, title: title)
        }
        .buttonStyle(.plain)
    }

    private var notificationsRow: some View {
        Button {
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                openURL(url)
            }
        } label: {
            rowContent(icon: "icon-notifications", title: "Notifications Settings")
        }
        .buttonStyle(.plain)
    }

    private var contactRow: some View {
        Button {
            if let url = URL(string: "https://imaginative-status-057532.framer.app/contact") {
                openURL(url)
            }
        } label: {
            rowContent(icon: "icon-contact", title: "Contact Us")
        }
        .buttonStyle(.plain)
    }

    private var logOutRow: some View {
        Button {
            try? auth.signOut()
        } label: {
            rowContent(icon: "icon-logout", title: "Log Out")
        }
        .buttonStyle(.plain)
    }

    private func rowContent(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(ink)
                .frame(width: 20, height: 18, alignment: .center)
            Text(title)
                .font(.custom("DMSans-SemiBold", size: 15))
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
        Rectangle()
            .fill(hairline)
            .frame(height: 1)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}

#Preview {
    ProfileView().environmentObject(VisaStore()).environmentObject(AuthManager())
}
