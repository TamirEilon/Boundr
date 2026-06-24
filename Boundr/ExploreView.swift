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
    @Binding var eligibilityFilter: String
    @State private var searchText           = ""
    @State private var selectedRegion       = "All"
    @State private var selectedType         = "All"
    @State private var selectedEligibility  = "All"
    @State private var sortOption: SortOption = .none

    private let eligibilityOptions = ["All", "Eligible", "Not Eligible", "No Visa Needed"]

    init(eligibilityFilter: Binding<String> = .constant("All")) {
        self._eligibilityFilter = eligibilityFilter
    }

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
            let matchEligibility: Bool = {
                switch selectedEligibility {
                case "Eligible":       return store.eligibility(visa) == .eligible
                case "Not Eligible":   return store.eligibility(visa) == .ineligible
                case "No Visa Needed": return store.eligibility(visa) == .exempt
                default:               return true
                }
            }()
            return matchSearch && matchRegion && matchType && matchEligibility
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
                VStack(spacing: 2) {
                    Text("Explore")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.ink)
                    Text("\(filteredVisas.count) visas")
                        .font(.sfR(15)).tracking(-0.45).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8).padding(.bottom, 16)

                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search countries or visa types", text: $searchText)
                        .font(.sfR(15)).tracking(-0.45)
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
                            // Eligibility section
                            Button { selectedEligibility = "All" } label: {
                                if selectedEligibility == "All" { Label("All", systemImage: "checkmark") }
                                else { Text("All") }
                            }
                            Button { selectedEligibility = "Eligible" } label: {
                                if selectedEligibility == "Eligible" { Label("Eligible", systemImage: "checkmark") }
                                else { Text("Eligible") }
                            }
                            Button { selectedEligibility = "Not Eligible" } label: {
                                if selectedEligibility == "Not Eligible" { Label("Not Eligible", systemImage: "checkmark") }
                                else { Text("Not Eligible") }
                            }
                            Button { selectedEligibility = "No Visa Needed" } label: {
                                if selectedEligibility == "No Visa Needed" { Label("No Visa Needed", systemImage: "checkmark") }
                                else { Text("No Visa Needed") }
                            }
                            Divider()
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
                                title: sortOption != .none ? sortOption.rawValue : selectedEligibility != "All" ? selectedEligibility : "Sort",
                                isActive: sortOption != .none || selectedEligibility != "All"
                            )
                        }
                }
                .padding(.horizontal)
                .padding(.bottom, 14)

                // List
                if filteredVisas.isEmpty {
                    VStack(spacing: 16) {
                        Text("No visas match your filters")
                            .font(.sfR(15)).tracking(-0.45)
                            .foregroundColor(.secondary)
                        Button {
                            searchText          = ""
                            selectedRegion      = "All"
                            selectedType        = "All"
                            selectedEligibility = "All"
                            sortOption          = .none
                        } label: {
                            Text("Clear filters")
                                .font(.sfR(15)).tracking(-0.45)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24).padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredVisas) { visa in
                                NavigationLink(value: visa) {
                                    VisaListRow(visa: visa, eligibility: store.eligibility(visa))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Visa.self) { VisaDetailView(visa: $0) }
            .onAppear {
                if eligibilityFilter != "All" {
                    selectedEligibility = eligibilityFilter
                    eligibilityFilter   = "All" // reset so repeat taps work
                }
            }
        }
    }

    @ViewBuilder
    private func dropdownLabel(title: String, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(isActive ? .sfSB(15) : .sfR(15))
                .tracking(-0.45)
                .lineLimit(1)
                .truncationMode(.tail)
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .medium))
                .fixedSize()
        }
        .foregroundColor(isActive ? .white : .primary)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
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
    let eligibility: VisaEligibility

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
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(visa.badgeColor.opacity(0.5))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(visa.countryCode)
                            .font(.sfSB(15)).tracking(-0.45).foregroundColor(.ink)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(visa.country.uppercased())
                        .font(.sfR(11)).tracking(-0.33).foregroundColor(.secondary).tracking(0.5)
                    Text(visa.visaName)
                        .font(.sfSB(15)).tracking(-0.45)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle().fill(tagColor).frame(width: 6, height: 6)
                    Text(tagLabel)
                        .font(.sfSB(12)).tracking(-0.36)
                        .foregroundColor(tagColor)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(tagColor.opacity(0.1))
                .cornerRadius(20)
            }
            .padding(.horizontal, 16).padding(.top, 16)

            Divider().padding(.horizontal, 16).padding(.top, 14)

            VStack(spacing: 8) {
                infoRow(icon: "clock",      label: "Duration",   value: visa.duration)
                infoRow(icon: "calendar",   label: "Processing", value: visa.processingTime)
                infoRow(icon: "creditcard", label: "Cost",       value: visa.cost)
            }
            .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 14)
            Text(label)
                .font(.sfR(12)).tracking(-0.36)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.sfSB(12)).tracking(-0.36)
                .foregroundColor(.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - FiltersSheet (kept for potential reuse)

#Preview {
    ExploreView().environmentObject(VisaStore())
}
