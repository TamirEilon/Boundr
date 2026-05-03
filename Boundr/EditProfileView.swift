import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var store: VisaStore
    @Environment(\.dismiss) var dismiss

    @State private var draft: UserProfile

    init(user: UserProfile) {
        _draft = State(initialValue: user)
    }

    private let nationalities = [
        "American", "British", "Canadian", "Australian", "German", "French",
        "Spanish", "Italian", "Dutch", "Swedish", "Norwegian", "Danish",
        "Finnish", "Irish", "Portuguese", "Greek", "Polish", "Austrian",
        "Belgian", "Swiss", "New Zealander", "Japanese", "South Korean",
        "Singaporean", "Indian", "Brazilian", "Mexican", "Argentine", "Israeli",
        "South African", "Other"
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

                formField(label: "Age") {
                    textRow(value: intBinding(\.age), keyboard: .numberPad)
                }

                formField(label: "Education") {
                    pickerRow(selection: $draft.educationLevel,
                              options: educationOptions.map(\.key),
                              display: { key in educationOptions.first { $0.key == key }?.label ?? key })
                }

                formField(label: "Occupation") {
                    pickerRow(selection: $draft.occupation,
                              options: occupationOptions,
                              display: { $0 })
                }

                formField(label: "Years of experience") {
                    textRow(value: intBinding(\.experienceYears), keyboard: .numberPad)
                }

                formField(label: "Relationship status") {
                    relationshipGrid
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
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
                    store.user = draft
                    dismiss()
                }
                .font(.subheadline).fontWeight(.semibold)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formField(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
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
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }

    private func textRow(value: Binding<String>, keyboard: UIKeyboardType) -> some View {
        TextField("", text: value)
            .font(.body)
            .keyboardType(keyboard)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
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
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                        )
                }
            }
        }
    }

    private var availableNationalities: [String] {
        nationalities.filter { !draft.nationalities.contains($0) }
    }

    private var nationalityField: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Selected pills
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

            // Add button (visible when fewer than 3 selected)
            if draft.nationalities.count < 3 {
                Menu {
                    ForEach(availableNationalities, id: \.self) { nat in
                        Button(nat) { draft.nationalities.append(nat) }
                    }
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
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1))
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
