import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    private let appVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    private let ink       = Color(red: 51/255,  green: 54/255,  blue: 63/255)   // #33363F
    private let brandBlue = Color(red: 67/255,  green: 122/255, blue: 244/255)  // #437AF4
    private let footGray  = Color(red: 0.56, green: 0.57, blue: 0.60)

    private func dm(_ size: CGFloat, _ semibold: Bool = false) -> Font {
        Font.custom(semibold ? "DMSans-SemiBold" : "DMSans-Regular", size: size)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Wordmark
                Image("boundr-wordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .padding(.top, 28)
                    .padding(.bottom, 28)

                // Blue card
                VStack(alignment: .leading, spacing: 14) {
                    (Text("Visas, ").font(dm(26, true))
                     + Text("simplified").font(dm(26, true)).italic())
                        .foregroundColor(.white)

                    Text("Boundr helps you discover visa opportunities based on your profile, goals and future plans – all in one place. We simplify the complex world of immigration by turning scattered requirements into clear, personalized insights you can understand in minutes.")
                        .font(dm(15))
                        .foregroundColor(.white.opacity(0.92))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(brandBlue)
                .cornerRadius(24)

                // Footer
                VStack(spacing: 6) {
                    Text("Version \(appVersion) – Build \(buildNumber)")
                    Text("© Copyright Boundr. All rights reserved")
                }
                .font(dm(13))
                .foregroundColor(footGray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 26)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
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
                Text("About Boundr").font(dm(18, true)).foregroundColor(ink)
            }
        }
    }
}

#Preview {
    NavigationStack { AboutView() }
}
