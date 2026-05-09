import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var store: VisaStore
    @Environment(\.dismiss) var dismiss

    @State private var draft: UserProfile
    @State private var otherOccupation: String = ""
    @State private var showNationalityPicker = false
    @State private var nationalitySearch = ""

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
        "Consultant", "Entrepreneur", "Freelancer", "Student", "Other"
    ]

    private let relationshipOptions: [(key: String, label: String)] = [
        ("single",             "Single"),
        ("in_a_relationship",  "In a relationship"),
        ("married",            "Married"),
        ("married_with_kids",  "Married with kids")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                formField(label: "Nationality (up to 3)") {
                    nationalityField
                }

                formField(label: "Where do you live?") {
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
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: draft.occupation)
                }

                formField(label: "Years of experience") {
                    textRow(value: intBinding(\.experienceYears), keyboard: .numberPad)
                }

                formField(label: "Relationship status") {
                    relationshipGrid
                }

                if draft.relationshipStatus != "single" {
                    formField(label: "Number of kids") {
                        HStack(spacing: 0) {
                            Button {
                                if draft.numberOfKids > 0 { draft.numberOfKids -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 52, height: 52)
                                    .foregroundColor(draft.numberOfKids == 0 ? Color(.systemGray3) : .primary)
                            }
                            Text("\(draft.numberOfKids)")
                                .font(.title3).fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                            Button {
                                draft.numberOfKids += 1
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 52, height: 52)
                                    .foregroundColor(.primary)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
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
                        .foregroundColor(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit profile").font(.headline).fontWeight(.bold)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    var saved = draft
                    if saved.occupation == "Other" && !otherOccupation.trimmingCharacters(in: .whitespaces).isEmpty {
                        saved.occupation = otherOccupation.trimmingCharacters(in: .whitespaces)
                    }
                    store.user = saved
                    dismiss()
                }
                .font(.subheadline).fontWeight(.semibold)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formField(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color(.systemGray))
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
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
        }
    }

    private func textRow(value: Binding<String>, keyboard: UIKeyboardType) -> some View {
        TextField("", text: value)
            .font(.subheadline).fontWeight(.semibold)
            .keyboardType(keyboard)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }

    private var homeCountryField: some View {
        pickerRow(selection: $draft.homeCountry,
                  options: allCountries,
                  display: { $0 })
    }

    private var relationshipGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(relationshipOptions, id: \.key) { option in
                let isSelected = draft.relationshipStatus == option.key
                Button { draft.relationshipStatus = option.key } label: {
                    Text(option.label)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSelected ? Color.black : Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.clear : Color(.systemGray5), lineWidth: 1)
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
                        HStack(spacing: 5) {
                            Text(nat)
                                .font(.subheadline).fontWeight(.medium)
                            Button {
                                draft.nationalities.removeAll { $0 == nat }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(20)
                    }
                }
            }

            if draft.nationalities.count < 3 {
                Button {
                    nationalitySearch = ""
                    showNationalityPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add nationality")
                            .font(.subheadline).fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray5), lineWidth: 1))
                }
                .sheet(isPresented: $showNationalityPicker) {
                    NavigationStack {
                        List(filteredNationalities, id: \.self) { nat in
                            Button(nat) {
                                draft.nationalities.append(nat)
                                showNationalityPicker = false
                            }
                            .foregroundColor(.primary)
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
