import SwiftUI

// MARK: - Visa Model

struct Visa: Identifiable, Hashable {
    let id: String
    let country: String
    let visaType: String
    let visaName: String
    let description: String
    let duration: String
    let processingTime: String
    let cost: String
    let requirements: [String]
    let eligibleNationalities: [String]
    let minAge: Int?
    let maxAge: Int?
    let requiredOccupation: String?
    let requiredEducation: [String]
    let applicationURL: String

    var countryCode: String { CountryUtils.code(for: country) }
    var badgeColor: Color { CountryUtils.badgeColor(for: country) }
    var region: String { CountryUtils.region(for: country) }

    var visaTypeDisplay: String {
        switch visaType {
        case "digital_nomad": return "Digital Nomad"
        case "tourist":       return "Tourist"
        case "work":          return "Work"
        case "student":       return "Student"
        case "retirement":    return "Retirement"
        default:              return visaType.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    var visaTypeColor: Color {
        switch visaType {
        case "digital_nomad": return .blue
        case "tourist":       return .green
        case "work":          return .orange
        case "student":       return .purple
        case "retirement":    return .pink
        default:              return .gray
        }
    }
}

// MARK: - UserProfile

struct UserProfile: Codable {
    var fullName: String = ""
    var nationalities: [String] = []
    var age: Int = 0
    var homeCountry: String = "United States"
    var educationLevel: String = ""
    var occupation: String = ""
    var languages: String = ""
    var experienceYears: Int = 0
    var relationshipStatus: String = "single"
    var numberOfKids: Int = 0

    // Computed — excluded from Codable automatically
    var nationality: String { nationalities.first ?? "" }
    var firstName: String { fullName.components(separatedBy: " ").first ?? fullName }

    var educationDisplay: String {
        switch educationLevel {
        case "high_school": return "High School"
        case "bachelors":   return "Bachelor's degree"
        case "masters":     return "Master's degree"
        case "phd":         return "PhD"
        default:            return educationLevel.capitalized
        }
    }

    var maritalStatusDisplay: String {
        switch relationshipStatus {
        case "single":   return "Single"
        case "married":  return "Married"
        case "divorced": return "Divorced"
        case "widowed":  return "Widowed"
        default:         return relationshipStatus.capitalized
        }
    }
}

// MARK: - CountryUtils

enum CountryUtils {
    static func code(for country: String) -> String {
        codes[country] ?? String(country.prefix(2)).uppercased()
    }

    static func region(for country: String) -> String {
        if europe.contains(country)     { return "Europe" }
        if americas.contains(country)   { return "Americas" }
        if asia.contains(country)       { return "Asia" }
        if oceania.contains(country)    { return "Oceania" }
        if middleEast.contains(country) { return "Middle East" }
        return "Other"
    }

    static func imageURL(for country: String) -> URL? {
        guard let id = photoIDs[country] else { return nil }
        return URL(string: "https://images.unsplash.com/\(id)?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80")
    }

    private static let photoIDs: [String: String] = [
        // Europe
        "Portugal":         "photo-1555881400-74d7acaacd8b",
        "Spain":            "photo-1543783207-ec64e4d95325",
        "Germany":          "photo-1467269204594-9661b134dd2b",
        "Netherlands":      "photo-1512470876302-972faa2aa9a4",
        "Sweden":           "photo-1509356843151-3e7d96241e11",
        "Ireland":          "photo-1590089415225-401ed6f9db8e",
        "United Kingdom":   "photo-1513635269975-59663e0ac1ad",
        "France":           "photo-1502602898657-3e91760cbb34",
        "Italy":            "photo-1529260830199-42c24126f198",
        "Greece":           "photo-1533105079780-92b9be482077",
        "Switzerland":      "photo-1527668752968-14dc70a27c95",
        "Malta":            "photo-1514890547357-a9ee288728e0",
        "Austria":          "photo-1520675746836-92b1c1d267ad",
        "Belgium":          "photo-1491557345352-5929e343eb89",
        "Czech Republic":   "photo-1541849546-216549ae216d",
        "Poland":           "photo-1563177978-4c5ffc081b2a",
        "Croatia":          "photo-1767026054594-fbd20c8d4a34",
        "Norway":           "photo-1544085311-11a028465b03",
        "Denmark":          "photo-1513622470522-26c3c8a854bc",
        "Finland":          "photo-1578054320988-a2ac16f42591",
        "Estonia":          "photo-1634937810870-4ce3744c3a42",
        "Iceland":          "photo-1504829857797-ddff29c27927",
        "Hungary":          "photo-1504016798967-7a462f730c38",
        "Romania":          "photo-1562566861-5ba35d8c4889",
        "Luxembourg":       "photo-1585208798174-6cedd4454a8c",
        // Americas
        "United States":    "photo-1485738422979-f5c462d49f74",
        "Canada":           "photo-1517935706615-2717063c2225",
        "Mexico":           "photo-1518638150340-f706e86654de",
        "Brazil":           "photo-1483729558449-99ef09a8c325",
        "Argentina":        "photo-1612294037637-ec328d0e075e",
        "Costa Rica":       "photo-1611223156134-07ade11dfe6a",
        "Colombia":         "photo-1591604466107-ec97de577aff",
        "Chile":            "photo-1464822759023-fed622ff2c3b",
        "Peru":             "photo-1526392060635-9d6019884377",
        "Panama":           "photo-1554795080-0b4a5db2f1dc",
        // Asia
        "Japan":            "photo-1528360983277-13d401cdc186",
        "Singapore":        "photo-1525625293386-3f8f99389edd",
        "South Korea":      "photo-1583833008338-31a6657917ab",
        "Thailand":         "photo-1528181304800-259b08848526",
        "India":            "photo-1524492412937-b28074a5d7da",
        "Vietnam":          "photo-1557750255-c76072a7aad1",
        "Indonesia":        "photo-1537996194471-e657df975ab4",
        "Malaysia":         "photo-1596422846543-75c6fc197f11",
        "Philippines":      "photo-1565791380713-1756b9a05343",
        "Taiwan":           "photo-1563729784474-d77dbb933a9e",
        "China":            "photo-1508804185872-d7badad00f7d",
        "Nepal":            "photo-1544735716-392fe2489ffa",
        "Sri Lanka":        "photo-1540448051910-09cfadd5df61",
        // Oceania
        "Australia":        "photo-1624138784614-87fd1b6528f8",
        "New Zealand":      "photo-1507699622108-4be3abd695ad",
        "Fiji":             "photo-1548574505-5e239809ee19",
        // Middle East
        "UAE":              "photo-1512453979798-5ea266f8880c",
        "United Arab Emirates": "photo-1512453979798-5ea266f8880c",
        "Israel":           "photo-1547483029-77784da27709",
        "Turkey":           "photo-1524231757912-21f4fe3a7200",
        "Jordan":           "photo-1548786811-dd6e453ccca7",
        "Morocco":          "photo-1489749798305-4fea3ae63d43",
        "Egypt":            "photo-1539768942893-daf53e448371",
        "Qatar":            "photo-1548605522-c8fa15bc8e4a",
        "Saudi Arabia":     "photo-1586724237569-f3d0c1dee8c6",
        // Africa
        "South Africa":     "photo-1516026672322-bc52d61a55d5",
        "Kenya":            "photo-1547471080-7cc2caa01a7e",
        "Nigeria":          "photo-1618516976736-3b77d7c28193",
        "Ethiopia":         "photo-1580060839134-75a5edca2e99",
        "Ghana":            "photo-1629739885594-96b3e5a4b8c4",
    ]

    static func badgeColor(for country: String) -> Color {
        switch region(for: country) {
        case "Europe":      return Color(red: 0.72, green: 0.76, blue: 0.92)
        case "Americas":    return Color(red: 0.72, green: 0.92, blue: 0.78)
        case "Asia":        return Color(red: 0.95, green: 0.88, blue: 0.72)
        case "Oceania":     return Color(red: 0.72, green: 0.90, blue: 0.92)
        case "Middle East": return Color(red: 0.92, green: 0.78, blue: 0.92)
        default:            return Color(red: 0.90, green: 0.80, blue: 0.75)
        }
    }

    private static let europe: Set<String> = [
        "Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina",
        "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia",
        "Finland", "France", "Germany", "Greece", "Hungary", "Iceland", "Ireland",
        "Italy", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg",
        "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "North Macedonia",
        "Norway", "Poland", "Portugal", "Romania", "Russia", "San Marino", "Serbia",
        "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine",
        "United Kingdom", "Vatican"
    ]
    private static let americas: Set<String> = [
        "Antigua and Barbuda", "Argentina", "Bahamas", "Barbados", "Belize",
        "Bolivia", "Brazil", "Canada", "Chile", "Colombia", "Costa Rica", "Cuba",
        "Dominica", "Dominican Republic", "Ecuador", "El Salvador", "Grenada",
        "Guatemala", "Guyana", "Haiti", "Honduras", "Jamaica", "Mexico", "Nicaragua",
        "Panama", "Paraguay", "Peru", "Saint Kitts and Nevis", "Saint Lucia",
        "Saint Vincent and the Grenadines", "Suriname", "Trinidad and Tobago",
        "United States", "Uruguay", "Venezuela"
    ]
    private static let asia: Set<String> = [
        "Afghanistan", "Armenia", "Azerbaijan", "Bangladesh", "Bhutan", "Brunei",
        "Cambodia", "China", "Georgia", "India", "Indonesia", "Japan", "Kazakhstan",
        "Kyrgyzstan", "Laos", "Malaysia", "Maldives", "Mongolia", "Myanmar", "Nepal",
        "North Korea", "Pakistan", "Philippines", "Singapore", "South Korea",
        "Sri Lanka", "Taiwan", "Tajikistan", "Thailand", "Timor-Leste", "Turkmenistan",
        "Uzbekistan", "Vietnam"
    ]
    private static let oceania: Set<String> = [
        "Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia", "Nauru",
        "New Zealand", "Palau", "Papua New Guinea", "Samoa", "Solomon Islands",
        "Tonga", "Tuvalu", "Vanuatu"
    ]
    private static let middleEast: Set<String> = [
        "Bahrain", "Egypt", "Iran", "Iraq", "Israel", "Jordan", "Kuwait", "Lebanon",
        "Libya", "Oman", "Qatar", "Saudi Arabia", "Syria", "Turkey", "UAE",
        "United Arab Emirates", "Yemen"
    ]

    private static let codes: [String: String] = [
        "Afghanistan": "AF", "Albania": "AL", "Algeria": "DZ", "Andorra": "AD",
        "Angola": "AO", "Argentina": "AR", "Armenia": "AM", "Australia": "AU",
        "Austria": "AT", "Azerbaijan": "AZ", "Bahrain": "BH", "Bangladesh": "BD",
        "Belarus": "BY", "Belgium": "BE", "Belize": "BZ", "Bolivia": "BO",
        "Bosnia and Herzegovina": "BA", "Botswana": "BW", "Brazil": "BR",
        "Brunei": "BN", "Bulgaria": "BG", "Cambodia": "KH", "Cameroon": "CM",
        "Canada": "CA", "Chile": "CL", "China": "CN", "Colombia": "CO",
        "Costa Rica": "CR", "Croatia": "HR", "Cuba": "CU", "Cyprus": "CY",
        "Czech Republic": "CZ", "Denmark": "DK", "Ecuador": "EC", "Egypt": "EG",
        "Estonia": "EE", "Ethiopia": "ET", "Finland": "FI", "France": "FR",
        "Germany": "DE", "Ghana": "GH", "Greece": "GR", "Guatemala": "GT",
        "Honduras": "HN", "Hungary": "HU", "Iceland": "IS", "India": "IN",
        "Indonesia": "ID", "Iran": "IR", "Iraq": "IQ", "Ireland": "IE",
        "Israel": "IL", "Italy": "IT", "Jamaica": "JM", "Japan": "JP",
        "Jordan": "JO", "Kazakhstan": "KZ", "Kenya": "KE", "Kuwait": "KW",
        "Kyrgyzstan": "KG", "Latvia": "LV", "Lebanon": "LB", "Libya": "LY",
        "Lithuania": "LT", "Luxembourg": "LU", "Malaysia": "MY", "Malta": "MT",
        "Mexico": "MX", "Moldova": "MD", "Monaco": "MC", "Mongolia": "MN",
        "Montenegro": "ME", "Morocco": "MA", "Mozambique": "MZ", "Myanmar": "MM",
        "Nepal": "NP", "Netherlands": "NL", "New Zealand": "NZ", "Nicaragua": "NI",
        "Nigeria": "NG", "Norway": "NO", "Oman": "OM", "Pakistan": "PK",
        "Panama": "PA", "Paraguay": "PY", "Peru": "PE", "Philippines": "PH",
        "Poland": "PL", "Portugal": "PT", "Qatar": "QA", "Romania": "RO",
        "Russia": "RU", "Rwanda": "RW", "Saudi Arabia": "SA", "Senegal": "SN",
        "Serbia": "RS", "Singapore": "SG", "Slovakia": "SK", "Slovenia": "SI",
        "South Africa": "ZA", "South Korea": "KR", "Spain": "ES", "Sri Lanka": "LK",
        "Sudan": "SD", "Sweden": "SE", "Switzerland": "CH", "Syria": "SY",
        "Taiwan": "TW", "Tanzania": "TZ", "Thailand": "TH", "Tunisia": "TN",
        "Turkey": "TR", "UAE": "AE", "Uganda": "UG", "Ukraine": "UA",
        "United Kingdom": "GB", "United States": "US", "Uruguay": "UY",
        "Uzbekistan": "UZ", "Venezuela": "VE", "Vietnam": "VN", "Yemen": "YE",
        "Zambia": "ZM", "Zimbabwe": "ZW"
    ]
}
