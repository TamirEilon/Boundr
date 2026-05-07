import SwiftUI

// MARK: - Sort Option

enum SortOption: String, CaseIterable {
    case none              = "Default"
    case costLowHigh       = "Cost: Low to High"
    case costHighLow       = "Cost: High to Low"
    case durationLongShort = "Duration: Long to Short"
    case durationShortLong = "Duration: Short to Long"
    case processingFastSlow = "Processing: Fast to Slow"
    case processingSlowFast = "Processing: Slow to Fast"
}

// MARK: - ExploreView

struct ExploreView: View {
    @EnvironmentObject var store: VisaStore
    @State private var searchText      = ""
    @State private var selectedRegion  = "All"
    @State private var selectedType    = "All"
    @State private var sortOption: SortOption = .none

    private let regions = ["All", "Europe", "Americas", "Asia", "Oceania", "Middle East", "Other"]

    private var allVisaTypes: [String] {
        ["All"] + Array(Set(store.allVisas.map { $0.visaType })).sorted()
    }

    private func visaTypeLabel(_ type: String) -> String {
        switch type {
        case "All":          return "All"
        case "digital_nomad": return "Digital Nomad"
        case "tourist":      return "Tourist"
        case "work":         return "Work"
        case "student":      return "Student"
        case "retirement":   return "Retirement"
        default:             return type.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private var filteredVisas: [Visa] {
        var visas = store.allVisas.filter { visa in
            let matchSearch = searchText.isEmpty
                || visa.country.localizedCaseInsensitiveContains(searchText)
                || visa.visaName.localizedCaseInsensitiveContains(searchText)
                || visa.visaTypeDisplay.localizedCaseInsensitiveContains(searchText)
            let matchRegion = selectedRegion == "All" || visa.region == selectedRegion
            let matchType   = selectedType   == "All" || visa.visaType == selectedType
            return matchSearch && matchRegion && matchType
        }

        switch sortOption {
        case .costLowHigh:       visas.sort { parseCost($0.cost) < parseCost($1.cost) }
        case .costHighLow:       visas.sort { parseCost($0.cost) > parseCost($1.cost) }
        case .durationLongShort: visas.sort { parseDays($0.duration) > parseDays($1.duration) }
        case .durationShortLong: visas.sort { parseDays($0.duration) < parseDays($1.duration) }
        case .processingFastSlow: visas.sort { parseDays($0.processingTime) < parseDays($1.processingTime) }
        case .processingSlowFast: visas.sort { parseDays($0.processingTime) > parseDays($1.processingTime) }
        case .none: break
        }

        return visas
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 2) {
                    Text("Explore").font(.largeTitle).fontWeight(.bold)
                    Text("\(filteredVisas.count) visas").font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.horizontal).padding(.top).padding(.bottom, 16)

                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search countries or visa types", text: $searchText)
                        .font(.subheadline)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color(.systemGray6)).cornerRadius(12)
                .padding(.horizontal).padding(.bottom, 12)

                // Dropdowns
                HStack(spacing: 8) {
                    // Region
                    Menu {
                            ForEach(regions, id: \.self) { region in
                                Button {
                                    selectedRegion = region
                                } label: {
                                    if selectedRegion == region {
                                        Label(region, systemImage: "checkmark")
                                    } else {
                                        Text(region)
                                    }
                                }
                            }
                        } label: {
                            dropdownLabel(
                                title: selectedRegion == "All" ? "Region" : selectedRegion,
                                isActive: selectedRegion != "All"
                            )
                        }

                        // Visa Type
                        Menu {
                            ForEach(allVisaTypes, id: \.self) { type in
                                Button {
                                    selectedType = type
                                } label: {
                                    if selectedType == type {
                                        Label(visaTypeLabel(type), systemImage: "checkmark")
                                    } else {
                                        Text(visaTypeLabel(type))
                                    }
                                }
                            }
                        } label: {
                            dropdownLabel(
                                title: selectedType == "All" ? "Visa Type" : visaTypeLabel(selectedType),
                                isActive: selectedType != "All"
                            )
                        }

                        // Sort
                        Menu {
                            Button { sortOption = .none } label: {
                                if sortOption == .none { Label("Default", systemImage: "checkmark") }
                                else { Text("Default") }
                            }
                            Divider()
                            Button { sortOption = .costLowHigh } label: {
                                if sortOption == .costLowHigh { Label("Cost: Low to High", systemImage: "checkmark") }
                                else { Text("Cost: Low to High") }
                            }
                            Button { sortOption = .costHighLow } label: {
                                if sortOption == .costHighLow { Label("Cost: High to Low", systemImage: "checkmark") }
                                else { Text("Cost: High to Low") }
                            }
                            Divider()
                            Button { sortOption = .durationLongShort } label: {
                                if sortOption == .durationLongShort { Label("Duration: Long to Short", systemImage: "checkmark") }
                                else { Text("Duration: Long to Short") }
                            }
                            Button { sortOption = .durationShortLong } label: {
                                if sortOption == .durationShortLong { Label("Duration: Short to Long", systemImage: "checkmark") }
                                else { Text("Duration: Short to Long") }
                            }
                            Divider()
                            Button { sortOption = .processingFastSlow } label: {
                                if sortOption == .processingFastSlow { Label("Processing: Fast to Slow", systemImage: "checkmark") }
                                else { Text("Processing: Fast to Slow") }
                            }
                            Button { sortOption = .processingSlowFast } label: {
                                if sortOption == .processingSlowFast { Label("Processing: Slow to Fast", systemImage: "checkmark") }
                                else { Text("Processing: Slow to Fast") }
                            }
                        } label: {
                            dropdownLabel(
                                title: sortOption == .none ? "Sort" : sortOption.rawValue,
                                isActive: sortOption != .none
                            )
                        }
                }
                .padding(.horizontal)
                .padding(.bottom, 14)

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

    @ViewBuilder
    private func dropdownLabel(title: String, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .regular)
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(isActive ? .white : .primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isActive ? Color.black : Color(.systemGray6))
        .cornerRadius(20)
    }

    // MARK: - Parsing helpers

    private func parseCost(_ raw: String) -> Double {
        let digits = raw.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
        return Double(digits) ?? 0
    }

    private func parseDays(_ raw: String) -> Int {
        let lower = raw.lowercased()
        let nums = lower.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        let n = Int(nums.first ?? "0") ?? 0
        if lower.contains("year")  { return n * 365 }
        if lower.contains("month") { return n * 30  }
        if lower.contains("week")  { return n * 7   }
        return n
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
                    Text(visa.visaName)
                        .font(.subheadline).fontWeight(.semibold)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
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

// MARK: - FiltersSheet (kept for potential reuse)

#Preview {
    ExploreView().environmentObject(VisaStore())
}
