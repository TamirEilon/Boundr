import Foundation

/// Decides when to ask the user to rate Boundr on the App Store.
///
/// We use Apple's native `requestReview` prompt (see `VisaDetailView`), which the
/// system already throttles to at most 3 times per year. On top of that we only
/// surface it right after a positive action — the user saving a visa — and never
/// more than once per app version, so it always lands on a "happy" moment.
@MainActor
enum ReviewManager {
    private static let defaults = UserDefaults.standard
    private static let eventCountKey  = "review_significant_event_count"
    private static let lastVersionKey = "review_last_prompted_version"

    /// Cumulative count of positive actions (visa saves) at which we'll consider
    /// prompting. Spread out so it appears "every once in a while" — never on the
    /// very first save, and again only after sustained engagement.
    private static let milestones: Set<Int> = [2, 6, 15]

    private static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    /// Record one significant engagement event (e.g. opening the app to the main
    /// experience) and report whether a review prompt should be shown right now.
    static func shouldRequestReview() -> Bool {
        let newCount = defaults.integer(forKey: eventCountKey) + 1
        defaults.set(newCount, forKey: eventCountKey)

        // Only at a milestone, and only once per app version.
        guard milestones.contains(newCount) else { return false }
        guard defaults.string(forKey: lastVersionKey) != currentVersion else { return false }

        defaults.set(currentVersion, forKey: lastVersionKey)
        return true
    }
}
