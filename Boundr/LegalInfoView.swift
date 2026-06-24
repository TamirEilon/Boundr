import SwiftUI

struct LegalInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let ink      = Color(red: 51/255,  green: 54/255,  blue: 63/255)   // #33363F
    private let arrow    = Color(red: 173/255, green: 173/255, blue: 173/255)  // #ADADAD
    private let hairline = Color.black.opacity(0.08)

    private func dm(_ size: CGFloat, _ semibold: Bool = false) -> Font {
        .system(size: size, weight: semibold ? .semibold : .regular)
    }

    private let items: [(title: String, url: String)] = [
        ("Privacy Policy",      "https://imaginative-status-057532.framer.app/privacy-policy"),
        ("Terms & Conditions",  "https://imaginative-status-057532.framer.app/terms-and-condition"),
        ("AI Disclaimer",       "https://imaginative-status-057532.framer.app/ai-disclaimer"),
        ("Refund Policy",       "https://imaginative-status-057532.framer.app/refund-policy")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(items, id: \.title) { item in
                    Button {
                        if let url = URL(string: item.url) { openURL(url) }
                    } label: {
                        row(title: item.title)
                    }
                    .buttonStyle(.plain)
                    Rectangle().fill(hairline).frame(height: 1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
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
                Text("Legal Info").font(dm(18, true)).tracking(-0.54).foregroundColor(ink)
            }
        }
    }

    private func row(title: String) -> some View {
        HStack {
            Text(title)
                .font(dm(15, true)).tracking(-0.45)
                .foregroundColor(ink)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(arrow)
        }
        .padding(.vertical, 22)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack { LegalInfoView() }
}
