import SwiftUI

struct ContactUsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Contact us")
                    .font(.title2).fontWeight(.bold)
                    .padding(.top, 8)

                Text("Have a question, spotted an issue, or just want to say hi? We'd love to hear from you.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)

                VStack(spacing: 0) {
                    contactRow(icon: "envelope", title: "Email us", subtitle: "support@boundr.app") {
                        if let url = URL(string: "mailto:support@boundr.app") { openURL(url) }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
            }
            .padding(.horizontal, 20)
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
                        .frame(width: 38, height: 38)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
        }
    }

    private func contactRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16)).foregroundColor(.primary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6)).cornerRadius(8)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption).foregroundColor(Color(.systemGray3))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
    }
}
