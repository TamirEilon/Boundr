import SwiftUI
import FirebaseAuth

// Wraps child views onto new rows when they exceed available width
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for subview in subviews {
            let s = subview.sizeThatFits(.unspecified)
            if x + s.width > maxW, x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: maxW, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for subview in subviews {
            let s = subview.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var store: VisaStore
    @EnvironmentObject var auth: AuthManager

    @State private var step = 0

    // Collected answers
    @State private var selectedNationalities: Set<String> = []
    @State private var countrySearch = ""
    @State private var residenceCountry = ""
    @State private var residenceSearch = ""
    @State private var age: Double     = 28
    @State private var education       = "masters"
    @State private var occupation      = "Software Engineer"
    @State private var otherOccupation = ""
    @State private var experience: Double = 4
    @State private var relationshipStatus = "single"
    @State private var numberOfKids = 0

    private let totalSteps = 8

    private var firstName: String {
        auth.currentUser?.displayName?.components(separatedBy: " ").first ?? "there"
    }

    // Occupations where "years of experience" is irrelevant
    private var skipsExperience: Bool {
        ["Retired", "Student", "Founder / Self-employed"].contains(occupation)
    }

    private var canAdvance: Bool {
        switch step {
        case 0: return !selectedNationalities.isEmpty
        case 1: return !residenceCountry.isEmpty
        case 4: return occupation != "Other" || !otherOccupation.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button {
                        if step > 0 {
                            // Skip experience step (5) going back when it's irrelevant
                            if step == 6 && skipsExperience {
                                withAnimation { step = 4 }
                            } else {
                                withAnimation { step -= 1 }
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 38, height: 38)
                            .background(Color(.systemGray6), in: Circle())
                    }
                    .opacity(step == 0 ? 0 : 1)

                    Spacer()
                    progressDots
                    Spacer()
                    // Skip button — only on non-critical steps
                    if [3, 4, 5, 6].contains(step) {
                        Button { advance() } label: {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 48, height: 38)
                        }
                    } else {
                        Color.clear.frame(width: 48, height: 38)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        switch step {
                        case 0: nationalityStep
                        case 1: residenceStep
                        case 2: ageStep
                        case 3: educationStep
                        case 4: occupationStep
                        case 5: experienceStep
                        case 6: maritalStatusStep
                        default: summaryStep
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 120)
                }
            }

            // Bottom button
            VStack(spacing: 0) {
                Button { advance() } label: {
                    HStack(spacing: 8) {
                        Text(step == totalSteps - 1 ? "See my matches" : "Continue")
                            .font(.subheadline).fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(canAdvance ? Color.black : Color(.systemGray4))
                    .cornerRadius(16)
                }
                .disabled(!canAdvance)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(.regularMaterial)
        }
    }

    // MARK: - Progress dots

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                if i == step {
                    Capsule().fill(Color.black).frame(width: 22, height: 7)
                } else if i < step {
                    Circle().fill(Color.black.opacity(0.35)).frame(width: 7, height: 7)
                } else {
                    Circle().fill(Color(.systemGray4)).frame(width: 7, height: 7)
                }
            }
        }
    }

    // MARK: - Step 1: Nationality

    private let countries: [(code: String, name: String, nationality: String)] = [
        ("AF", "Afghanistan",           "Afghan"),
        ("AL", "Albania",               "Albanian"),
        ("DZ", "Algeria",               "Algerian"),
        ("AD", "Andorra",               "Andorran"),
        ("AO", "Angola",                "Angolan"),
        ("AG", "Antigua & Barbuda",     "Antiguan"),
        ("AR", "Argentina",             "Argentine"),
        ("AM", "Armenia",               "Armenian"),
        ("AU", "Australia",             "Australian"),
        ("AT", "Austria",               "Austrian"),
        ("AZ", "Azerbaijan",            "Azerbaijani"),
        ("BS", "Bahamas",               "Bahamian"),
        ("BH", "Bahrain",               "Bahraini"),
        ("BD", "Bangladesh",            "Bangladeshi"),
        ("BB", "Barbados",              "Barbadian"),
        ("BY", "Belarus",               "Belarusian"),
        ("BE", "Belgium",               "Belgian"),
        ("BZ", "Belize",                "Belizean"),
        ("BJ", "Benin",                 "Beninese"),
        ("BT", "Bhutan",                "Bhutanese"),
        ("BO", "Bolivia",               "Bolivian"),
        ("BA", "Bosnia & Herzegovina",  "Bosnian"),
        ("BW", "Botswana",              "Botswanan"),
        ("BR", "Brazil",                "Brazilian"),
        ("BN", "Brunei",                "Bruneian"),
        ("BG", "Bulgaria",              "Bulgarian"),
        ("BF", "Burkina Faso",          "Burkinabé"),
        ("BI", "Burundi",               "Burundian"),
        ("KH", "Cambodia",              "Cambodian"),
        ("CM", "Cameroon",              "Cameroonian"),
        ("CA", "Canada",                "Canadian"),
        ("CV", "Cape Verde",            "Cape Verdean"),
        ("CF", "Central African Rep.",  "Central African"),
        ("TD", "Chad",                  "Chadian"),
        ("CL", "Chile",                 "Chilean"),
        ("CN", "China",                 "Chinese"),
        ("CO", "Colombia",              "Colombian"),
        ("KM", "Comoros",               "Comorian"),
        ("CD", "DR Congo",              "Congolese"),
        ("CG", "Republic of Congo",     "Congolese"),
        ("CR", "Costa Rica",            "Costa Rican"),
        ("HR", "Croatia",               "Croatian"),
        ("CU", "Cuba",                  "Cuban"),
        ("CY", "Cyprus",                "Cypriot"),
        ("CZ", "Czech Republic",        "Czech"),
        ("DK", "Denmark",               "Danish"),
        ("DJ", "Djibouti",              "Djiboutian"),
        ("DM", "Dominica",              "Dominican"),
        ("DO", "Dominican Republic",    "Dominican"),
        ("EC", "Ecuador",               "Ecuadorian"),
        ("EG", "Egypt",                 "Egyptian"),
        ("SV", "El Salvador",           "Salvadoran"),
        ("GQ", "Equatorial Guinea",     "Equatoguinean"),
        ("ER", "Eritrea",               "Eritrean"),
        ("EE", "Estonia",               "Estonian"),
        ("SZ", "Eswatini",              "Swazi"),
        ("ET", "Ethiopia",              "Ethiopian"),
        ("FJ", "Fiji",                  "Fijian"),
        ("FI", "Finland",               "Finnish"),
        ("FR", "France",                "French"),
        ("GA", "Gabon",                 "Gabonese"),
        ("GM", "Gambia",                "Gambian"),
        ("GE", "Georgia",               "Georgian"),
        ("DE", "Germany",               "German"),
        ("GH", "Ghana",                 "Ghanaian"),
        ("GR", "Greece",                "Greek"),
        ("GD", "Grenada",               "Grenadian"),
        ("GT", "Guatemala",             "Guatemalan"),
        ("GN", "Guinea",                "Guinean"),
        ("GW", "Guinea-Bissau",         "Bissau-Guinean"),
        ("GY", "Guyana",                "Guyanese"),
        ("HT", "Haiti",                 "Haitian"),
        ("HN", "Honduras",              "Honduran"),
        ("HU", "Hungary",               "Hungarian"),
        ("IS", "Iceland",               "Icelandic"),
        ("IN", "India",                 "Indian"),
        ("ID", "Indonesia",             "Indonesian"),
        ("IR", "Iran",                  "Iranian"),
        ("IQ", "Iraq",                  "Iraqi"),
        ("IE", "Ireland",               "Irish"),
        ("IL", "Israel",                "Israeli"),
        ("IT", "Italy",                 "Italian"),
        ("JM", "Jamaica",               "Jamaican"),
        ("JP", "Japan",                 "Japanese"),
        ("JO", "Jordan",                "Jordanian"),
        ("KZ", "Kazakhstan",            "Kazakhstani"),
        ("KE", "Kenya",                 "Kenyan"),
        ("KI", "Kiribati",              "I-Kiribati"),
        ("KW", "Kuwait",                "Kuwaiti"),
        ("KG", "Kyrgyzstan",            "Kyrgyz"),
        ("LA", "Laos",                  "Lao"),
        ("LV", "Latvia",                "Latvian"),
        ("LB", "Lebanon",               "Lebanese"),
        ("LS", "Lesotho",               "Basotho"),
        ("LR", "Liberia",               "Liberian"),
        ("LY", "Libya",                 "Libyan"),
        ("LI", "Liechtenstein",         "Liechtensteiner"),
        ("LT", "Lithuania",             "Lithuanian"),
        ("LU", "Luxembourg",            "Luxembourgish"),
        ("MG", "Madagascar",            "Malagasy"),
        ("MW", "Malawi",                "Malawian"),
        ("MY", "Malaysia",              "Malaysian"),
        ("MV", "Maldives",              "Maldivian"),
        ("ML", "Mali",                  "Malian"),
        ("MT", "Malta",                 "Maltese"),
        ("MH", "Marshall Islands",      "Marshallese"),
        ("MR", "Mauritania",            "Mauritanian"),
        ("MU", "Mauritius",             "Mauritian"),
        ("MX", "Mexico",                "Mexican"),
        ("FM", "Micronesia",            "Micronesian"),
        ("MD", "Moldova",               "Moldovan"),
        ("MC", "Monaco",                "Monégasque"),
        ("MN", "Mongolia",              "Mongolian"),
        ("ME", "Montenegro",            "Montenegrin"),
        ("MA", "Morocco",               "Moroccan"),
        ("MZ", "Mozambique",            "Mozambican"),
        ("MM", "Myanmar",               "Burmese"),
        ("NA", "Namibia",               "Namibian"),
        ("NR", "Nauru",                 "Nauruan"),
        ("NP", "Nepal",                 "Nepali"),
        ("NL", "Netherlands",           "Dutch"),
        ("NZ", "New Zealand",           "New Zealander"),
        ("NI", "Nicaragua",             "Nicaraguan"),
        ("NE", "Niger",                 "Nigerien"),
        ("NG", "Nigeria",               "Nigerian"),
        ("MK", "North Macedonia",       "Macedonian"),
        ("NO", "Norway",                "Norwegian"),
        ("OM", "Oman",                  "Omani"),
        ("PK", "Pakistan",              "Pakistani"),
        ("PW", "Palau",                 "Palauan"),
        ("PA", "Panama",                "Panamanian"),
        ("PG", "Papua New Guinea",      "Papua New Guinean"),
        ("PY", "Paraguay",              "Paraguayan"),
        ("PE", "Peru",                  "Peruvian"),
        ("PH", "Philippines",           "Filipino"),
        ("PL", "Poland",                "Polish"),
        ("PT", "Portugal",              "Portuguese"),
        ("QA", "Qatar",                 "Qatari"),
        ("RO", "Romania",               "Romanian"),
        ("RU", "Russia",                "Russian"),
        ("RW", "Rwanda",                "Rwandan"),
        ("KN", "Saint Kitts & Nevis",   "Kittitian"),
        ("LC", "Saint Lucia",           "Saint Lucian"),
        ("VC", "Saint Vincent",         "Vincentian"),
        ("WS", "Samoa",                 "Samoan"),
        ("SM", "San Marino",            "Sammarinese"),
        ("ST", "São Tomé & Príncipe",   "São Toméan"),
        ("SA", "Saudi Arabia",          "Saudi"),
        ("SN", "Senegal",               "Senegalese"),
        ("RS", "Serbia",                "Serbian"),
        ("SC", "Seychelles",            "Seychellois"),
        ("SL", "Sierra Leone",          "Sierra Leonean"),
        ("SG", "Singapore",             "Singaporean"),
        ("SK", "Slovakia",              "Slovak"),
        ("SI", "Slovenia",              "Slovenian"),
        ("SB", "Solomon Islands",       "Solomon Islander"),
        ("SO", "Somalia",               "Somali"),
        ("ZA", "South Africa",          "South African"),
        ("SS", "South Sudan",           "South Sudanese"),
        ("ES", "Spain",                 "Spanish"),
        ("LK", "Sri Lanka",             "Sri Lankan"),
        ("SD", "Sudan",                 "Sudanese"),
        ("SR", "Suriname",              "Surinamese"),
        ("SE", "Sweden",                "Swedish"),
        ("CH", "Switzerland",           "Swiss"),
        ("SY", "Syria",                 "Syrian"),
        ("TW", "Taiwan",                "Taiwanese"),
        ("TJ", "Tajikistan",            "Tajik"),
        ("TZ", "Tanzania",              "Tanzanian"),
        ("TH", "Thailand",              "Thai"),
        ("TL", "Timor-Leste",           "Timorese"),
        ("TG", "Togo",                  "Togolese"),
        ("TO", "Tonga",                 "Tongan"),
        ("TT", "Trinidad & Tobago",     "Trinidadian"),
        ("TN", "Tunisia",               "Tunisian"),
        ("TR", "Turkey",                "Turkish"),
        ("TM", "Turkmenistan",          "Turkmen"),
        ("TV", "Tuvalu",                "Tuvaluan"),
        ("UG", "Uganda",                "Ugandan"),
        ("UA", "Ukraine",               "Ukrainian"),
        ("AE", "United Arab Emirates",  "Emirati"),
        ("GB", "United Kingdom",        "British"),
        ("US", "United States",         "American"),
        ("UY", "Uruguay",               "Uruguayan"),
        ("UZ", "Uzbekistan",            "Uzbek"),
        ("VU", "Vanuatu",               "Ni-Vanuatu"),
        ("VE", "Venezuela",             "Venezuelan"),
        ("VN", "Vietnam",               "Vietnamese"),
        ("YE", "Yemen",                 "Yemeni"),
        ("ZM", "Zambia",                "Zambian"),
        ("ZW", "Zimbabwe",              "Zimbabwean"),
    ]

    private var filteredCountries: [(code: String, name: String, nationality: String)] {
        if countrySearch.isEmpty { return countries }
        return countries.filter {
            $0.name.localizedCaseInsensitiveContains(countrySearch) ||
            $0.nationality.localizedCaseInsensitiveContains(countrySearch)
        }
    }

    private var nationalityStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                stepHeader(
                    title: "Where's your\npassport from?",
                    italicWord: "passport",
                    subtitle: "Pick up to 3 nationalities. We'll match visas for all of them."
                )
                // Selected pills + counter
                if !selectedNationalities.isEmpty {
                    HStack(alignment: .top, spacing: 0) {
                        FlowLayout(spacing: 8) {
                            ForEach(Array(selectedNationalities.sorted()), id: \.self) { nat in
                                let name = countries.first { $0.nationality == nat }?.name ?? nat
                                HStack(spacing: 4) {
                                    Text(name).font(.caption).fontWeight(.medium)
                                    Button {
                                        selectedNationalities.remove(nat)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 9, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.black)
                                .cornerRadius(20)
                            }
                        }
                        Spacer(minLength: 8)
                        Text("\(selectedNationalities.count)/3")
                            .font(.caption).foregroundColor(.secondary)
                            .padding(.top, 6)
                    }
                    .transition(.opacity)
                }
            }

            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.subheadline)
                TextField("Search countries", text: $countrySearch)
                    .font(.subheadline)
                    .autocorrectionDisabled()
                if !countrySearch.isEmpty {
                    Button { countrySearch = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color(.systemGray6)).cornerRadius(12)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(filteredCountries, id: \.code) { country in
                    let selected = selectedNationalities.contains(country.nationality)
                    let maxReached = selectedNationalities.count >= 3 && !selected
                    Button {
                        if selected {
                            selectedNationalities.remove(country.nationality)
                        } else if !maxReached {
                            selectedNationalities.insert(country.nationality)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(country.code)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(selected ? .white.opacity(0.7) : Color(.systemGray3))
                                .frame(width: 28)
                            Text(country.name)
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(selected ? .white : maxReached ? Color(.systemGray3) : .primary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 16)
                        .background(selected ? Color.black : Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1))
                    }
                    .disabled(maxReached)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedNationalities)
    }

    // MARK: - Step 2: Residence Country

    private var filteredResidenceCountries: [(code: String, name: String, nationality: String)] {
        if residenceSearch.isEmpty { return countries }
        return countries.filter {
            $0.name.localizedCaseInsensitiveContains(residenceSearch) ||
            $0.nationality.localizedCaseInsensitiveContains(residenceSearch)
        }
    }

    private var residenceStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                title: "Where do you live\ncurrently?",
                italicWord: "live",
                subtitle: "We'll show visas you can apply for from your country."
            )

            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.subheadline)
                TextField("Search countries", text: $residenceSearch)
                    .font(.subheadline)
                    .autocorrectionDisabled()
                if !residenceSearch.isEmpty {
                    Button { residenceSearch = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color(.systemGray6)).cornerRadius(12)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(filteredResidenceCountries, id: \.code) { country in
                    let selected = residenceCountry == country.name
                    Button {
                        residenceCountry = selected ? "" : country.name
                    } label: {
                        HStack(spacing: 10) {
                            Text(country.code)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(selected ? .white.opacity(0.7) : Color(.systemGray3))
                                .frame(width: 28)
                            Text(country.name)
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(selected ? .white : .primary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 16)
                        .background(selected ? Color.black : Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: residenceCountry)
    }

    // MARK: - Step 2: Age

    private var ageStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "How old are you?", italicWord: "old",
                       subtitle: "Some visas have age limits — most cap at 35 or 45.")
            VStack(spacing: 6) {
                Text("\(Int(age))")
                    .font(.system(size: 80, weight: .regular, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("years old")
                    .font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 16)
            VStack(spacing: 6) {
                Slider(value: $age, in: 16...90, step: 1).tint(.black)
                HStack {
                    Text("16").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("90").font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Step 3: Education

    private let educationOptions: [(key: String, label: String)] = [
        ("high_school", "High school"),
        ("bachelors",   "Bachelor's degree"),
        ("masters",     "Master's degree"),
        ("phd",         "PhD"),
        ("other",       "Other"),
    ]

    private var educationStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "Highest education?", italicWord: "education",
                       subtitle: "Degrees unlock skilled-worker routes.")
            VStack(spacing: 10) {
                ForEach(educationOptions, id: \.key) { option in
                    let selected = education == option.key
                    Button { education = option.key } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 15))
                                .foregroundColor(selected ? .white : .secondary)
                                .frame(width: 20)
                            Text(option.label)
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(selected ? .white : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 18).padding(.vertical, 18)
                        .background(selected ? Color.black : Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: - Step 4: Occupation

    private let occupationOptions = [
        "Software Engineer",       "Designer / Creative",
        "Product Manager",         "Data Scientist / AI",
        "Doctor / Nurse",          "Teacher / Researcher",
        "Lawyer / Legal",          "Accountant / Finance",
        "Marketing / PR",          "Sales / Business Dev",
        "Engineer (non-software)", "Architect",
        "Journalist / Writer",     "Artist / Musician",
        "Founder / Self-employed", "Student",
        "Retired",                 "Other",
    ]

    private var occupationStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "What is your work?", italicWord: "work",
                       subtitle: "Your field shapes which talent visas apply.")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(occupationOptions, id: \.self) { option in
                    let selected = occupation == option
                    Button { occupation = option } label: {
                        Text(option)
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundColor(selected ? .white : .primary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                            .padding(.horizontal, 14).padding(.vertical, 16)
                            .background(selected ? Color.black : Color(.systemBackground))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1))
                    }
                }
            }

            if occupation == "Other" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your job title?")
                        .font(.subheadline).fontWeight(.medium)
                    TextField("e.g. Geologist, Pilot, Chef…", text: $otherOccupation)
                        .font(.subheadline)
                        .padding(.horizontal, 16).padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: occupation)
    }

    // MARK: - Step 5: Experience

    private var experienceStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "Years of experience?", italicWord: "experience",
                       subtitle: "Most skilled visas require 2–5 years in your field.")
            VStack(spacing: 6) {
                Text("\(Int(experience))")
                    .font(.system(size: 80, weight: .regular, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("years")
                    .font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 16)
            VStack(spacing: 6) {
                Slider(value: $experience, in: 0...20, step: 1).tint(.black)
                HStack {
                    Text("0").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("20+").font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Step 6: Summary

    // MARK: - Step 7: Marital Status

    private let relationshipOptions: [(key: String, label: String)] = [
        ("single",            "Single"),
        ("in_a_relationship", "In a relationship"),
        ("married",           "Married"),
        ("divorced",          "Divorced"),
        ("widowed",           "Widowed"),
    ]

    private var maritalStatusStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "What's your\nrelationship status?",
                       italicWord: "relationship",
                       subtitle: "Some family and partner visas depend on this.")

            VStack(spacing: 10) {
                ForEach(relationshipOptions, id: \.key) { option in
                    let selected = relationshipStatus == option.key
                    Button { relationshipStatus = option.key } label: {
                        HStack {
                            Text(option.label)
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(selected ? .white : .primary)
                            Spacer()
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 18).padding(.vertical, 18)
                        .background(selected ? Color.black : Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1))
                    }
                }
            }

            if relationshipStatus != "single" {
                VStack(alignment: .leading, spacing: 10) {
                    Text("How many kids do you have?")
                        .font(.subheadline).fontWeight(.medium)

                    HStack(spacing: 0) {
                        Button {
                            if numberOfKids > 0 { numberOfKids -= 1 }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 56, height: 56)
                                .foregroundColor(numberOfKids == 0 ? Color(.systemGray3) : .primary)
                        }
                        Text("\(numberOfKids)")
                            .font(.title2).fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                        Button {
                            numberOfKids += 1
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 56, height: 56)
                                .foregroundColor(.primary)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: relationshipStatus)
    }

    private var summaryStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Green checkmark
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.green)
                )

            // Title
            Text("You're all set,\n\(firstName).")
                .font(.system(size: 34, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)

            // Subtitle with bold counts
            let eligible   = store.eligibleVisas.count
            let ineligible = store.ineligibleVisas.count
            Group {
                Text("Based on what you shared, we found ")
                + Text("\(eligible) visas").fontWeight(.bold)
                + Text(" you're eligible for and ")
                + Text("\(ineligible) more").fontWeight(.bold)
                + Text(" close to reach.")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            // Summary card
            VStack(spacing: 0) {
                summaryRow("Passport",  countries.filter { selectedNationalities.contains($0.nationality) }.map(\.name).joined(separator: ", "))
                Divider().padding(.leading, 16)
                summaryRow("Lives in",  residenceCountry)
                Divider().padding(.leading, 16)
                summaryRow("Age",        "\(Int(age))")
                Divider().padding(.leading, 16)
                summaryRow("Education",  educationOptions.first { $0.key == education }?.label ?? education)
                Divider().padding(.leading, 16)
                summaryRow("Occupation", occupation)
                if !skipsExperience {
                    Divider().padding(.leading, 16)
                    summaryRow("Experience", "\(Int(experience)) years")
                }
                Divider().padding(.leading, 16)
                summaryRow("Status", relationshipOptions.first { $0.key == relationshipStatus }?.label ?? relationshipStatus)
            }
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline).fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Shared header

    private func stepHeader(title: String, italicWord: String?, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let word = italicWord, let range = title.range(of: word) {
                let before = String(title[title.startIndex..<range.lowerBound])
                let after  = String(title[range.upperBound...])
                (Text(before).font(.system(size: 34, weight: .bold))
                 + Text(word).font(Font.custom("InstrumentSerif-Italic", size: 36))
                 + Text(after).font(.system(size: 34, weight: .bold)))
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(subtitle)
                .font(.subheadline).foregroundColor(.secondary)
        }
    }

    // MARK: - Advance

    private func advance() {
        if step == totalSteps - 2 {
            // Commit data before showing summary so counts are accurate
            commitToStore()
            withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
        } else if step < totalSteps - 1 {
            // Skip experience step (5) when it's irrelevant for the occupation
            if step == 4 && skipsExperience {
                withAnimation(.easeInOut(duration: 0.25)) { step = 6 }
            } else {
                withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
            }
        } else {
            auth.completeOnboarding()
        }
    }

    private func commitToStore() {
        store.user.nationalities   = Array(selectedNationalities)
        store.user.homeCountry     = residenceCountry
        store.user.age             = Int(age)
        store.user.educationLevel  = education
        store.user.occupation      = occupation == "Other" ? otherOccupation : occupation
        store.user.experienceYears    = Int(experience)
        store.user.relationshipStatus = relationshipStatus
        store.user.numberOfKids       = numberOfKids
    }
}
