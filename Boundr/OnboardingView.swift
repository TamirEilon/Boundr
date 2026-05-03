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
    @State private var selectedNationalities: Set<String> = ["American"]
    @State private var age: Double     = 28
    @State private var education       = "masters"
    @State private var occupation      = "Software Engineer"
    @State private var experience: Double = 4

    private let totalSteps = 6

    private var firstName: String {
        auth.currentUser?.displayName?.components(separatedBy: " ").first ?? "there"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { if step > 0 { withAnimation { step -= 1 } } } label: {
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
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        switch step {
                        case 0: nationalityStep
                        case 1: ageStep
                        case 2: educationStep
                        case 3: occupationStep
                        case 4: experienceStep
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
                    .background(Color.black)
                    .cornerRadius(16)
                }
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
        ("US", "United States",  "American"),
        ("GB", "United Kingdom", "British"),
        ("CA", "Canada",         "Canadian"),
        ("DE", "Germany",        "German"),
        ("FR", "France",         "French"),
        ("IN", "India",          "Indian"),
        ("BR", "Brazil",         "Brazilian"),
        ("AU", "Australia",      "Australian"),
        ("JP", "Japan",          "Japanese"),
        ("MX", "Mexico",         "Mexican"),
        ("ZA", "South Africa",   "South African"),
        ("NG", "Nigeria",        "Nigerian"),
        ("ES", "Spain",          "Spanish"),
        ("IT", "Italy",          "Italian"),
        ("NL", "Netherlands",    "Dutch"),
        ("SE", "Sweden",         "Swedish"),
        ("KR", "South Korea",    "South Korean"),
        ("SG", "Singapore",      "Singaporean"),
        ("IL", "Israel",         "Israeli"),
        ("PL", "Poland",         "Polish"),
    ]

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

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(countries, id: \.code) { country in
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

    // MARK: - Step 2: Age

    private var ageStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "How old are you?", italicWord: nil,
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
                Slider(value: $age, in: 16...65, step: 1).tint(.black)
                HStack {
                    Text("16").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("65").font(.caption).foregroundColor(.secondary)
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
            stepHeader(title: "Highest education?", italicWord: nil,
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
        "Software Engineer", "Designer",
        "Product Manager",   "Data Scientist",
        "Doctor / Nurse",    "Teacher / Researcher",
        "Marketing",         "Finance",
        "Founder / Self-employed", "Other",
    ]

    private var occupationStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "What do you do?", italicWord: nil,
                       subtitle: "Your field shapes which talent visas apply.")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(occupationOptions, id: \.self) { option in
                    let selected = occupation == option
                    Button { occupation = option } label: {
                        Text(option)
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundColor(selected ? .white : .primary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14).padding(.vertical, 16)
                            .background(selected ? Color.black : Color(.systemBackground))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: - Step 5: Experience

    private var experienceStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "Years of experience?", italicWord: nil,
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
                summaryRow("Passport", countries.filter { selectedNationalities.contains($0.nationality) }.map(\.name).joined(separator: ", "))
                Divider().padding(.leading, 16)
                summaryRow("Age",        "\(Int(age))")
                Divider().padding(.leading, 16)
                summaryRow("Education",  educationOptions.first { $0.key == education }?.label ?? education)
                Divider().padding(.leading, 16)
                summaryRow("Occupation", occupation)
                Divider().padding(.leading, 16)
                summaryRow("Experience", "\(Int(experience)) years")
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
                 + Text(word).font(.system(size: 34, weight: .regular, design: .serif)).italic()
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
            withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
        } else {
            auth.completeOnboarding()
        }
    }

    private func commitToStore() {
        store.user.nationalities   = Array(selectedNationalities)
        store.user.age             = Int(age)
        store.user.educationLevel  = education
        store.user.occupation      = occupation
        store.user.experienceYears = Int(experience)
    }
}
