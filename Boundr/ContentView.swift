import SwiftUI
import FirebaseAuth

extension Color {
    static let ink = Color(red: 51/255, green: 54/255, blue: 63/255)  // #33363F
}

extension Font {
    // SF Pro (system) helpers used across the app.
    static func sfR(_ size: CGFloat)  -> Font { .system(size: size, weight: .regular) }
    static func sfSB(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    static func sfB(_ size: CGFloat)  -> Font { .system(size: size, weight: .bold) }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab               = 0
    @State private var exploreEligibilityFilter  = "All"

    private static let tabInk = Color(red: 51/255, green: 54/255, blue: 63/255)  // #33363F

    init() {
        // Icon-only tab bar. Both states are #33363F — they differ by shape
        // (outline when unselected, filled when selected), not by color.
        let ink = UIColor(red: 51/255, green: 54/255, blue: 63/255, alpha: 1)   // #33363F
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        for layout in [appearance.stackedLayoutAppearance,
                       appearance.inlineLayoutAppearance,
                       appearance.compactInlineLayoutAppearance] {
            layout.normal.iconColor   = ink
            layout.selected.iconColor = ink
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = ink
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Image(selectedTab == 0 ? "tab-home-fill" : "tab-home") }
                .tag(0)
            ExploreView(eligibilityFilter: $exploreEligibilityFilter)
                .tabItem { Image(selectedTab == 1 ? "tab-explore-fill" : "tab-explore") }
                .tag(1)
            SavedView()
                .tabItem { Image(selectedTab == 2 ? "tab-saved-fill" : "tab-saved") }
                .tag(2)
            ProfileView(selectedTab: $selectedTab, exploreEligibilityFilter: $exploreEligibilityFilter)
                .tabItem { Image(selectedTab == 3 ? "tab-profile-fill" : "tab-profile") }
                .tag(3)
        }
        .tint(Self.tabInk)   // selected tab = #33363F (filled), not blue
    }
}

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject var store: VisaStore
    @EnvironmentObject var auth: AuthManager
    @Binding var selectedTab: Int

    private var firstName: String {
        let name = auth.currentUser?.displayName ?? store.user.firstName
        return name.components(separatedBy: " ").first ?? name
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning 👋" }
        if h < 17 { return "Good afternoon 👋" }
        return "Good evening 👋"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    topMatchSection

                    if store.eligibleVisas.isEmpty {
                        workTowardCarouselSection
                    } else {
                        eligibleSection
                    }

                    if store.recentlyViewedVisas.isEmpty {
                        if !store.ineligibleVisas.isEmpty { workingTowardSection }
                    } else {
                        recentlyViewedSection
                    }

                    Spacer(minLength: 20)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Visa.self) { VisaDetailView(visa: $0) }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting).font(.sfR(15)).tracking(-0.45).foregroundColor(.secondary)
                Text(firstName).font(.sfB(26)).tracking(-0.78).foregroundColor(.ink)
            }
            Spacer()
            Circle().fill(Color.black).frame(width: 40, height: 40)
                .overlay(
                    Text(String((auth.currentUser?.displayName ?? store.user.fullName).prefix(1)).uppercased())
                        .font(.sfSB(17)).tracking(-0.51).foregroundColor(.white)
                )
                .contentShape(Circle())
                .onTapGesture { selectedTab = 3 }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Profile")
        }
        .padding(.horizontal).padding(.top)
    }

    // MARK: Top Match

    @ViewBuilder
    private var topMatchSection: some View {
        if let visa = store.topMatch {
            NavigationLink(value: visa) {
                TopMatchCard(visa: visa, isEligible: store.topMatchIsEligible)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
    }

    // MARK: Eligible Section

    private var eligibleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Where you can go right now")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.eligibleVisas.prefix(10)) { visa in
                        NavigationLink(value: visa) { EligibleVisaCard(visa: visa).contentShape(Rectangle()) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
        }
    }

    // MARK: Work Toward Carousel (shown when no eligible visas)

    private var workTowardCarouselSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                sectionHeader("Visas to work toward")
                Text("You don't qualify yet — here's what's close.")
                    .font(.sfR(12)).tracking(-0.36).foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.ineligibleVisas.prefix(10)) { visa in
                        NavigationLink(value: visa) { WorkTowardCard(visa: visa).contentShape(Rectangle()) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
        }
    }

    // MARK: Working Toward

    private var workingTowardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Worth working toward")
                .font(.sfSB(17)).tracking(-0.51).foregroundColor(.ink)
                .padding(.horizontal)
            VStack(spacing: 10) {
                ForEach(store.ineligibleVisas.prefix(3)) { visa in
                    NavigationLink(value: visa) {
                        WorkingTowardRow(visa: visa).padding(.horizontal).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Recently Viewed

    private var recentlyViewedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently viewed")
                .font(.sfSB(17)).tracking(-0.51).foregroundColor(.ink)
                .padding(.horizontal)
            VStack(spacing: 10) {
                ForEach(store.recentlyViewedVisas.prefix(5)) { visa in
                    NavigationLink(value: visa) {
                        WorkingTowardRow(visa: visa, eligibility: store.eligibility(visa)).padding(.horizontal).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.sfSB(17)).tracking(-0.51).foregroundColor(.ink)
            .padding(.horizontal)
    }
}

// MARK: - TopMatchCard

struct TopMatchCard: View {
    let visa: Visa
    var isEligible: Bool = true

    private var fallbackGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.18, blue: 0.38),
                     Color(red: 0.15, green: 0.30, blue: 0.50)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Badge
            HStack(spacing: 4) {
                Image(systemName: isEligible ? "sparkle" : "lock").font(.caption)
                Text(isEligible ? "TOP MATCH" : "EXPLORE")
                    .font(.sfSB(12)).tracking(-0.36).tracking(1.2)
            }
            .foregroundColor(.white.opacity(0.85))

            Spacer(minLength: 16)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(visa.country.uppercased())
                    .font(.sfR(12)).tracking(-0.36).foregroundColor(.white.opacity(0.75))

                Text(visa.visaName)
                    .font(.sfSB(22)).tracking(-0.66).foregroundColor(.white)
                    .lineLimit(2)

                Text(visa.description)
                    .font(.sfR(14)).tracking(-0.42).foregroundColor(.white.opacity(0.8)).lineLimit(2)

                HStack(spacing: 16) {
                    Label(visa.processingTime, systemImage: "clock")
                        .font(.sfR(12)).tracking(-0.36).lineLimit(1)
                    Label(visa.cost, systemImage: "creditcard")
                        .font(.sfR(12)).tracking(-0.36).lineLimit(1).truncationMode(.tail)
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .padding(11).background(Color(red: 38/255, green: 99/255, blue: 235/255)).clipShape(Circle())
                }
                .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 230, alignment: .topLeading)
        .background {
            AsyncImage(url: CountryUtils.imageURL(for: visa.country)) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(fallbackGradient)
                }
            }
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.15), .black.opacity(0.65)],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - EligibleVisaCard

struct EligibleVisaCard: View {
    let visa: Visa

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(visa.badgeColor.opacity(0.5))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(visa.countryCode)
                        .font(.sfSB(15)).tracking(-0.45).foregroundColor(.ink)
                )

            Text(visa.country.uppercased())
                .font(.sfR(11)).tracking(-0.33).foregroundColor(.secondary).tracking(0.5)

            Text(visa.visaName)
                .font(.sfSB(15)).tracking(-0.45).lineLimit(2).foregroundColor(.ink)

            HStack(spacing: 4) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text(visa.duration).font(.sfR(12)).tracking(-0.36).foregroundColor(.secondary).lineLimit(1)
            }
        }
        .padding(14)
        .frame(width: 155, height: 160, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

// MARK: - WorkTowardCard

struct WorkTowardCard: View {
    let visa: Visa

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(visa.countryCode)
                            .font(.sfSB(15)).tracking(-0.45)
                            .foregroundColor(Color(.systemGray2))
                    )
                Image(systemName: "lock.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }

            Text(visa.country.uppercased())
                .font(.sfR(11)).tracking(-0.33).foregroundColor(.secondary).tracking(0.5)

            Text(visa.visaName)
                .font(.sfSB(15)).tracking(-0.45).lineLimit(2)
                .foregroundColor(.ink)

            HStack(spacing: 4) {
                Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                Text(visa.duration).font(.sfR(12)).tracking(-0.36).foregroundColor(.secondary).lineLimit(1)
            }
        }
        .padding(14)
        .frame(width: 155, height: 160, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

// MARK: - WorkingTowardRow

struct WorkingTowardRow: View {
    let visa: Visa
    var eligibility: VisaEligibility = .ineligible

    private var tagColor: Color {
        switch eligibility {
        case .eligible:   return .green
        case .exempt:     return .blue
        case .ineligible: return .red
        }
    }

    private var tagLabel: String {
        switch eligibility {
        case .eligible:   return "Eligible"
        case .exempt:     return "No visa needed"
        case .ineligible: return "Not eligible"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pink.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(visa.countryCode)
                        .font(.sfSB(15)).tracking(-0.45).foregroundColor(.pink)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(visa.country.uppercased())
                    .font(.sfR(11)).tracking(-0.33).foregroundColor(.secondary).tracking(0.5)
                Text(visa.visaName).font(.sfSB(15)).tracking(-0.45).foregroundColor(.ink)
            }

            Spacer()

            Text(tagLabel)
                .font(.sfSB(12)).tracking(-0.36)
                .foregroundColor(tagColor)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(tagColor.opacity(0.1)).cornerRadius(8)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

#Preview {
    ContentView()
        .environmentObject(VisaStore())
        .environmentObject(AuthManager())
}
