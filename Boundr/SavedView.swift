import SwiftUI

struct SavedView: View {
    @EnvironmentObject var store: VisaStore

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Saved").font(.largeTitle).fontWeight(.bold)
                    Text("\(store.savedVisas.count) visa\(store.savedVisas.count == 1 ? "" : "s")")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.horizontal).padding(.top).padding(.bottom, 20)

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
                        LazyVStack(spacing: 0) {
                            ForEach(store.savedVisas) { visa in
                                NavigationLink(value: visa) {
                                    VisaListRow(visa: visa, isEligible: store.isEligible(visa))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
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
