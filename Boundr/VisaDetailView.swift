import SwiftUI

struct VisaDetailView: View {
    let visa: Visa
    @EnvironmentObject var store: VisaStore
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    private var eligible: Bool { store.isEligible(visa) }
    private var saved: Bool    { store.isSaved(visa) }

    private let steps: [(title: String, detail: String)] = [
        ("Gather documents",       "Passport, proof of income, criminal record, insurance."),
        ("Submit application",     "Apply at consulate or online portal in your country."),
        ("Biometrics & interview", "Brief in-person appointment if required."),
        ("Approval & travel",      "Receive your visa, then enter and register locally.")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection

                    VStack(alignment: .leading, spacing: 28) {
                        descriptionSection
                        statsSection
                        if !visa.requirements.isEmpty { requirementsSection }
                        howItWorksSection
                        Color.clear.frame(height: 80) // padding for bottom bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .ignoresSafeArea(edges: .top)

            bottomBar
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Hero

    private var heroSection: some View {
        // The Color.clear rectangle owns the layout size.
        // AsyncImage is a background so it can NEVER inflate the layout width.
        Color.clear
            .frame(height: 300)
            .background {
                AsyncImage(url: CountryUtils.imageURL(for: visa.country)) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(LinearGradient(
                            colors: heroGradient,
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ))
                    }
                }
            }
            .clipped()
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    // Dark scrim
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top, endPoint: .bottom
                    )

                    // Country code + name + visa title
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .frame(width: 52, height: 52)
                            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                            .overlay(
                                Text(visa.countryCode)
                                    .font(.headline).fontWeight(.bold).foregroundColor(.primary)
                            )
                        Text(visa.country.uppercased())
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.85))
                            .tracking(0.8)
                        Text(visa.visaName)
                            .font(.title).fontWeight(.bold)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
            .overlay(alignment: .top) {
                // Navigation buttons
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 38, height: 38)
                            .background(.regularMaterial, in: Circle())
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Button {} label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .frame(width: 38, height: 38)
                                .background(.regularMaterial, in: Circle())
                        }
                        Button { store.toggleSaved(visa) } label: {
                            Image(systemName: saved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 15))
                                .foregroundColor(saved ? .white : .primary)
                                .frame(width: 38, height: 38)
                                .background(saved ? AnyShapeStyle(Color.black) : AnyShapeStyle(.regularMaterial),
                                            in: Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
    }

    private var heroGradient: [Color] {
        switch visa.region {
        case "Europe":      return [Color(red: 0.35, green: 0.55, blue: 0.80), Color(red: 0.10, green: 0.25, blue: 0.55)]
        case "Americas":    return [Color(red: 0.20, green: 0.65, blue: 0.45), Color(red: 0.05, green: 0.35, blue: 0.28)]
        case "Asia":        return [Color(red: 0.75, green: 0.42, blue: 0.22), Color(red: 0.45, green: 0.18, blue: 0.10)]
        case "Oceania":     return [Color(red: 0.20, green: 0.55, blue: 0.75), Color(red: 0.08, green: 0.30, blue: 0.55)]
        case "Middle East": return [Color(red: 0.60, green: 0.32, blue: 0.65), Color(red: 0.38, green: 0.10, blue: 0.42)]
        default:            return [Color(red: 0.40, green: 0.40, blue: 0.45), Color(red: 0.22, green: 0.22, blue: 0.28)]
        }
    }

    // MARK: - Description + Eligibility

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(visa.description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(eligible ? "Eligible" : "Not eligible")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundColor(eligible ? .green : .red)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background((eligible ? Color.green : Color.red).opacity(0.12))
                .cornerRadius(20)

            if !eligible {
                let reasons = store.ineligibilityReasons(for: visa)
                if !reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(reasons, id: \.self) { reason in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red.opacity(0.7))
                                    .padding(.top, 1)
                                Text(reason)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 10) {
            statCard(icon: "clock",      label: "Duration",   value: visa.duration)
            statCard(icon: "calendar",   label: "Processing", value: visa.processingTime)
            statCard(icon: "creditcard", label: "Cost",       value: visa.cost)
        }
    }

    private func statCard(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(.secondary)
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value).font(.subheadline).fontWeight(.bold).lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }

    // MARK: - Requirements

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Requirements")
                .font(.headline).fontWeight(.bold)

            VStack(spacing: 0) {
                ForEach(Array(visa.requirements.enumerated()), id: \.offset) { idx, req in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 30, height: 30)
                            Circle()
                                .fill(Color(.systemGray3))
                                .frame(width: 8, height: 8)
                        }
                        Text(req)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 6)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)

                    if idx < visa.requirements.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(14)
        }
    }

    // MARK: - How It Works

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How it works")
                .font(.headline).fontWeight(.bold)

            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 28, height: 28)
                            Text("\(idx + 1)")
                                .font(.caption).fontWeight(.bold).foregroundColor(.primary)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.title)
                                .font(.subheadline).fontWeight(.semibold)
                            Text(step.detail)
                                .font(.subheadline).foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 4)
                        .padding(.bottom, idx < steps.count - 1 ? 24 : 0)

                        Spacer()
                    }
                    .background(alignment: .topLeading) {
                        if idx < steps.count - 1 {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 1.5)
                                .padding(.top, 28)
                                .padding(.leading, 13.25)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button { store.toggleSaved(visa) } label: {
                HStack(spacing: 8) {
                    Image(systemName: saved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 15))
                    Text(saved ? "Saved" : "Save")
                        .font(.subheadline).fontWeight(.semibold)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
            }

            Button {
                if let url = URL(string: visa.applicationURL) { openURL(url) }
            } label: {
                Text("Start application")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(visa.applicationURL.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(14)
            }
            .disabled(visa.applicationURL.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
    }
}
