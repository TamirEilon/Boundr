import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var store: VisaStore
    @State private var searchText = ""
    @State private var selectedEligibility = "All"
    @State private var selectedRegion = "All"

    private let regions = ["All", "Europe", "Americas", "Asia", "Oceania", "Middle East", "Other"]

    private var eligibilityOptions: [String] {
        ["All",
         "Eligible \(store.eligibleVisas.count)",
         "Not eligible \(store.ineligibleVisas.count)"]
    }

    private var filteredVisas: [Visa] {
        store.allVisas.filter { visa in
            let matchSearch = searchText.isEmpty
                || visa.country.localizedCaseInsensitiveContains(searchText)
                || visa.visaName.localizedCaseInsensitiveContains(searchText)
                || visa.visaTypeDisplay.localizedCaseInsensitiveContains(searchText)

            let matchEligibility: Bool = {
                if selectedEligibility.hasPrefix("Eligible") && !selectedEligibility.hasPrefix("Not") {
                    return store.isEligible(visa)
                }
                if selectedEligibility.hasPrefix("Not eligible") {
                    return !store.isEligible(visa)
                }
                return true
            }()

            let matchRegion = selectedRegion == "All" || visa.region == selectedRegion

            return matchSearch && matchEligibility && matchRegion
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Explore").font(.largeTitle).fontWeight(.bold)
                        Text("\(filteredVisas.count) visas").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 18)).foregroundColor(.primary)
                            .padding(10).background(Color(.systemGray6)).cornerRadius(10)
                    }
                }
                .padding(.horizontal).padding(.top).padding(.bottom, 16)

                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search countries or visa types", text: $searchText)
                        .font(.subheadline)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color(.systemGray6)).cornerRadius(12)
                .padding(.horizontal).padding(.bottom, 16)

                // Eligibility filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(eligibilityOptions, id: \.self) { opt in
                            EligibilityChip(label: opt, isSelected: selectedEligibility == opt) {
                                selectedEligibility = opt
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                // Region filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(regions, id: \.self) { region in
                            RegionChip(label: region, isSelected: selectedRegion == region) {
                                selectedRegion = region
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)

                // List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredVisas) { visa in
                            NavigationLink(value: visa) {
                                VisaListRow(visa: visa, isEligible: store.isEligible(visa))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Visa.self) { VisaDetailView(visa: $0) }
        }
    }
}

// MARK: - Eligibility Chip

struct EligibilityChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Region Chip

struct RegionChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline).foregroundColor(.primary)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.primary : Color(.systemGray4),
                                lineWidth: isSelected ? 1.5 : 1)
                )
        }
    }
}

// MARK: - VisaListRow (shared with SavedView)

struct VisaListRow: View {
    let visa: Visa
    let isEligible: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(visa.badgeColor.opacity(0.5))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(visa.countryCode)
                            .font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(visa.country.uppercased())
                        .font(.caption2).foregroundColor(.secondary).tracking(0.5)
                    Text(visa.visaName).font(.subheadline).fontWeight(.semibold)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle().fill(isEligible ? Color.green : Color.red).frame(width: 6, height: 6)
                    Text(isEligible ? "Eligible" : "Not eligible")
                        .font(.caption).fontWeight(.medium)
                        .foregroundColor(isEligible ? .green : .red)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background((isEligible ? Color.green : Color.red).opacity(0.1))
                .cornerRadius(20)
            }
            .padding(.horizontal, 16).padding(.top, 16)

            Divider().padding(.horizontal, 16).padding(.top, 14)

            HStack(spacing: 20) {
                Label(visa.duration,       systemImage: "clock").font(.caption)
                Label(visa.cost,           systemImage: "creditcard").font(.caption)
                Spacer()
                Label(visa.processingTime, systemImage: "calendar").font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

#Preview {
    ExploreView().environmentObject(VisaStore())
}
