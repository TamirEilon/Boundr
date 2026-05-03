import SwiftUI
import Foundation
import Combine

class VisaStore: ObservableObject {
    @Published var allVisas: [Visa] = []
    @Published var savedVisaIDs: Set<String> = []
    @Published var user = UserProfile()

    private var cancellables = Set<AnyCancellable>()
    private var currentUID: String?

    init() { loadVisas() }

    // MARK: - Computed

    var eligibleVisas: [Visa]   { allVisas.filter { isEligible($0) } }
    var ineligibleVisas: [Visa] { allVisas.filter { !isEligible($0) } }
    var savedVisas: [Visa]      { allVisas.filter { savedVisaIDs.contains($0.id) } }
    var topMatch: Visa?         { eligibleVisas.first }

    // MARK: - Eligibility

    func isEligible(_ visa: Visa) -> Bool {
        // 1. Nationality: at least one of the user's nationalities must be in the list
        if !visa.eligibleNationalities.isEmpty,
           !user.nationalities.contains(where: { visa.eligibleNationalities.contains($0) }) {
            return false
        }

        // 2. Age bounds
        if let min = visa.minAge, user.age > 0, user.age < min { return false }
        if let max = visa.maxAge, user.age > 0, user.age > max { return false }

        // 3. Education: user's level must be in the accepted list
        if !visa.requiredEducation.isEmpty, !user.educationLevel.isEmpty,
           !visa.requiredEducation.contains(user.educationLevel) {
            return false
        }

        // 4. Occupation: if visa specifies one, user's occupation must match (case-insensitive)
        if let requiredOcc = visa.requiredOccupation, !requiredOcc.isEmpty,
           !user.occupation.isEmpty {
            let userOcc = user.occupation.lowercased()
            let reqOcc  = requiredOcc.lowercased()
            if !userOcc.contains(reqOcc) && !reqOcc.contains(userOcc) { return false }
        }

        return true
    }

    func isSaved(_ visa: Visa) -> Bool { savedVisaIDs.contains(visa.id) }

    func toggleSaved(_ visa: Visa) {
        if savedVisaIDs.contains(visa.id) {
            savedVisaIDs.remove(visa.id)
        } else {
            savedVisaIDs.insert(visa.id)
        }
        if let uid = currentUID { saveFavourites(for: uid) }
    }

    // MARK: - Persistence

    func loadProfile(for uid: String) {
        currentUID = uid
        let key = "profile_\(uid)"
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            user = saved
        }
        let favKey = "favourites_\(uid)"
        if let data = UserDefaults.standard.data(forKey: favKey),
           let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
            savedVisaIDs = saved
        }
        startAutoSave(uid: uid)
    }

    func saveProfile(for uid: String) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "profile_\(uid)")
        }
    }

    private func saveFavourites(for uid: String) {
        if let data = try? JSONEncoder().encode(savedVisaIDs) {
            UserDefaults.standard.set(data, forKey: "favourites_\(uid)")
        }
    }

    private func startAutoSave(uid: String) {
        cancellables.removeAll()
        $user
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveProfile(for: uid) }
            .store(in: &cancellables)
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
                case "\"": inQuotes = true
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
