import SwiftUI

/// A self-contained card rendered to a UIImage and shared via the system share sheet.
struct VisaShareCardView: View {
    let visa: Visa
    let heroImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            heroSection
            statsSection
            footerSection
        }
        .frame(width: 375)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Hero

    private var heroSection: some View {
        Color.clear
            .frame(height: 200)
            .background {
                Group {
                    if let img = heroImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: heroGradient,
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            ))
                    }
                }
            }
            .clipped()
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.62)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        // Country badge — plain colour so ImageRenderer renders it correctly
                        HStack(spacing: 7) {
                            Text(visa.countryCode)
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.black)
                                .frame(width: 26, height: 26)
                                .background(Color.white)
                                .clipShape(Circle())

                            Text(visa.country.uppercased())
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.92))
                                .tracking(0.8)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.20))
                        .clipShape(Capsule())

                        Text(visa.visaName)
                            .font(.title2).fontWeight(.bold)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 8) {
            statTile(icon: "clock",      label: "Duration",   value: visa.duration)
            statTile(icon: "calendar",   label: "Processing", value: visa.processingTime)
            statTile(icon: "creditcard", label: "Cost",       value: visa.cost)
        }
        .padding(18)
        .background(Color(.systemBackground))
    }

    private func statTile(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(11)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(13)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            HStack(spacing: 9) {
                Image("BoundrLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Boundr")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.ink)
                    Text("Discover your next visa")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("Get the app")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(red: 37/255, green: 99/255, blue: 235/255))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: - Gradient fallback

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
}
