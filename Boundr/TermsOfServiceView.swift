import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        LegalPageView(title: "Terms of Service", sections: [
            LegalSection(heading: "1. Agreement to Terms", body: "By using our application, Boundr (the \"Service\"), you agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the Service."),

            LegalSection(heading: "2. Description of Service", body: "Boundr provides information regarding global travel visas, including requirements, costs, and processing times. The Service includes an eligibility checker based on user-provided data. Boundr is an informational tool only and does not provide legal or immigration advice.\n\nDisclaimer: The information provided by Boundr is for general guidance only. It is not a substitute for professional immigration advice. You must verify all information with official government sources before taking any action."),

            LegalSection(heading: "3. User Accounts", body: "To access certain features of the Service, you must create an account. You are responsible for safeguarding your account information and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account."),

            LegalSection(heading: "4. Intellectual Property", body: "The Service and its original content, features, and functionality are and will remain the exclusive property of Boundr and its licensors."),

            LegalSection(heading: "5. Disclaimer of Warranties", body: "The Service is provided on an 'AS IS' and 'AS AVAILABLE' basis. We make no warranties, express or implied, that the information is accurate, complete, or current. We expressly disclaim any liability for errors or omissions in the content of the Service. Your use of the Service and your reliance on any information on the Service is solely at your own risk."),

            LegalSection(heading: "6. Limitation of Liability", body: "In no event shall Boundr, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service."),

            LegalSection(heading: "7. Changes to Terms", body: "We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms & Conditions on this page."),

            LegalSection(heading: "8. Contact Us", body: "If you have any questions about these Terms, please contact us through the Contact Us page in this app.")
        ])
    }
}
