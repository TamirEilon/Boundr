import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ExploreView()
                .tabItem { Label("Explore", systemImage: "safari") }
            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject var store: VisaStore

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
                    eligibilityStats

                    if !store.eligibleVisas.isEmpty   { eligibleSection }
                    if !store.ineligibleVisas.isEmpty { workingTowardSection }

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
                Text(greeting).font(.subheadline).foregroundColor(.secondary)
                Text("Hey, \(store.user.firstName)").font(.title).fontWeight(.bold)
            }
            Spacer()
            HStack(spacing: 10) {
                Button {} label: {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 18)).foregroundColor(.primary)
                        .padding(10).background(Color(.systemGray6)).clipShape(Circle())
                }
                Circle().fill(Color.black).frame(width: 40, height: 40)
                    .overlay(
                        Text(String(store.user.fullName.prefix(1)))
                            .font(.headline).foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal).padding(.top)
    }

    // MARK: Top Match

    @ViewBuilder
    private var topMatchSection: some View {
        if let visa = store.topMatch {
            NavigationLink(value: visa) {
                TopMatchCard(visa: visa)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
    }

    // MARK: Stats

    private var eligibilityStats: some View {
        HStack(spacing: 20) {
            statPill(color: .green, label: "Eligible", count: store.eligibleVisas.count)
            statPill(color: .red,   label: "Not yet",  count: store.ineligibleVisas.count)
        }
        .padding(.horizontal)
    }

    private func statPill(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.subheadline)
            Text("\(count)").font(.subheadline).fontWeight(.semibold)
        }
    }

    // MARK: Eligible Section

    private var eligibleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Where you can go right now")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.eligibleVisas.prefix(10)) { visa in
                        NavigationLink(value: visa) { EligibleVisaCard(visa: visa) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: Working Toward

    private var workingTowardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Worth working toward")
            VStack(spacing: 10) {
                ForEach(store.ineligibleVisas.prefix(3)) { visa in
                    NavigationLink(value: visa) {
                        WorkingTowardRow(visa: visa).padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title).font(.headline).fontWeight(.bold)
            Spacer()
            Button("See all") {}.font(.subheadline).foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
}

// MARK: - TopMatchCard

struct TopMatchCard: View {
    let visa: Visa

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color(red: 0.08, green: 0.18, blue: 0.38),
                             Color(red: 0.15, green: 0.30, blue: 0.50)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 230)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkle").font(.caption)
                    Text("TOP MATCH").font(.caption).fontWeight(.semibold).tracking(1.2)
                }
                .foregroundColor(.white.opacity(0.85))

                Text(visa.country.uppercased())
                    .font(.caption).fontWeight(.medium).foregroundColor(.white.opacity(0.75))

                Text(visa.visaName)
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)

                Text(visa.description)
                    .font(.subheadline).foregroundColor(.white.opacity(0.8)).lineLimit(2)

                HStack(spacing: 16) {
                    Label(visa.processingTime, systemImage: "clock").font(.caption)
                    Label(visa.cost,           systemImage: "creditcard").font(.caption)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .padding(11).background(Color.blue).clipShape(Circle())
                }
                .foregroundColor(.white.opacity(0.85))
            }
            .padding(20)
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
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                )

            Text(visa.country.uppercased())
                .font(.caption2).foregroundColor(.secondary).tracking(0.5)

            Text(visa.visaName)
                .font(.subheadline).fontWeight(.semibold).lineLimit(2)

            HStack(spacing: 4) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text(visa.duration).font(.caption).foregroundColor(.secondary).lineLimit(1)
            }
        }
        .padding(14)
        .frame(width: 155)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

// MARK: - WorkingTowardRow

struct WorkingTowardRow: View {
    let visa: Visa

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pink.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(visa.countryCode)
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.pink)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(visa.country.uppercased())
                    .font(.caption2).foregroundColor(.secondary).tracking(0.5)
                Text(visa.visaName).font(.subheadline).fontWeight(.semibold)
            }

            Spacer()

            Text("Not eligible")
                .font(.caption).fontWeight(.semibold).foregroundColor(.red)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.red.opacity(0.1)).cornerRadius(8)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

#Preview {
    ContentView().environmentObject(VisaStore())
}
