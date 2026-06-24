import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var store: VisaStore
    @Environment(\.dismiss) var dismiss

    @State private var draft: UserProfile
    @State private var otherOccupation: String = ""
    @State private var showNationalityPicker = false
    @State private var nationalitySearch = ""
    @State private var showCountryPicker = false
    @State private var countrySearch = ""

    init(user: UserProfile) {
        _draft = State(initialValue: user)
        let isOther = !["Software Engineer","Designer","Product Manager","Data Scientist",
                        "Marketing","Sales","Teacher","Doctor","Lawyer","Accountant",
                        "Consultant","Entrepreneur","Freelancer","Student"].contains(user.occupation)
        if isOther && !user.occupation.isEmpty {
            _draft = State(initialValue: {
                var u = user; u.occupation = "Other"; return u
            }())
            _otherOccupation = State(initialValue: user.occupation)
        }
    }

    private let allCountries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Argentina", "Armenia",
        "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Belarus",
        "Belgium", "Belize", "Bolivia", "Bosnia & Herzegovina", "Botswana", "Brazil", "Brunei",
        "Bulgaria", "Cambodia", "Cameroon", "Canada", "Chile", "China", "Colombia",
        "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Ecuador",
        "Egypt", "El Salvador", "Estonia", "Ethiopia", "Finland", "France", "Georgia",
        "Germany", "Ghana", "Greece", "Guatemala", "Honduras", "Hungary", "Iceland", "India",
        "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan",
        "Jordan", "Kazakhstan", "Kenya", "Kuwait", "Laos", "Latvia", "Lebanon", "Libya",
        "Lithuania", "Luxembourg", "Malaysia", "Malta", "Mexico", "Moldova", "Mongolia",
        "Morocco", "Mozambique", "Myanmar", "Nepal", "Netherlands", "New Zealand", "Nigeria",
        "North Macedonia", "Norway", "Oman", "Pakistan", "Panama", "Paraguay", "Peru",
        "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda",
        "Saudi Arabia", "Senegal", "Serbia", "Singapore", "Slovakia", "Slovenia",
        "South Africa", "South Korea", "Spain", "Sri Lanka", "Sudan", "Sweden", "Switzerland",
        "Syria", "Taiwan", "Tanzania", "Thailand", "Tunisia", "Turkey", "UAE",
        "Uganda", "Ukraine", "United Kingdom", "United States", "Uruguay", "Uzbekistan",
        "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    ]

    private let nationalities = [
        "Afghan", "Albanian", "Algerian", "American", "Andorran", "Angolan", "Argentine",
        "Armenian", "Australian", "Austrian", "Azerbaijani", "Bahamian", "Bahraini",
        "Bangladeshi", "Belarusian", "Belgian", "Belizean", "Bolivian", "Bosnian",
        "Botswanan", "Brazilian", "British", "Bruneian", "Bulgarian", "Cambodian",
        "Cameroonian", "Canadian", "Cape Verdean", "Chilean", "Chinese", "Colombian",
        "Costa Rican", "Croatian", "Cuban", "Cypriot", "Czech", "Danish", "Dutch",
        "Ecuadorian", "Egyptian", "Emirati", "Estonian", "Ethiopian", "Filipino",
        "Finnish", "French", "Gabonese", "Gambian", "Georgian", "German", "Ghanaian",
        "Greek", "Guatemalan", "Guinean", "Haitian", "Honduran", "Hungarian",
        "Icelandic", "Indian", "Indonesian", "Iranian", "Iraqi", "Irish", "Israeli",
        "Italian", "Jamaican", "Japanese", "Jordanian", "Kazakhstani", "Kenyan",
        "Kuwaiti", "Lao", "Latvian", "Lebanese", "Libyan", "Lithuanian", "Luxembourgish",
        "Macedonian", "Malagasy", "Malawian", "Malaysian", "Maldivian", "Malian",
        "Maltese", "Mauritanian", "Mauritian", "Mexican", "Moldovan", "Mongolian",
        "Montenegrin", "Moroccan", "Mozambican", "Namibian", "Nepali", "New Zealander",
        "Nicaraguan", "Nigerian", "Nigerien", "Norwegian", "Omani", "Pakistani",
        "Panamanian", "Paraguayan", "Peruvian", "Polish", "Portuguese", "Qatari",
        "Romanian", "Russian", "Rwandan", "Salvadoran", "Saudi", "Senegalese", "Serbian",
        "Singaporean", "Slovak", "Slovenian", "Somali", "South African", "South Korean",
        "Spanish", "Sri Lankan", "Sudanese", "Swedish", "Swiss", "Syrian", "Taiwanese",
        "Tajik", "Tanzanian", "Thai", "Tunisian", "Turkish", "Turkmen", "Ugandan",
        "Ukrainian", "Uruguayan", "Uzbek", "Venezuelan", "Vietnamese", "Yemeni",
        "Zambian", "Zimbabwean"
    ]

    private let educationOptions: [(key: String, label: String)] = [
        ("high_school", "High School"),
        ("bachelors",   "Bachelor's degree"),
        ("masters",     "Master's degree"),
        ("phd",         "PhD")
    ]

    private let occupationOptions = [
        "Software Engineer", "Designer", "Product Manager", "Data Scientist",
        "Marketing", "Sales", "Teacher", "Doctor", "Lawyer", "Accountant",
        "Consultant", "Entrepreneur", "Freelancer", "Student", "Retired", "Other"
    ]

    private let relationshipOptions: [(key: String, label: String)] = [
        ("single",             "Single"),
        ("in_a_relationship",  "In a relationship"),
        ("married",            "Married"),
        ("married_with_kids",  "Married with kids")
    ]

    // MARK: - Design tokens

    private let ink         = Color(red: 51/255,  green: 54/255,  blue: 63/255)    // #33363F
    private let fieldBorder = Color(red: 0.90, green: 0.90, blue: 0.91)
    private let labelGray   = Color(red: 0.44, green: 0.45, blue: 0.49)

    private func dm(_ size: CGFloat, _ semibold: Bool = false) -> Font {
        .system(size: size, weight: semibold ? .semibold : .regular)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                formField(label: "Nationalities (Up to 3 nationalities)") {
                    nationalityField
                }

                formField(label: "Country of residence") {
                    homeCountryField
                }

                formField(label: "Age") {
                    textRow(value: intBinding(\.age), keyboard: .numberPad)
                }

                formField(label: "Education") {
                    pickerRow(selection: $draft.educationLevel,
                              options: educationOptions.map(\.key),
                              display: { key in educationOptions.first { $0.key == key }?.label ?? key })
                }

                formField(label: "Occupation") {
                    VStack(alignment: .leading, spacing: 10) {
                        pickerRow(selection: $draft.occupation,
                                  options: occupationOptions,
                                  display: { $0 })
                        if draft.occupation == "Other" {
                            TextField("Job title", text: $otherOccupation)
                                .font(dm(16)).tracking(-0.48)
                                .foregroundColor(ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color(.systemBackground))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(fieldBorder, lineWidth: 1.5))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: draft.occupation)
                }

                if draft.occupation != "Retired" {
                    formField(label: "Years of experience") {
                        textRow(value: intBinding(\.experienceYears), keyboard: .numberPad)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                formField(label: "Relationship status") {
                    relationshipGrid
                }

                if draft.relationshipStatus != "single" {
                    formField(label: "Number of kids") {
                        kidsStepper
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
            .animation(.easeInOut(duration: 0.2), value: draft.relationshipStatus)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ink)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit Profile").font(dm(18, true)).tracking(-0.54).foregroundColor(ink)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    var saved = draft
                    if saved.occupation == "Other" && !otherOccupation.trimmingCharacters(in: .whitespaces).isEmpty {
                        saved.occupation = otherOccupation.trimmingCharacters(in: .whitespaces)
                    }
                    store.user = saved
                    dismiss()
                } label: {
                    Text("Save").font(dm(16, true)).tracking(-0.48).foregroundColor(ink)
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formField(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(dm(13)).tracking(-0.39)
                .foregroundColor(labelGray)
            content()
        }
    }

    private func pickerRow(selection: Binding<String>,
                           options: [String],
                           display: @escaping (String) -> String) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(display(option)) { selection.wrappedValue = option }
            }
        } label: {
            HStack {
                Text(display(selection.wrappedValue))
                    .font(dm(16)).tracking(-0.48)
                    .foregroundColor(ink)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ink)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(fieldBorder, lineWidth: 1.5))
        }
    }

    private func textRow(value: Binding<String>, keyboard: UIKeyboardType) -> some View {
        TextField("", text: value)
            .font(dm(16)).tracking(-0.48)
            .foregroundColor(ink)
            .keyboardType(keyboard)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(fieldBorder, lineWidth: 1.5))
    }

    private var kidsStepper: some View {
        HStack(spacing: 0) {
            Button {
                if draft.numberOfKids > 0 { draft.numberOfKids -= 1 }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 52, height: 54)
                    .foregroundColor(draft.numberOfKids == 0 ? Color(.systemGray3) : ink)
            }
            Text("\(draft.numberOfKids)")
                .font(dm(18, true)).tracking(-0.54).foregroundColor(ink)
                .frame(maxWidth: .infinity)
            Button {
                draft.numberOfKids += 1
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 52, height: 54)
                    .foregroundColor(ink)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(fieldBorder, lineWidth: 1.5))
    }

    private var filteredCountries: [String] {
        if countrySearch.isEmpty { return allCountries }
        return allCountries.filter { $0.localizedCaseInsensitiveContains(countrySearch) }
    }

    private var homeCountryField: some View {
        Button {
            countrySearch = ""
            showCountryPicker = true
        } label: {
            HStack {
                Text(draft.homeCountry.isEmpty ? "Select country" : draft.homeCountry)
                    .font(dm(16)).tracking(-0.48)
                    .foregroundColor(draft.homeCountry.isEmpty ? Color(.systemGray3) : ink)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ink)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(fieldBorder, lineWidth: 1.5))
        }
        .sheet(isPresented: $showCountryPicker) {
            NavigationStack {
                List(filteredCountries, id: \.self) { country in
                    Button(country) {
                        draft.homeCountry = country
                        showCountryPicker = false
                    }
                    .foregroundColor(.ink)
                }
                .searchable(text: $countrySearch, prompt: "Search country")
                .navigationTitle("Select Country")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showCountryPicker = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var relationshipGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(relationshipOptions, id: \.key) { option in
                let isSelected = draft.relationshipStatus == option.key
                Button { draft.relationshipStatus = option.key } label: {
                    Text(option.label)
                        .font(dm(15, isSelected)).tracking(-0.45)
                        .foregroundColor(isSelected ? .white : ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(isSelected ? ink : Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.clear : fieldBorder, lineWidth: 1.5)
                        )
                }
            }
        }
    }

    private var filteredNationalities: [String] {
        let available = nationalities.filter { !draft.nationalities.contains($0) }
        if nationalitySearch.isEmpty { return available }
        return available.filter { $0.localizedCaseInsensitiveContains(nationalitySearch) }
    }

    private var nationalityField: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !draft.nationalities.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(draft.nationalities, id: \.self) { nat in
                        HStack(spacing: 6) {
                            Text(nat)
                                .font(dm(14)).tracking(-0.42)
                            Button {
                                draft.nationalities.removeAll { $0 == nat }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(ink)
                        .cornerRadius(20)
                    }
                }
            }

            if draft.nationalities.count < 3 {
                Button {
                    nationalitySearch = ""
                    showNationalityPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add Nationality")
                            .font(dm(16)).tracking(-0.48)
                    }
                    .foregroundColor(ink)
                    .padding(.horizontal, 16).padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(fieldBorder, lineWidth: 1.5))
                }
                .sheet(isPresented: $showNationalityPicker) {
                    NavigationStack {
                        List(filteredNationalities, id: \.self) { nat in
                            Button(nat) {
                                draft.nationalities.append(nat)
                                showNationalityPicker = false
                            }
                            .foregroundColor(.ink)
                        }
                        .searchable(text: $nationalitySearch, prompt: "Search nationality")
                        .navigationTitle("Select Nationality")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showNationalityPicker = false }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: draft.nationalities.count)
    }

    private func intBinding(_ keyPath: WritableKeyPath<UserProfile, Int>) -> Binding<String> {
        Binding(
            get: { "\(draft[keyPath: keyPath])" },
            set: { if let v = Int($0) { draft[keyPath: keyPath] = v } }
        )
    }
}

#Preview {
    NavigationStack {
        EditProfileView(user: UserProfile()).environmentObject(VisaStore())
    }
}
