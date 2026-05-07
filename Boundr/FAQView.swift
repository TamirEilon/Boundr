import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) var dismiss

    private let faqs: [(question: String, answer: String)] = [
        (
            "What is Boundr?",
            "Boundr is a visa research platform that helps you discover and compare visa options based on your personal profile and eligibility."
        ),
        (
            "How does eligibility checking work?",
            "After completing your profile (nationality, age, occupation, education), we automatically match you against visa requirements to show which visas you qualify for."
        ),
        (
            "Is the information on Boundr official?",
            "Boundr aggregates visa information for research purposes. Always verify details with official government sources before applying."
        ),
        (
            "Can I save visas I'm interested in?",
            "Yes! Click the bookmark icon on any visa card or detail page to save it to your personal list."
        ),
        (
            "How do I update my profile information?",
            "Go to Profile Settings from the user menu, then click 'Edit Info' to update your eligibility details."
        )
    ]

    @State private var expanded: Set<Int> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(faqs.indices, id: \.self) { i in
                    faqItem(index: i)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
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
                        .foregroundColor(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6), in: Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text("FAQ").font(.headline).fontWeight(.bold)
            }
        }
    }

    private func faqItem(index: Int) -> some View {
        let isOpen = expanded.contains(index)
        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isOpen { expanded.remove(index) } else { expanded.insert(index) }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(faqs[index].question)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.systemGray3))
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            if isOpen {
                Divider().padding(.horizontal, 16)
                Text(faqs[index].answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

#Preview {
    NavigationStack {
        FAQView()
    }
}
