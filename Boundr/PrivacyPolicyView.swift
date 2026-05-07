import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        LegalPageView(title: "Privacy Policy", sections: [
            LegalSection(heading: "", body: "Welcome to Boundr (\"we,\" \"us,\" \"our\"). We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice, or our practices with regards to your personal information, please contact us."),

            LegalSection(heading: "1. What Information Do We Collect?", body: "We collect personal information that you voluntarily provide to us when you register on the application, express an interest in obtaining information about us or our products and services, or otherwise when you contact us.\n\nThe personal information we collect may include:\n\n• Personal Identification Information: Full name and email address.\n• Profile Information for Eligibility: Age, nationalities, occupation, education level, marital status, country of residence.\n• Usage Data: Information on how you use the application, such as saved visas and pages visited."),

            LegalSection(heading: "2. How Do We Use Your Information?", body: "We use personal information collected via our application for a variety of business purposes. We use the information we collect or receive:\n\n• To facilitate account creation and the logon process.\n• To power our core feature, the visa eligibility checker, and to personalize your experience.\n• To manage your account and keep it in working order.\n• To respond to your inquiries and solve any potential issues you might have with the use of our Services."),

            LegalSection(heading: "3. Will Your Information Be Shared With Anyone?", body: "We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations. We do not sell your personal information.\n\nWe may share your data with third-party vendors, service providers, contractors, or agents who perform services for us or on our behalf, including AI service providers and data hosting providers."),

            LegalSection(heading: "4. How Do We Keep Your Information Safe?", body: "We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure."),

            LegalSection(heading: "5. What Are Your Privacy Rights?", body: "You may review, change, or terminate your account at any time. If you would like to review or change the information in your account, you can log in to your account settings and update your user account. Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases."),

            LegalSection(heading: "6. How Can You Contact Us About This Policy?", body: "If you have questions or comments about this policy, you may contact us through the Contact Us page in this app.")
        ])
    }
}
