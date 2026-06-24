import SwiftUI

struct SavedView: View {
    @EnvironmentObject var store: VisaStore

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Saved")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                if store.savedVisas.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 44))
                            .foregroundColor(Color(.systemGray4))
                        Text("No saved visas yet")
                            .font(.headline).foregroundColor(.secondary)
                        Text("Tap the bookmark icon on any visa to save it here.")
                            .font(.subheadline).foregroundColor(Color(.systemGray3))
                            .multilineTextAlignment(.center).padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.savedVisas) { visa in
                                NavigationLink(value: visa) {
                                    VisaListRow(visa: visa, eligibility: store.eligibility(visa))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(for: Visa.self) { VisaDetailView(visa: $0) }
        }
    }
}

#Preview {
    SavedView().environmentObject(VisaStore())
}
