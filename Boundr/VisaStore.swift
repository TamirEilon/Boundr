import SwiftUI
import Foundation
import Combine
import FirebaseFirestore

enum VisaEligibility: Equatable {
    case eligible
    case exempt
    case ineligible
}

class VisaStore: ObservableObject {
    @Published var allVisas: [Visa] = []
    @Published var isLoading = true
    @Published var savedVisaIDs: Set<String> = []
    @Published var recentlyViewedIDs: [String] = []
    @Published var user = UserProfile()

    private var cancellables = Set<AnyCancellable>()
    private var currentUID: String?

    init() { loadVisas() }

    // MARK: - Computed

    var eligibleVisas: [Visa]   { allVisas.filter { eligibility($0) == .eligible } }
    var ineligibleVisas: [Visa] { allVisas.filter { eligibility($0) == .ineligible } }
    var exemptVisas: [Visa]     { allVisas.filter { eligibility($0) == .exempt } }
    var savedVisas: [Visa]      { allVisas.filter { savedVisaIDs.contains($0.id) } }
    var recentlyViewedVisas: [Visa] {
        recentlyViewedIDs.compactMap { id in allVisas.first { $0.id == id } }
    }

    var topMatch: Visa? {
        let eligible = eligibleVisas
        let visas = eligible.isEmpty ? allVisas : eligible
        guard !visas.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return visas[day % visas.count]
    }

    var topMatchIsEligible: Bool { !eligibleVisas.isEmpty }

    // MARK: - Eligibility

    private static let EU_EEA_SWISS = ["Austrian","Belgian","Bulgarian","Croatian","Cypriot",
        "Czech","Danish","Dutch","Estonian","Finnish","French","German","Greek","Hungarian",
        "Irish","Italian","Latvian","Lithuanian","Luxembourger","Maltese","Polish","Portuguese",
        "Romanian","Slovak","Slovene","Spanish","Swedish","Norwegian","Icelander",
        "Liechtensteiner","Swiss"]

    private static let exemptMap: [String: [String]] = {
        let eu = EU_EEA_SWISS
        return [

            // ── Electronic Travel Authorisations ─────────────────────────────
            "Canada|eTA (Electronic Travel Authorization)":
                ["American", "Canadian"],
            "Israel|ETA\u{2011}IL (Electronic Travel Authorization)":
                ["Israeli"],
            "New Zealand|NZeTA (New Zealand Electronic Travel Authority)":
                ["New Zealander", "Australian"],
            "South Korea|K-ETA (Korea Electronic Travel Authorization)":
                ["South Korean"],
            "United Kingdom|Electronic Travel Authorisation (ETA)":
                ["British", "Irish"],
            "United States|Electronic System for Travel Authorization (ESTA)":
                ["American", "Canadian"],

            // ── Australia — citizens never need an Australian visa ────────────
            "Australia|eVisitor (subclass 651)":                ["Australian"],
            "Australia|Electronic Travel Authority (ETA) (subclass 601)": ["Australian"],
            "Australia|Working Holiday Visa (417)":             ["Australian"],
            "Australia|Student Visa (Subclass 500)":            ["Australian"],
            "Australia|Skilled Independent Visa (Subclass 189)": ["Australian"],
            "Australia|Temporary Graduate visa (subclass 485)": ["Australian"],

            // ── Canada — citizens don't need their own permits ────────────────
            "Canada|Study Permit":                              ["Canadian"],
            "Canada|Temporary Work Permit":                     ["Canadian"],
            "Canada|International Experience Canada (IEC) - Working Holiday": ["Canadian"],
            "Canada|Post\u{2011}Graduation Work Permit (PGWP)": ["Canadian"],

            // ── Non-EU countries — citizens exempt from own-country visas ────
            "Argentina|Digital Nomad Visa":                     ["Argentine"],
            "Brazil|Work Visa (VITEM V)":                       ["Brazilian"],
            "Chile|Temporary Work Visa":                        ["Chilean"],
            "Costa Rica|Digital Nomad Visa":                    ["Costa Rican"],
            "Japan|Highly Skilled Professional Visa":           ["Japanese"],
            "Japan|Temporary Visitor Visa":                     ["Japanese"],
            "Mexico|Temporary Resident Card (Work)":            ["Mexican"],
            "New Zealand|Skilled Migrant Category Resident Visa": ["New Zealander", "Australian"],
            "Singapore|Employment Pass":                        ["Singaporean"],
            "South Korea|E-7 Skilled Worker Visa":              ["South Korean"],
            "Thailand|Long Term Resident (LTR) Visa - Work from Thailand": ["Thai"],
            "UAE|Employment Visa":                              ["Emirati", "Saudi", "Kuwaiti", "Qatari", "Bahraini", "Omani"],
            "United States|H-1B Specialty Occupation Visa":     ["American"],
            "United States|O\u{2011}1 (US) Extraordinary Ability visa": ["American"],
            "United States|B-2 Tourist Visa":                   ["American", "Canadian"],
            "United States|EB\u{2011}1A (US) Extraordinary Ability immigrant visa": ["American"],

            // ── United Kingdom — British & Irish (Common Travel Area) ─────────
            "United Kingdom|Standard Visitor Visa":             ["British", "Irish"],
            "United Kingdom|Seasonal Worker visa (Temporary Work)": ["British", "Irish"],
            "United Kingdom|Global Talent visa (unsponsored work route)": ["British", "Irish"],
            "United Kingdom|Student Visa":                      ["British", "Irish"],
            "United Kingdom|Innovator Founder visa":            ["British", "Irish"],
            "United Kingdom|Graduate visa (post\u{2011}study work)": ["British", "Irish"],
            "United Kingdom|Health and Care Worker visa":       ["British", "Irish"],
            "United Kingdom|Skilled Worker Visa":               ["British", "Irish"],
            "United Kingdom|Youth Mobility Scheme Visa (Tier 5)": ["British"],
            "United Kingdom|High Potential Individual visa":    ["British", "Irish"],

            // ── EU freedom of movement — EU/EEA/Swiss in EU countries ─────────
            "Austria|Red-White-Red Card":                       eu,
            "Belgium|Single Permit (Combined Residence and Work Permit)": eu,
            "Croatia|Digital Nomad Visa":                       eu,
            "Czech Republic|Employee Card":                     eu,
            "Denmark|Pay Limit Scheme":                         eu,
            "Estonia|Digital Nomad Visa":                       eu,
            "Finland|Residence Permit for an Employee":         eu,
            "France|Autorisation Provisoire de Séjour (APS)":  eu,
            "France|Long-Stay Student Visa (VLS-TS)":           eu,
            "Germany|Residence permit for skilled workers (Section 18a/18b AufenthG)": eu,
            "Germany|EU Blue Card":                             eu,
            "Germany|Residence permit to seek employment after studies/training (Section 20 AufenthG)": eu,
            "Greece|Digital Nomad Visa":                        eu,
            "Ireland|Critical Skills Employment Permit":        eu,
            "Italy|Work Visa (Lavoro Subordinato)":             eu,
            "Malta|Nomad Residence Permit":                     eu,
            "Netherlands|Highly Skilled Migrant Visa":          eu,
            "Netherlands|Working Holiday Visa":                 eu,
            "Poland|Work Permit type A":                        eu,
            "Portugal|Digital Nomad Visa (D8)":                 eu,
            "Portugal|Portugal D2 (Entrepreneur/Independent Professional)": eu,
            "Spain|Highly Qualified Professional (HQP/PAC) residence and work authorization": eu,
            "Spain|Digital Nomad Visa":                         eu,
            "Sweden|Work Permit":                               eu,

            // ── EEA freedom of movement (Iceland, Norway) ─────────────────────
            "Iceland|Long-term Visa for Remote Work":           eu,
            "Norway|Skilled Worker Residence Permit":           eu,

            // ── Switzerland — EU/EFTA free movement agreement ─────────────────
            "Switzerland|B Permit (Residence and Work)":        eu,
            "Switzerland|Work Permit L (Short-term)":           eu,
        ]
    }()

    private static let exemptReasonMap: [String: String] = [

        // Electronic Travel Authorisations
        "Canada|eTA (Electronic Travel Authorization)":
            "US and Canadian citizens are exempt from the eTA and can enter Canada with just their passport.",
        "Israel|ETA\u{2011}IL (Electronic Travel Authorization)":
            "Israeli citizens don't need an ETA to enter their own country — your Israeli passport is all you need.",
        "New Zealand|NZeTA (New Zealand Electronic Travel Authority)":
            "New Zealand and Australian citizens travel freely under the Trans-Tasman Travel Arrangement.",
        "South Korea|K-ETA (Korea Electronic Travel Authorization)":
            "South Korean citizens don't need a K-ETA to enter their own country.",
        "United Kingdom|Electronic Travel Authorisation (ETA)":
            "British and Irish citizens are exempt under the Common Travel Area — no ETA required.",
        "United States|Electronic System for Travel Authorization (ESTA)":
            "US and Canadian citizens don't need ESTA to enter the United States.",

        // Australia
        "Australia|eVisitor (subclass 651)":
            "Australian citizens don't need a visa to enter Australia — your Australian passport is all you need.",
        "Australia|Electronic Travel Authority (ETA) (subclass 601)":
            "Australian citizens don't need an ETA to enter their own country.",
        "Australia|Working Holiday Visa (417)":
            "Australian citizens can live and work in Australia without a Working Holiday Visa.",
        "Australia|Student Visa (Subclass 500)":
            "Australian citizens study as domestic students and don't need an international student visa.",
        "Australia|Skilled Independent Visa (Subclass 189)":
            "Australian citizens already have full residency rights and don't need to apply for a skilled visa.",
        "Australia|Temporary Graduate visa (subclass 485)":
            "Australian citizens can work in Australia after graduation without a graduate visa.",

        // Canada
        "Canada|Study Permit":
            "Canadian citizens can study in Canada without a study permit.",
        "Canada|Temporary Work Permit":
            "Canadian citizens have the right to work in Canada without a permit.",
        "Canada|International Experience Canada (IEC) - Working Holiday":
            "Canadian citizens can live in Canada without the IEC Working Holiday visa.",
        "Canada|Post\u{2011}Graduation Work Permit (PGWP)":
            "Canadian citizens can work in Canada after graduation without a post-study work permit.",

        // Non-EU own-country
        "Argentina|Digital Nomad Visa":
            "Argentine citizens can live and work in Argentina without a digital nomad visa.",
        "Brazil|Work Visa (VITEM V)":
            "Brazilian citizens have the right to work in Brazil without a work visa.",
        "Chile|Temporary Work Visa":
            "Chilean citizens can work in Chile without a temporary work visa.",
        "Costa Rica|Digital Nomad Visa":
            "Costa Rican citizens can live and work in Costa Rica without a digital nomad visa.",
        "Japan|Highly Skilled Professional Visa":
            "Japanese citizens don't need a visa to live and work in Japan.",
        "Japan|Temporary Visitor Visa":
            "Japanese citizens don't need a visitor visa to enter their own country.",
        "Mexico|Temporary Resident Card (Work)":
            "Mexican citizens have the right to live and work in Mexico without a residence card.",
        "New Zealand|Skilled Migrant Category Resident Visa":
            "New Zealand and Australian citizens already hold residence rights under the Trans-Tasman Travel Arrangement and don't need to apply for a skilled migrant visa.",
        "Singapore|Employment Pass":
            "Singaporean citizens can work in Singapore without an Employment Pass.",
        "South Korea|E-7 Skilled Worker Visa":
            "South Korean citizens don't need a work visa to work in their own country.",
        "Thailand|Long Term Resident (LTR) Visa - Work from Thailand":
            "Thai citizens can live and work in Thailand without a long-term resident visa.",
        "UAE|Employment Visa":
            "GCC citizens (UAE, Saudi Arabia, Kuwait, Qatar, Bahrain and Oman) can live and work in any Gulf Cooperation Council state, including the UAE, without an employment visa.",
        "United States|H-1B Specialty Occupation Visa":
            "US citizens can work in the United States without a work visa.",
        "United States|O\u{2011}1 (US) Extraordinary Ability visa":
            "US citizens can work in the United States without a visa.",
        "United States|B-2 Tourist Visa":
            "US and Canadian citizens don't need a tourist visa to visit the United States.",
        "United States|EB\u{2011}1A (US) Extraordinary Ability immigrant visa":
            "US citizens are already permanent residents and don't need an immigrant visa.",

        // United Kingdom — CTA
        "United Kingdom|Standard Visitor Visa":
            "British and Irish citizens can enter the UK freely under the Common Travel Area.",
        "United Kingdom|Seasonal Worker visa (Temporary Work)":
            "British and Irish citizens can work in the UK without a visa under the Common Travel Area.",
        "United Kingdom|Global Talent visa (unsponsored work route)":
            "British and Irish citizens can live and work in the UK without a visa.",
        "United Kingdom|Student Visa":
            "British and Irish citizens can study in the UK without a student visa.",
        "United Kingdom|Innovator Founder visa":
            "British and Irish citizens can start a business in the UK without a visa.",
        "United Kingdom|Graduate visa (post\u{2011}study work)":
            "British and Irish citizens can work in the UK after graduation without a graduate visa.",
        "United Kingdom|Health and Care Worker visa":
            "British and Irish citizens can work in the UK healthcare sector without a visa.",
        "United Kingdom|Skilled Worker Visa":
            "British and Irish citizens can work in the UK without a skilled worker visa.",
        "United Kingdom|Youth Mobility Scheme Visa (Tier 5)":
            "British citizens don't need a Youth Mobility visa to live in the UK.",
        "United Kingdom|High Potential Individual visa":
            "British and Irish citizens can live and work in the UK without a visa.",

        // EU freedom of movement
        "Austria|Red-White-Red Card":
            "As an EU/EEA/Swiss citizen, you can live and work in Austria freely — no permit required.",
        "Belgium|Single Permit (Combined Residence and Work Permit)":
            "As an EU/EEA/Swiss citizen, you can live and work in Belgium freely — no permit required.",
        "Croatia|Digital Nomad Visa":
            "As an EU/EEA/Swiss citizen, you have freedom of movement in Croatia — no digital nomad visa needed.",
        "Czech Republic|Employee Card":
            "As an EU/EEA/Swiss citizen, you can work in the Czech Republic freely — no employee card required.",
        "Denmark|Pay Limit Scheme":
            "As an EU/EEA/Swiss citizen, you can live and work in Denmark freely — no permit required.",
        "Estonia|Digital Nomad Visa":
            "As an EU/EEA/Swiss citizen, you have freedom of movement in Estonia — no digital nomad visa needed.",
        "Finland|Residence Permit for an Employee":
            "As an EU/EEA/Swiss citizen, you can live and work in Finland freely — no permit required.",
        "France|Autorisation Provisoire de Séjour (APS)":
            "As an EU/EEA/Swiss citizen, you can work in France after graduation without an APS.",
        "France|Long-Stay Student Visa (VLS-TS)":
            "As an EU/EEA/Swiss citizen, you can study in France without a long-stay visa.",
        "Germany|Residence permit for skilled workers (Section 18a/18b AufenthG)":
            "As an EU/EEA/Swiss citizen, you can live and work in Germany freely — no residence permit required.",
        "Germany|EU Blue Card":
            "As an EU/EEA/Swiss citizen, you have the right to live and work in Germany without a visa.",
        "Germany|Residence permit to seek employment after studies/training (Section 20 AufenthG)":
            "As an EU/EEA/Swiss citizen, you can stay in Germany to look for work without a special permit.",
        "Greece|Digital Nomad Visa":
            "As an EU/EEA/Swiss citizen, you have freedom of movement in Greece — no digital nomad visa needed.",
        "Ireland|Critical Skills Employment Permit":
            "As an EU/EEA/Swiss citizen, you have the right to work in Ireland without a permit.",
        "Italy|Work Visa (Lavoro Subordinato)":
            "As an EU/EEA/Swiss citizen, you can live and work in Italy freely — no work visa required.",
        "Malta|Nomad Residence Permit":
            "As an EU/EEA/Swiss citizen, you have the right to live and work freely in Malta — no visa required.",
        "Netherlands|Highly Skilled Migrant Visa":
            "As an EU/EEA/Swiss citizen, you can live and work in the Netherlands freely — no permit required.",
        "Netherlands|Working Holiday Visa":
            "As an EU/EEA/Swiss citizen, you can live and work in the Netherlands freely — no Working Holiday visa needed.",
        "Poland|Work Permit type A":
            "As an EU/EEA/Swiss citizen, you can live and work in Poland freely — no work permit required.",
        "Portugal|Digital Nomad Visa (D8)":
            "As an EU/EEA/Swiss citizen, you have the right to live and work in Portugal without a visa.",
        "Portugal|Portugal D2 (Entrepreneur/Independent Professional)":
            "As an EU/EEA/Swiss citizen, you can work as an entrepreneur in Portugal without a visa.",
        "Spain|Highly Qualified Professional (HQP/PAC) residence and work authorization":
            "As an EU/EEA/Swiss citizen, you can live and work in Spain freely — no authorisation required.",
        "Spain|Digital Nomad Visa":
            "As an EU/EEA/Swiss citizen, you have the right to live and work in Spain without a visa.",
        "Sweden|Work Permit":
            "As an EU/EEA/Swiss citizen, you can live and work in Sweden freely — no work permit required.",
        "Iceland|Long-term Visa for Remote Work":
            "As an EU/EEA/Swiss citizen, you have freedom of movement in Iceland under the EEA Agreement.",
        "Norway|Skilled Worker Residence Permit":
            "As an EU/EEA/Swiss citizen, you can live and work in Norway freely under the EEA Agreement.",
        "Switzerland|B Permit (Residence and Work)":
            "As an EU/EEA/Swiss citizen, you can live and work in Switzerland under the free movement agreement.",
        "Switzerland|Work Permit L (Short-term)":
            "As an EU/EEA/Swiss citizen, you can work in Switzerland short-term under the free movement agreement.",
    ]

    func exemptNationalities(for visa: Visa) -> [String] {
        Self.exemptMap["\(visa.country)|\(visa.visaName)"] ?? []
    }

    func exemptReason(for visa: Visa) -> String? {
        Self.exemptReasonMap["\(visa.country)|\(visa.visaName)"]
    }

    func eligibility(_ visa: Visa) -> VisaEligibility {
        let exempt = exemptNationalities(for: visa)
        let exemptSet = Set(exempt)

        // Exempt always wins — if any passport exempts the user, they don't need this visa
        if !exemptSet.isEmpty, user.nationalities.contains(where: { exemptSet.contains($0) }) {
            return .exempt
        }

        let nationalityOK = visa.eligibleNationalities.isEmpty
            || user.nationalities.contains(where: { visa.eligibleNationalities.contains($0) })
        let ageOK: Bool = {
            if let min = visa.minAge, user.age > 0, user.age < min { return false }
            if let max = visa.maxAge, user.age > 0, user.age > max { return false }
            return true
        }()
        let educationOK = visa.requiredEducation.isEmpty || user.educationLevel.isEmpty
            || visa.requiredEducation.contains(user.educationLevel)
        let occupationOK: Bool = {
            guard let req = visa.requiredOccupation, !req.isEmpty, !user.occupation.isEmpty else { return true }
            let u = user.occupation.lowercased(), r = req.lowercased()
            return u.contains(r) || r.contains(u)
        }()

        if nationalityOK && ageOK && educationOK && occupationOK { return .eligible }
        return .ineligible
    }

    func isEligible(_ visa: Visa) -> Bool { eligibility(visa) == .eligible }

    func ineligibilityReasons(for visa: Visa) -> [String] {
        var reasons: [String] = []
        if !visa.eligibleNationalities.isEmpty,
           !user.nationalities.contains(where: { visa.eligibleNationalities.contains($0) }) {
            reasons.append("Your nationality is not eligible for this visa")
        }
        if let min = visa.minAge, user.age > 0, user.age < min {
            reasons.append("Minimum age for this visa is \(min)")
        }
        if let max = visa.maxAge, user.age > 0, user.age > max {
            reasons.append("Maximum age for this visa is \(max)")
        }
        if !visa.requiredEducation.isEmpty, !user.educationLevel.isEmpty,
           !visa.requiredEducation.contains(user.educationLevel) {
            reasons.append("Your education level doesn't meet the requirement")
        }
        if let requiredOcc = visa.requiredOccupation, !requiredOcc.isEmpty,
           !user.occupation.isEmpty {
            let userOcc = user.occupation.lowercased()
            let reqOcc  = requiredOcc.lowercased()
            if !userOcc.contains(reqOcc) && !reqOcc.contains(userOcc) {
                reasons.append("Your occupation doesn't match the requirement")
            }
        }
        return reasons
    }

    func recordView(_ visa: Visa) {
        recentlyViewedIDs.removeAll { $0 == visa.id }
        recentlyViewedIDs.insert(visa.id, at: 0)
        if recentlyViewedIDs.count > 10 { recentlyViewedIDs = Array(recentlyViewedIDs.prefix(10)) }
        if let uid = currentUID { saveRecentlyViewed(for: uid) }
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

    func reset() {
        cancellables.removeAll()
        currentUID = nil
        user = UserProfile()
        savedVisaIDs = []
        recentlyViewedIDs = []
    }

    func loadProfile(for uid: String) {
        // Always reset first so no stale data from a previous user bleeds through
        reset()
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
        let recentKey = "recentlyViewed_\(uid)"
        if let data = UserDefaults.standard.data(forKey: recentKey),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            recentlyViewedIDs = saved
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

    private func saveRecentlyViewed(for uid: String) {
        if let data = try? JSONEncoder().encode(recentlyViewedIDs) {
            UserDefaults.standard.set(data, forKey: "recentlyViewed_\(uid)")
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

    // MARK: - Firestore Loading

    private func loadVisas() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("visas").getDocuments { [weak self] snapshot, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if let docs = snapshot?.documents, !docs.isEmpty {
                    self.allVisas = docs.compactMap { self.visa(from: $0) }
                } else {
                    self.allVisas = Self.bundledVisas
                }
                self.isLoading = false
            }
        }
    }

    private func visa(from doc: QueryDocumentSnapshot) -> Visa? {
        let d = doc.data()
        guard let country = d["country"] as? String, !country.isEmpty else { return nil }
        return Visa(
            id:                    doc.documentID,
            country:               country,
            visaType:              d["visa_type"]              as? String   ?? "",
            visaName:              d["visa_name"]              as? String   ?? "",
            description:           d["description"]            as? String   ?? "",
            duration:              d["duration"]               as? String   ?? "",
            processingTime:        d["processing_time"]        as? String   ?? "",
            cost:                  d["cost"]                   as? String   ?? "",
            requirements:          d["requirements"]           as? [String] ?? [],
            eligibleNationalities: d["eligible_nationalities"] as? [String] ?? [],
            minAge:                d["min_age"]                as? Int,
            maxAge:                d["max_age"]                as? Int,
            requiredOccupation:    d["required_occupation"]    as? String,
            requiredEducation:     d["required_education"]     as? [String] ?? [],
            applicationURL:        d["application_url"]        as? String   ?? ""
        )
    }
}
