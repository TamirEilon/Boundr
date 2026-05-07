import SwiftUI

struct LegalSection {
    let heading: String
    let body: String
}

struct LegalPageView: View {
    let title: String
    let sections: [LegalSection]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.title2).fontWeight(.bold)
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 8) {
                        if !section.heading.isEmpty {
                            Text(section.heading)
                                .font(.subheadline).fontWeight(.bold)
                        }
                        Text(section.body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 20)
                }
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
}
