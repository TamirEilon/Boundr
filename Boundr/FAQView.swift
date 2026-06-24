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
            "Yes! Tap the bookmark icon on any visa card or detail page to save it to your personal list."
        ),
        (
            "How do i update my profile information?",
            "Go to \"Edit Profile\" page from the \"Profile Page\", then feel free to adjust the information as you please"
        )
    ]

    @State private var expanded: Set<Int> = []

    private let ink      = Color(red: 51/255,  green: 54/255,  blue: 63/255)   // #33363F
    private let arrow    = Color(red: 173/255, green: 173/255, blue: 173/255)  // #ADADAD
    private let answerGray = Color(red: 0.56, green: 0.57, blue: 0.60)
    private let hairline = Color.black.opacity(0.08)

    private func dm(_ size: CGFloat, _ semibold: Bool = false) -> Font {
        .system(size: size, weight: semibold ? .semibold : .regular)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(faqs.indices, id: \.self) { i in
                    faqItem(index: i)
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
                Text("FAQs").font(dm(18, true)).tracking(-0.54).foregroundColor(ink)
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
                HStack(alignment: .top, spacing: 12) {
                    Text(faqs[index].question)
                        .font(dm(15, true)).tracking(-0.45)
                        .foregroundColor(ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(arrow)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                        .padding(.top, 1)
                }
                .padding(.vertical, 20)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                Text(faqs[index].answer)
                    .font(dm(14)).tracking(-0.42)
                    .foregroundColor(answerGray)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Rectangle().fill(hairline).frame(height: 1)
        }
    }
}

#Preview {
    NavigationStack {
        FAQView()
    }
}
