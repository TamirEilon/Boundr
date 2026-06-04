import UserNotifications
import UIKit

// MARK: - NotificationManager

final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    // MARK: - Fact pool

    struct VisaFact {
        let title: String   // short headline shown in expanded view
        let body: String    // full fact body
        let country: String // country whose hero image to use
    }

    private let facts: [VisaFact] = [
        VisaFact(title: "World's most powerful passport",
                 body: "Japan's passport grants visa-free or visa-on-arrival access to 193 countries — ranking it #1 globally on the Henley Passport Index.",
                 country: "Japan"),
        VisaFact(title: "No US digital nomad visa",
                 body: "The US Digital Nomad Visa doesn't exist — America is one of the few developed nations without a dedicated remote-work visa.",
                 country: "United States"),
        VisaFact(title: "Portugal's tax perk",
                 body: "Portugal's NHR tax regime lets new residents pay a flat 20% income tax for 10 years — one of Europe's most attractive fiscal deals.",
                 country: "Portugal"),
        VisaFact(title: "One visa, 27 countries",
                 body: "The Schengen Area covers 27 European countries — a single visa gets you into all of them for up to 90 days.",
                 country: "France"),
        VisaFact(title: "Estonia started it all",
                 body: "Estonia was the first country in the world to launch a dedicated digital nomad visa, back in August 2020.",
                 country: "Estonia"),
        VisaFact(title: "Georgia — live visa-free for a year",
                 body: "Citizens of most countries can live in Georgia visa-free for a full 365 days — no application, no fees.",
                 country: "Japan"),
        VisaFact(title: "Dubai's 5-year remote visa",
                 body: "Dubai's Virtual Working Programme offers a 5-year remote work visa for just $611 USD — one of the most affordable long-term options in the world.",
                 country: "UAE"),
        VisaFact(title: "35+ digital nomad visas",
                 body: "Over 35 countries now offer dedicated digital nomad visas — up from just 3 in 2019. The market is growing fast.",
                 country: "Portugal"),
        VisaFact(title: "Thailand's 10-year LTR visa",
                 body: "Thailand's Long-Term Resident Visa gives remote workers earning $40,000+/year up to 10 years of legal residency and a flat 17% income tax option.",
                 country: "Thailand"),
        VisaFact(title: "Cyprus — 60 days makes you a resident",
                 body: "You can become a tax resident of Cyprus with just 60 days of physical presence per year — one of the lowest thresholds in Europe.",
                 country: "Greece"),
        VisaFact(title: "Germany's no-minimum freelance visa",
                 body: "Germany's Freelance Visa (Freiberufler) has no minimum income requirement — making it one of the most accessible skilled worker routes in Europe.",
                 country: "Germany"),
        VisaFact(title: "UK Global Talent — no job needed",
                 body: "The UK's Global Talent Visa has no minimum salary and no job offer required — just an endorsement from a recognised body in your field.",
                 country: "United Kingdom"),
        VisaFact(title: "Portugal tops Europe for nomads",
                 body: "Portugal has been ranked the #1 destination for digital nomads in Europe for three consecutive years.",
                 country: "Portugal"),
        VisaFact(title: "Andorra has no income tax",
                 body: "Andorra has no income tax — and it sits nestled between France and Spain in the Pyrenees mountains.",
                 country: "France"),
        VisaFact(title: "New Zealand's powerful passport",
                 body: "New Zealand ranks in the top 3 most powerful passports globally, granting access to 185+ countries without a visa.",
                 country: "New Zealand"),
        VisaFact(title: "Malta's EU residency route",
                 body: "Malta offers EU residency through its Global Residence Programme with a minimum tax of €15,000/year — and it comes with full Schengen access.",
                 country: "Malta"),
        VisaFact(title: "Panama's fast residency",
                 body: "Panama's Friendly Nations Visa offers permanent residency to citizens of 50 countries — often processed within just a few months.",
                 country: "Panama"),
        VisaFact(title: "Costa Rica — no army since 1948",
                 body: "Costa Rica abolished its military in 1948 and redirected that budget to education and healthcare — making it one of the most stable countries in Latin America.",
                 country: "Costa Rica"),
        VisaFact(title: "Spain's nomad visa income bar",
                 body: "Spain's Digital Nomad Visa requires a minimum monthly income of 200% of Spain's minimum wage — currently around €2,646/month.",
                 country: "Spain"),
        VisaFact(title: "Canada's open working holiday",
                 body: "Canada's IEC Working Holiday permit requires no job offer before you arrive — just apply, get approved, and work anywhere in Canada for up to 2 years.",
                 country: "Canada"),
    ]

    // MARK: - Category IDs

    private let topMatchCategoryID = "BOUNDR_TOP_MATCH"
    private let factCategoryID     = "BOUNDR_FACT"

    // MARK: - Setup

    override private init() { super.init() }

    func setup() {
        UNUserNotificationCenter.current().delegate = self

        let viewVisa    = UNNotificationAction(identifier: "VIEW_VISA",    title: "View Visa",    options: .foreground)
        let exploreAll  = UNNotificationAction(identifier: "EXPLORE_ALL",  title: "Explore All",  options: .foreground)
        let exploreVisas = UNNotificationAction(identifier: "EXPLORE_VISAS", title: "Explore Visas", options: .foreground)

        let topMatchCategory = UNNotificationCategory(identifier: topMatchCategoryID,
                                                       actions: [viewVisa, exploreAll],
                                                       intentIdentifiers: [],
                                                       options: [])
        let factCategory     = UNNotificationCategory(identifier: factCategoryID,
                                                       actions: [exploreVisas],
                                                       intentIdentifiers: [],
                                                       options: [])

        UNUserNotificationCenter.current().setNotificationCategories([topMatchCategory, factCategory])
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    /// Call this every time the app becomes active with the latest top match.
    func scheduleAll(topMatch: Visa?) async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Remove all previously scheduled notifications and start fresh
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Pre-download the top match hero image once
        var topMatchAttachmentURL: URL? = nil
        if let visa = topMatch, let imgURL = CountryUtils.imageURL(for: visa.country) {
            topMatchAttachmentURL = await downloadAndCache(url: imgURL, filename: "notif_topmatch")
        }

        let calendar  = Calendar.current
        let today     = calendar.startOfDay(for: Date())
        // Determine which fact to start from based on days since a fixed epoch
        let epoch     = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        let daysSinceEpoch = calendar.dateComponents([.day], from: epoch, to: today).day ?? 0
        var factIndex = (daysSinceEpoch / 2) // advances one fact per even day

        for dayOffset in 1...30 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            var components        = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour       = 12
            components.minute     = 0
            components.second     = 0

            let isTopMatchDay = dayOffset % 2 == 1  // odd offsets = top match

            if isTopMatchDay {
                await scheduleTopMatch(
                    visa: topMatch,
                    attachmentURL: topMatchAttachmentURL,
                    triggerComponents: components,
                    identifier: "topMatch_\(dayOffset)"
                )
            } else {
                let fact = facts[factIndex % facts.count]
                factIndex += 1
                let factImageURL = await downloadAndCache(
                    url: CountryUtils.imageURL(for: fact.country),
                    filename: "notif_fact_\(factIndex % facts.count)"
                )
                await scheduleFact(
                    fact: fact,
                    attachmentURL: factImageURL,
                    triggerComponents: components,
                    identifier: "fact_\(dayOffset)"
                )
            }
        }
    }

    // MARK: - Individual schedulers

    private func scheduleTopMatch(visa: Visa?, attachmentURL: URL?, triggerComponents: DateComponents, identifier: String) async {
        let content = UNMutableNotificationContent()

        if let visa {
            content.title    = "Your top match today 🌍"
            content.body     = "\(visa.country) — \(visa.visaName). You're eligible!"
            content.userInfo = ["visaID": visa.id]
        } else {
            content.title = "Your daily visa match is ready 🌍"
            content.body  = "Open Boundr to see which visa best fits your profile today."
        }

        content.sound            = .default
        content.categoryIdentifier = topMatchCategoryID

        if let url = attachmentURL,
           let attachment = try? UNNotificationAttachment(identifier: "heroImage", url: url, options: nil) {
            content.attachments = [attachment]
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    private func scheduleFact(fact: VisaFact, attachmentURL: URL?, triggerComponents: DateComponents, identifier: String) async {
        let content                    = UNMutableNotificationContent()
        content.title                  = "Did you know? 💡"
        content.body                   = fact.body
        content.sound                  = .default
        content.categoryIdentifier     = factCategoryID
        content.userInfo               = ["factTitle": fact.title]

        if let url = attachmentURL,
           let attachment = try? UNNotificationAttachment(identifier: "heroImage", url: url, options: nil) {
            content.attachments = [attachment]
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Image helpers

    private func downloadAndCache(url: URL?, filename: String) async -> URL? {
        guard let url else { return nil }

        let cacheDir  = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL   = cacheDir.appendingPathComponent("\(filename).jpg")

        // Return cached version if fresh enough (< 7 days old)
        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let modified = attrs[.modificationDate] as? Date,
           Date().timeIntervalSince(modified) < 7 * 86400 {
            return fileURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            return nil
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Handle action taps
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Post a notification so the app can navigate if needed
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: .boundrNotificationTapped, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

// MARK: - Notification name

extension Notification.Name {
    static let boundrNotificationTapped = Notification.Name("boundrNotificationTapped")
}
