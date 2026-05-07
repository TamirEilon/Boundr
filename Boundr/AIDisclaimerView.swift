import SwiftUI

struct AIDisclaimerView: View {
    var body: some View {
        LegalPageView(title: "AI Disclaimer", sections: [
            LegalSection(heading: "", body: "Welcome to Boundr. This application uses artificial intelligence (AI) technology to assist with visa information and guidance. Before using our services, please read this AI disclaimer carefully."),

            LegalSection(heading: "IMPORTANT NOTICE", body: "Boundr provides general visa information only and is NOT a substitute for professional immigration advice or legal counsel. Immigration laws are complex, constantly changing, and vary significantly by country and individual circumstances. Always consult with licensed immigration attorneys or official government sources before making any visa or immigration decisions."),

            LegalSection(heading: "1. Nature of AI Service", body: "Boundr uses artificial intelligence (AI) technology to:\n\n• Answer general questions about visa requirements and processes\n• Provide information from our visa database and current internet sources\n• Offer guidance on visa eligibility based on user-provided information\n• Assist with understanding visa application procedures\n\nOur AI assistant is a computer program designed to provide informational support. It is not a human immigration expert, lawyer, or government official."),

            LegalSection(heading: "2. Not Legal or Immigration Advice", body: "Boundr does NOT provide legal advice or professional immigration services. The information provided by our AI assistant:\n\n• Is for general informational purposes only\n• Should not be relied upon as legal, immigration, or professional advice\n• Does not create an attorney-client or advisor-client relationship\n• Cannot replace consultation with qualified immigration professionals\n• May not reflect the most recent changes in immigration laws or policies"),

            LegalSection(heading: "3. Limitations of AI Technology", body: "While our AI assistant is designed to be helpful and informative, it has significant limitations:\n\n• Cannot understand complex individual circumstances\n• May provide incomplete or inaccurate information\n• Cannot predict visa outcomes\n• Limited to available data, which may not include the most recent updates\n• Cannot replace human judgment in complex immigration decisions"),

            LegalSection(heading: "4. Data Accuracy and Currency", body: "Visa requirements, fees, processing times, and immigration policies change frequently. While we strive to provide current information, our database may not always reflect the most recent changes. Always verify all information directly with official government immigration websites, embassies, or consulates before taking any action."),

            LegalSection(heading: "5. Eligibility Assessment Limitations", body: "Our AI-powered eligibility checker provides a preliminary assessment only, based solely on basic criteria you provide. It cannot account for all factors that affect visa eligibility, does not guarantee visa approval, and may miss important requirements or exceptions.\n\nA \"you're eligible\" indicator does not mean your visa will be approved. A \"not eligible\" indicator does not definitively mean you cannot obtain the visa."),

            LegalSection(heading: "6. User Responsibility", body: "By using Boundr, you acknowledge and agree that:\n\n• You are responsible for all decisions and actions you take based on information from our platform\n• You will verify all information with official sources before making decisions\n• You understand the limitations of AI technology\n• You will seek professional advice when appropriate\n• You will not rely solely on our AI assistant for important immigration decisions"),

            LegalSection(heading: "7. Potential Risks", body: "Using Boundr carries certain risks, including but not limited to:\n\n• Reliance on inaccurate or outdated information\n• Missed requirements the AI may not identify\n• Delayed professional consultation due to over-reliance on AI\n• Misinterpretation of AI responses\n• Application errors resulting from incorrect information"),

            LegalSection(heading: "8. Privacy and Data Usage", body: "When you interact with our AI assistant, your conversations are processed by AI systems and data is encrypted and stored securely. We may use anonymized data to improve our AI system. Please refer to our Privacy Policy for detailed information on data handling.\n\nDo not share sensitive personal information such as passport numbers or financial details with the AI assistant."),

            LegalSection(heading: "9. Continuous Development", body: "Our AI technology is continuously evolving. The AI's capabilities and responses may change over time. We regularly update our systems to improve accuracy and functionality. Users should review this disclaimer periodically for updates."),

            LegalSection(heading: "10. Third-Party AI Services", body: "Our AI assistant may utilize third-party AI services and APIs. We are not responsible for the accuracy, reliability, or availability of these third-party services. Outages or changes to third-party AI providers may affect the availability or quality of our AI features."),

            LegalSection(heading: "11. Limitation of Liability", body: "To the fullest extent permitted by law, Boundr and its affiliates shall not be liable for any damages, losses, or consequences arising from use of or reliance on AI-generated information, inaccurate or outdated information, visa application rejections, or any actions taken based on interactions with our AI assistant."),

            LegalSection(heading: "12. Acceptance of Terms", body: "By using Boundr's AI features, you acknowledge that you have read, understood, and agree to this AI disclaimer. If you do not agree with any part of this disclaimer, please do not use our AI assistant or other AI-powered features."),

            LegalSection(heading: "Remember", body: "Immigration decisions can significantly impact your life. Always prioritize official government sources and qualified professional advice over AI-generated information. Use Boundr as a starting point for research, not as your sole source of immigration guidance."),

            LegalSection(heading: "13. Contact Information", body: "If you have questions about this AI disclaimer or concerns about our AI services, please contact us through the Contact Us page in this app.")
        ])
    }
}
