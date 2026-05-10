"""
Updates all visa descriptions in Firestore to clean 2-sentence versions.
Run: python3 update_descriptions.py
"""

import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

descriptions = {
    ("Argentina", "Digital Nomad Visa"): "Argentina's Digital Nomad Visa allows remote workers and freelancers to live and work legally in the country for up to 180 days, with the possibility of extension. Applicants must demonstrate a stable monthly income from foreign clients or employers, along with valid health insurance and a clean criminal record.",

    ("Australia", "eVisitor (subclass 651)"): "Australia's eVisitor Visa Subclass 651 allows citizens of eligible European countries to visit Australia for tourism or business for up to three months at a time within a 12-month period, completely free of charge. It is applied for online and linked electronically to the holder's passport, with no physical label or stamp required.",

    ("Australia", "Student Visa (Subclass 500)"): "Australia's Student Visa Subclass 500 allows international students to study full-time in a registered course at an Australian educational institution, with the right to work up to 48 hours per fortnight during term time. The visa duration is tied to the length of the enrolled course, and holders may bring eligible family members to Australia.",

    ("Australia", "Skilled Independent Visa (Subclass 189)"): "Australia's Skilled Independent Visa Subclass 189 is a points-tested permanent residency visa for skilled workers who are not sponsored by an employer, state, or family member. Applicants must submit an Expression of Interest through SkillSelect and receive an invitation to apply based on their points score.",

    ("Australia", "Working Holiday Visa (417)"): "Australia's Working Holiday Visa Subclass 417 is designed for young people aged 18 to 30 (or up to 35 for citizens of certain countries) from eligible nations who wish to holiday and work in Australia for up to 12 months. Holders can work for any employer during their stay but are limited to six months with the same employer, and may extend for a second or third year by completing specified regional work.",

    ("Australia", "Temporary Graduate visa (subclass 485)"): "Australia's Temporary Graduate Visa Subclass 485 allows international students who have recently completed a qualification at an Australian institution to live, work, and study in Australia on a temporary basis after graduation. Depending on the stream and location of study, the visa can be granted for between two and six years, giving graduates valuable opportunities to gain Australian work experience.",

    ("Australia", "Electronic Travel Authority (ETA) (subclass 601)"): "Australia's Electronic Travel Authority Subclass 601 allows eligible passport holders to visit Australia for tourism or business for up to three months per visit within a 12-month period, with a small service charge. The ETA is applied for online and linked electronically to the passport, making it one of the most convenient entry options available.",

    ("Austria", "Red-White-Red Card"): "Austria's Red-White-Red Card is a points-based work and residence permit that allows highly qualified workers, skilled workers in shortage occupations, and other key workers to live and work in Austria. Points are awarded for qualifications, work experience, age, and language skills, and successful applicants can bring family members under the associated Red-White-Red Card Plus.",

    ("Belgium", "Single Permit (Combined Residence and Work Permit)"): "Belgium's Single Permit combines a residence permit and work authorization into one document for non-EU nationals who have been offered employment in Belgium. It must be applied for by the employer on behalf of the employee and is issued for the duration of the employment contract.",

    ("Brazil", "Work Visa (VITEM V)"): "Brazil's Work Visa VITEM V is issued to foreign nationals who have signed an employment contract with a Brazilian company or have been transferred by a multinational employer. It is initially valid for two years and can be renewed, with holders eligible to apply for permanent residence after meeting certain conditions.",

    ("Canada", "Study Permit"): "Canada's Study Permit allows international students to study at designated learning institutions across the country for the duration of their academic program. It also permits part-time work on campus and, in many cases, off-campus work of up to 24 hours per week during academic sessions.",

    ("Canada", "eTA (Electronic Travel Authorization)"): "Canada's Electronic Travel Authorization is a mandatory entry requirement for visa-exempt foreign nationals travelling to Canada by air, allowing stays for tourism or business of up to six months. It is valid for five years or until the passport expires and is linked electronically to the traveller's passport.",

    ("Canada", "Temporary Work Permit"): "Canada's Temporary Work Permit allows foreign nationals to work in Canada for a specific employer for a fixed period, typically requiring a Labour Market Impact Assessment to confirm no Canadian worker is available for the role. The permit is tied to a single employer and position unless the holder qualifies for an open work permit.",

    ("Canada", "International Experience Canada (IEC) - Working Holiday"): "Canada's International Experience Canada Working Holiday permit allows young people from participating countries to live and work anywhere in Canada for up to 12 or 24 months, depending on nationality. No job offer is required before applying, making it one of the most flexible work-abroad programs available.",

    ("Canada", "Post‑Graduation Work Permit (PGWP)"): "Canada's Post-Graduation Work Permit is an open work permit that allows eligible graduates of Canadian designated learning institutions to gain Canadian work experience after completing their studies. The duration of the permit matches the length of the completed program, up to a maximum of three years.",

    ("Chile", "Temporary Work Visa"): "Chile's Temporary Work Visa is granted to foreign nationals who have received a job offer from a Chilean employer, allowing them to live and work in Chile for the duration of their contract. After one year of legal residence, holders become eligible to apply for permanent residency.",

    ("Costa Rica", "Digital Nomad Visa"): "Costa Rica's Digital Nomad Visa allows remote workers and self-employed professionals to live in the country for up to one year, with the option to renew for a further year. Applicants must demonstrate a minimum monthly income of USD 3,000 from foreign sources and are exempt from paying income tax on their foreign earnings.",

    ("Croatia", "Digital Nomad Visa"): "Croatia's Digital Nomad Visa allows non-EU remote workers to live in Croatia for up to one year while continuing to work for employers or clients based outside the country. Holders are not permitted to work for Croatian companies and are exempt from Croatian income tax on their foreign income.",

    ("Czech Republic", "Employee Card"): "The Czech Republic's Employee Card is a combined residence and work permit for non-EU nationals who have received a job offer from a Czech employer in a position listed in the central register of vacancies. It is issued for the duration of the employment contract and can be renewed, with holders entitled to bring family members.",

    ("Denmark", "Pay Limit Scheme"): "Denmark's Pay Limit Scheme offers a fast-track residence and work permit for non-EU nationals who have received a job offer with an annual salary above the qualifying threshold. The permit is tied to the sponsoring employer and is valid for up to four years.",

    ("Estonia", "Digital Nomad Visa"): "Estonia's Digital Nomad Visa allows remote workers employed by foreign companies or running their own foreign business to live and work legally in Estonia for up to one year. It was one of the first dedicated digital nomad visas in Europe and requires proof of a minimum monthly income to qualify.",

    ("Finland", "Residence Permit for an Employee"): "Finland's Residence Permit for an Employee allows non-EU nationals to live and work in Finland under a specific employment contract, with most applicants requiring a positive labour market test unless working in a shortage occupation. The permit is issued for the duration of the employment, up to a maximum of four years, and can be renewed.",

    ("France", "Autorisation Provisoire de Séjour (APS)"): "France's Autorisation Provisoire de Séjour is a temporary residence permit issued to international graduates of French higher education institutions, allowing them to stay in France for up to 12 months to seek employment or establish a business related to their degree. Holders are permitted to work during this period and may transition to a long-stay work permit upon securing qualifying employment.",

    ("France", "Long-Stay Student Visa (VLS-TS)"): "France's Long-Stay Student Visa VLS-TS allows international students accepted to a French higher education institution to study in France for more than 90 days, functioning as both a visa and a first residence permit. Students are permitted to work part-time during their studies, up to 60% of the legal annual working hours.",

    ("Germany", "Residence permit for skilled workers (Section 18a/18b AufenthG)"): "Germany's Residence Permit for Skilled Workers allows non-EU nationals with recognized vocational qualifications or university degrees to work in qualified employment in Germany. The permit can be extended and may lead to permanent settlement after several years of continuous legal employment.",

    ("Germany", "EU Blue Card"): "Germany's EU Blue Card is a residence and work permit for highly qualified non-EU nationals with a university degree and a job offer meeting the minimum salary threshold. After 21 months of pension contributions — or 33 months with sufficient German language skills — holders can apply for permanent residence.",

    ("Germany", "Residence permit to seek employment after studies/training (Section 20 AufenthG)"): "Germany's Residence Permit under Section 20 allows qualified non-EU graduates and skilled workers who completed studies or training in Germany to remain for up to 18 months to search for suitable employment. During this period, holders may take up any work to support themselves, and upon finding a qualifying job can transition directly to a work residence permit.",

    ("Greece", "Digital Nomad Visa"): "Greece's Digital Nomad Visa allows non-EU remote workers and freelancers to live in Greece for up to 12 months while working for employers or clients based outside the country. The visa can be renewed for additional one-year periods, and holders may bring family members under the same scheme.",

    ("Iceland", "Long-term Visa for Remote Work"): "Iceland's Long-Term Visa for Remote Work allows foreign nationals employed outside Iceland to live in the country for up to six months while continuing their remote work. Applicants must demonstrate a minimum monthly income and hold valid health insurance covering the duration of their stay.",

    ("Ireland", "Critical Skills Employment Permit"): "Ireland's Critical Skills Employment Permit is designed to attract highly skilled workers in occupations identified as being in short supply, requiring a job offer with a minimum annual salary of EUR 38,000 for most roles. It provides a direct pathway to long-term residency and allows the holder's spouse or partner to also apply for a work permit.",

    ("Israel", "ETA‑IL (Electronic Travel Authorization)"): "Israel's ETA-IL is a mandatory pre-travel electronic authorization for citizens of visa-exempt countries visiting Israel for short stays of up to 90 days per entry, valid for two years from the date of issue. It is applied for online before travel and is required even when the traveller's country has a visa-free agreement with Israel.",

    ("Italy", "Work Visa (Lavoro Subordinato)"): "Italy's Work Visa for Subordinate Employment allows non-EU nationals to enter Italy to work under an employment contract with an Italian employer, subject to the annual quota system known as the Decreto Flussi. Upon arrival, the holder must sign a residence contract at the immigration office and apply for a residence permit.",

    ("Japan", "Highly Skilled Professional Visa"): "Japan's Highly Skilled Professional Visa uses a points-based system to attract foreign professionals in advanced academic research, specialized technical fields, or senior business management, with higher points granting faster access to permanent residency. Applicants accumulating 70 or more points receive preferential immigration treatment, including a pathway to permanent residence after just one year.",

    ("Japan", "Temporary Visitor Visa"): "Japan's Temporary Visitor Visa allows foreign nationals to visit Japan for tourism, family visits, or short business meetings for stays of up to 90 days, depending on nationality. Citizens of countries with a visa exemption agreement with Japan do not need to apply in advance.",

    ("Malta", "Nomad Residence Permit"): "Malta's Nomad Residence Permit allows non-EU remote workers to live in Malta for up to one year while working for employers or clients based outside the country, with the option to renew for up to three years. Applicants must demonstrate a minimum gross monthly income of EUR 2,700 and hold valid health insurance.",

    ("Mexico", "Temporary Resident Card (Work)"): "Mexico's Temporary Resident Card for Work allows foreign nationals who have received a job offer from a Mexican employer to live and work legally in Mexico for up to four years. After four consecutive years of legal residence, holders are eligible to apply for permanent residency.",

    ("Netherlands", "Highly Skilled Migrant Visa"): "The Netherlands' Highly Skilled Migrant Visa allows non-EU professionals to live and work in the Netherlands for an employer recognized as a sponsor by the Dutch Immigration Service, with a minimum salary threshold that varies by age. It is one of the fastest work permits to process in Europe, typically decided within two weeks.",

    ("Netherlands", "Working Holiday Visa"): "The Netherlands' Working Holiday Visa allows young people from a small number of countries with bilateral agreements to live and work in the Netherlands for up to one year. Applicants must be between 18 and 30 years of age and meet basic financial and health insurance requirements.",

    ("New Zealand", "NZeTA (New Zealand Electronic Travel Authority)"): "New Zealand's Electronic Travel Authority is required for visitors from visa waiver countries to travel to New Zealand without a traditional visa, and is applied for online before departure. An International Visitor Conservation and Tourism Levy is also charged alongside the NZeTA application.",

    ("New Zealand", "Skilled Migrant Category Resident Visa"): "New Zealand's Skilled Migrant Category Resident Visa is a points-based permanent residency visa for skilled workers who can contribute to the New Zealand economy, with points awarded for employment, qualifications, age, and work experience. Applicants must first submit an Expression of Interest and receive an invitation to apply based on their points score.",

    ("Norway", "Skilled Worker Residence Permit"): "Norway's Skilled Worker Residence Permit allows non-EU nationals with a concrete job offer or self-employment to live and work in Norway, provided they hold relevant qualifications or a university degree. The permit is initially granted for up to three years and can lead to permanent residence after three years of continuous legal work in the country.",

    ("Poland", "Work Permit type A"): "Poland's Work Permit Type A allows non-EU nationals to work in Poland for a specific employer named in the permit, which is issued by the regional governor based on the employer's application. It is valid for up to three years and is one of the most common work authorization routes for foreign workers in Poland.",

    ("Portugal", "Digital Nomad Visa (D8)"): "Portugal's Digital Nomad Visa D8 allows remote workers and freelancers who earn at least four times the Portuguese minimum wage from foreign sources to live in Portugal for up to one year, with the option to extend and transition to residency. Holders enjoy access to Portugal's public services and may bring dependent family members under the family reunification scheme.",

    ("Portugal", "Portugal D2 (Entrepreneur/Independent Professional)"): "Portugal's D2 Visa is designed for non-EU entrepreneurs, freelancers, and independent professionals who wish to establish or expand a business in Portugal, requiring a viable business plan and sufficient financial means. Successful applicants receive a temporary residence permit that can be renewed and eventually leads to permanent residency and citizenship eligibility.",

    ("Singapore", "Employment Pass"): "Singapore's Employment Pass is issued to foreign professionals, managers, and executives who have been offered a job in Singapore earning at least SGD 5,000 per month, with higher thresholds for those in the financial services sector. It is valid for up to two years initially and can be renewed, with holders able to bring family members on dependent passes.",

    ("South Korea", "K-ETA (Korea Electronic Travel Authorization)"): "South Korea's Korea Electronic Travel Authorization is a mandatory pre-travel electronic permission for citizens of visa-free countries who wish to visit for tourism, business, or transit for stays of up to 90 days. It is applied for online, valid for two years from the date of issue, and allows multiple entries.",

    ("South Korea", "E-7 Skilled Worker Visa"): "South Korea's E-7 Visa is issued to foreign professionals with specific technical expertise in designated occupational categories who have received a job offer from a Korean employer. It is valid for one year initially and can be renewed, with long-term holders eligible to apply for an F-2 residency visa.",

    ("Spain", "Highly Qualified Professional (HQP/PAC) residence and work authorization"): "Spain's Highly Qualified Professional authorization offers a fast-track residence and work permit for non-EU nationals hired in highly skilled roles by major companies, with applications processed within 20 days. Holders can bring family members without separate labour market testing and benefit from reduced bureaucracy compared to standard work permit routes.",

    ("Spain", "Digital Nomad Visa"): "Spain's Digital Nomad Visa allows non-EU remote workers and freelancers who work primarily for clients or employers outside Spain to live in the country for up to one year, with the option to renew for up to five years. Applicants must demonstrate a minimum monthly income equivalent to 200% of Spain's minimum wage and hold valid health insurance.",

    ("Sweden", "Work Permit"): "Sweden's Work Permit allows non-EU nationals who have received a job offer from a Swedish employer to live and work in Sweden for the duration of their employment, up to two years per permit period. After four years of total work permit time in Sweden within a five-year period, holders become eligible to apply for permanent residency.",

    ("Switzerland", "B Permit (Residence and Work)"): "Switzerland's B Permit is a renewable annual residence permit issued to non-EU nationals who hold an employment contract of more than one year with a Swiss employer. After five years of continuous residence on a B Permit, holders may be eligible to apply for the C Permit, which grants indefinite leave to remain.",

    ("Switzerland", "Work Permit L (Short-term)"): "Switzerland's L Permit is a short-term residence permit for non-EU nationals with fixed-term employment contracts of less than one year, tied to a specific employer and role. It can be renewed up to a maximum total stay of 24 months and does not provide a direct pathway to long-term residency.",

    ("Thailand", "Long Term Resident (LTR) Visa - Work from Thailand"): "Thailand's Long-Term Resident Visa for Work from Thailand is a 10-year visa designed to attract highly skilled professionals and remote workers who wish to live in Thailand while working for overseas employers. Qualifying remote workers must earn a minimum of USD 40,000 per year and be employed by a company with at least three years of operating history.",

    ("UAE", "Employment Visa"): "The UAE's Employment Visa allows foreign nationals who have received a job offer from a UAE-based employer to live and work in the country for the duration of their employment contract. The visa is sponsored and processed by the employer and is typically issued for two years, renewable upon contract renewal.",

    ("United Kingdom", "Standard Visitor Visa"): "The UK Standard Visitor Visa allows non-visa-exempt nationals to visit the United Kingdom for tourism, business meetings, short-term studies, or family visits for up to six months. It does not permit the holder to work or access public funds during their stay.",

    ("United Kingdom", "Seasonal Worker visa (Temporary Work)"): "The UK Seasonal Worker Visa allows overseas nationals to come to the UK for up to six months to work in horticulture or poultry processing with an approved sponsor. It does not lead to settlement and holders must leave when their visa expires.",

    ("United Kingdom", "Electronic Travel Authorisation (ETA)"): "The UK Electronic Travel Authorisation is a digital permission to travel required for visa-exempt nationals visiting or transiting through the UK for up to six months. It is applied for online before travel and is linked electronically to the holder's passport.",

    ("United Kingdom", "Global Talent visa (unsponsored work route)"): "The UK Global Talent Visa is an unsponsored route for internationally recognized leaders and emerging talent in academia, research, arts, culture, or digital technology to live and work in the UK without being tied to a specific employer. Applicants must be endorsed by a designated competent body in their field, and there is no minimum salary requirement or job offer needed.",

    ("United Kingdom", "Student Visa"): "The UK Student Visa allows international students accepted onto a course at a UK-licensed student sponsor institution to study in the country for the duration of their programme. Students on eligible courses can work part-time during their studies and may be able to switch to a Graduate Visa upon completion.",

    ("United Kingdom", "Innovator Founder visa"): "The UK Innovator Founder Visa is for experienced businesspeople who wish to establish a genuine, innovative, and scalable business in the UK, requiring endorsement from an approved body confirming the business idea meets the relevant criteria. There is no minimum investment requirement, and successful applicants can apply for settlement after three years.",

    ("United Kingdom", "Graduate visa (post‑study work)"): "The UK Graduate Visa allows eligible international students who have completed a degree at a UK higher education provider to stay and work in the UK for two years after graduating, or three years for PhD graduates. It is an unsponsored visa with no minimum salary requirement, giving graduates the flexibility to gain experience across any sector.",

    ("United Kingdom", "Health and Care Worker visa"): "The UK Health and Care Worker Visa allows eligible medical professionals, including doctors, nurses, and allied health workers, to work for the NHS, NHS suppliers, or in adult social care. It comes with reduced visa fees and is exempt from the Immigration Health Surcharge, making it one of the most affordable routes for skilled healthcare workers.",

    ("United Kingdom", "Skilled Worker Visa"): "The UK Skilled Worker Visa allows non-UK nationals with a job offer from a UK-licensed sponsor employer to live and work in an eligible occupation that meets the minimum skill and salary thresholds. After five years of continuous residence on the Skilled Worker route, holders can apply for indefinite leave to remain.",

    ("United Kingdom", "Youth Mobility Scheme Visa (Tier 5)"): "The UK Youth Mobility Scheme Visa allows young people aged 18 to 30 from participating countries to live, work, and travel freely in the UK for up to two years, with no requirement for a job offer before applying. Participants can work in almost any role for any employer during their stay, making it one of the most flexible routes to UK work experience.",

    ("United Kingdom", "High Potential Individual visa"): "The UK High Potential Individual Visa is an unsponsored work route for recent graduates of eligible top-ranked global universities, allowing them to live and work in the UK for two years, or three years for those with a PhD. No job offer is required, and holders can switch into other work routes once they secure qualifying employment.",

    ("United States", "H-1B Specialty Occupation Visa"): "The US H-1B Visa allows US employers to temporarily employ foreign workers in specialty occupations requiring at least a bachelor's degree or equivalent in a specific technical field. Due to high demand, most H-1B petitions are subject to an annual cap and awarded through a randomized lottery system.",

    ("United States", "O‑1 (US) Extraordinary Ability visa"): "The US O-1 Visa is for individuals who possess extraordinary ability in the sciences, education, business, athletics, or the arts, demonstrated by sustained national or international acclaim. It requires sponsorship from a US employer or agent and is issued initially for up to three years, with unlimited one-year extensions available.",

    ("United States", "B-2 Tourist Visa"): "The US B-2 Tourist Visa allows foreign nationals to visit the United States temporarily for tourism, vacation, visiting family and friends, or receiving medical treatment for up to six months. It does not permit the holder to work or study for academic credit while in the United States.",

    ("United States", "EB‑1A (US) Extraordinary Ability immigrant visa"): "The US EB-1A Immigrant Visa is a green card category for individuals with extraordinary ability in the sciences, arts, education, business, or athletics who have reached the very top of their field. One of its key advantages is that it allows self-petition without the need for an employer sponsor or labour certification.",

    ("United States", "Electronic System for Travel Authorization (ESTA)"): "The US Electronic System for Travel Authorization allows citizens of Visa Waiver Program countries to travel to the United States for tourism or business for up to 90 days without obtaining a visa. Authorization is typically granted within minutes and is valid for two years or until the traveller's passport expires, whichever comes first.",
}

# Fetch all visas from Firestore and update descriptions
visas = db.collection("visas").get()
updated = 0
not_found = []

for doc in visas:
    d = doc.to_dict()
    country = d.get("country", "")
    visa_name = d.get("visa_name", "")
    key = (country, visa_name)
    if key in descriptions:
        doc.reference.update({"description": descriptions[key]})
        updated += 1
    else:
        not_found.append(f"{country} | {visa_name}")

print(f"Updated {updated} visa descriptions.")
if not_found:
    print(f"\nNot matched ({len(not_found)}):")
    for v in not_found:
        print(f"  {v}")
