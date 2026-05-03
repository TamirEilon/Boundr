import SwiftUI
import Foundation
import Combine

class VisaStore: ObservableObject {
    @Published var allVisas: [Visa] = []
    @Published var savedVisaIDs: Set<String> = []
    @Published var user = UserProfile()

    init() { loadVisas() }

    // MARK: - Computed

    var eligibleVisas: [Visa]   { allVisas.filter { isEligible($0) } }
    var ineligibleVisas: [Visa] { allVisas.filter { !isEligible($0) } }
    var savedVisas: [Visa]      { allVisas.filter { savedVisaIDs.contains($0.id) } }
    var topMatch: Visa?         { eligibleVisas.first }

    // MARK: - Eligibility

    func isEligible(_ visa: Visa) -> Bool {
        // Nationality: if list is non-empty, at least one of the user's nationalities must appear
        if !visa.eligibleNationalities.isEmpty,
           !user.nationalities.contains(where: { visa.eligibleNationalities.contains($0) }) { return false }
        // Age bounds
        if let min = visa.minAge, user.age < min { return false }
        if let max = visa.maxAge, user.age > max { return false }
        // Education: if required, user's level must be in the accepted list
        if !visa.requiredEducation.isEmpty,
           !visa.requiredEducation.contains(user.educationLevel) { return false }
        return true
    }

    func isSaved(_ visa: Visa) -> Bool { savedVisaIDs.contains(visa.id) }

    func toggleSaved(_ visa: Visa) {
        if savedVisaIDs.contains(visa.id) {
            savedVisaIDs.remove(visa.id)
        } else {
            savedVisaIDs.insert(visa.id)
        }
    }

    // MARK: - CSV Loading

    private func loadVisas() {
        guard let url = Bundle.main.url(forResource: "Visa_export", withExtension: "csv"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("❌ Visa_export.csv not found in bundle — add it to the Xcode target")
            return
        }

        let rows = parseCSV(content)
        guard rows.count > 1 else { return }

        // Column indices (0-based): country visaType visaName description duration
        // processingTime cost requirements eligibleNationalities minAge maxAge
        // requiredOccupation requiredEducation applicationUrl id …
        allVisas = rows.dropFirst().compactMap { fields in
            guard fields.count >= 14 else { return nil }
            return Visa(
                id:                    fields.count > 14 ? fields[14] : UUID().uuidString,
                country:               fields[0],
                visaType:              fields[1],
                visaName:              fields[2],
                description:           fields[3],
                duration:              fields[4],
                processingTime:        fields[5],
                cost:                  fields[6],
                requirements:          parseJSONArray(fields[7]),
                eligibleNationalities: parseJSONArray(fields[8]),
                minAge:                Int(fields[9].trimmingCharacters(in: .whitespaces)),
                maxAge:                Int(fields[10].trimmingCharacters(in: .whitespaces)),
                requiredOccupation:    fields[11].trimmingCharacters(in: .whitespaces).isEmpty ? nil : fields[11],
                requiredEducation:     parseJSONArray(fields[12]),
                applicationURL:        fields[13]
            )
        }
    }

    // Handles quoted fields, escaped "" inside quotes, and multiline fields.
    private func parseCSV(_ content: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var inQuotes = false
        var i = content.startIndex

        while i < content.endIndex {
            let ch = content[i]

            if inQuotes {
                if ch == "\"" {
                    let next = content.index(after: i)
                    if next < content.endIndex && content[next] == "\"" {
                        currentField.append("\"")
                        i = content.index(after: next)
                        continue
                    } else {
                        inQuotes = false
                    }
                } else {
                    currentField.append(ch)
                }
            } else {
                switch ch {
                case "\"":
                    inQuotes = true
                case ",":
                    currentRow.append(currentField)
                    currentField = ""
                case "\r":
                    let next = content.index(after: i)
                    if next < content.endIndex && content[next] == "\n" {
                        i = content.index(after: i)
                    }
                    fallthrough
                case "\n":
                    currentRow.append(currentField)
                    currentField = ""
                    rows.append(currentRow)
                    currentRow = []
                default:
                    currentField.append(ch)
                }
            }
            i = content.index(after: i)
        }

        // Last field / row
        currentRow.append(currentField)
        if currentRow.contains(where: { !$0.isEmpty }) {
            rows.append(currentRow)
        }

        return rows
    }

    private func parseJSONArray(_ raw: String) -> [String] {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let data = trimmed.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [String]
        else { return [] }
        return arr
    }
}
