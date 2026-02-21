import SwiftUI

// MARK: - Education Topic Enum

enum EducationTopic: String, CaseIterable, Identifiable {
    case uvBasics
    case sunProtection
    case safeExposure
    case sunscreenGuide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .uvBasics: return "UV Index Basics"
        case .sunProtection: return "Sun Protection"
        case .safeExposure: return "Safe Exposure Times"
        case .sunscreenGuide: return "Sunscreen Guide"
        }
    }

    var icon: String {
        switch self {
        case .uvBasics: return "sun.max.fill"
        case .sunProtection: return "shield.fill"
        case .safeExposure: return "clock.fill"
        case .sunscreenGuide: return "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .uvBasics: return AppColors.primary
        case .sunProtection: return AppColors.success
        case .safeExposure: return AppColors.warning
        case .sunscreenGuide: return AppColors.info
        }
    }

    var sections: [(heading: String, body: String)] {
        switch self {
        case .uvBasics:
            return Self.uvBasicsSections
        case .sunProtection:
            return Self.sunProtectionSections
        case .safeExposure:
            return Self.safeExposureSections
        case .sunscreenGuide:
            return Self.sunscreenGuideSections
        }
    }

    // MARK: - UV Basics Content

    private static let uvBasicsSections: [(heading: String, body: String)] = [
        (
            heading: "What Is the UV Index?",
            body: "The UV Index is an international standard measurement of the strength of ultraviolet radiation from the sun at a particular place and time. Developed by the World Health Organization (WHO), it serves as a simple and informative tool to help people gauge when to take precautions against overexposure. The higher the index value, the greater the potential for damage to your skin and eyes, and the less time it takes for harm to occur."
        ),
        (
            heading: "Understanding the Scale",
            body: "The UV Index runs on a scale from 0 upward:\n\n0-2 (Low): Minimal danger for the average person. You can safely enjoy the outdoors with minimal protection.\n\n3-5 (Moderate): Moderate risk of harm from unprotected sun exposure. Wear sunglasses, use SPF 30+ sunscreen, and seek shade during midday hours.\n\n6-7 (High): High risk of harm. Reduce time in the sun between 10 a.m. and 4 p.m., apply sunscreen generously, and wear protective clothing.\n\n8-10 (Very High): Very high risk of harm. Take extra precautions. Unprotected skin and eyes can burn quickly. Minimize sun exposure during midday.\n\n11+ (Extreme): Extreme risk. Unprotected skin can burn in minutes. Avoid being outside during midday hours, seek shade, and wear full protective gear."
        ),
        (
            heading: "Factors That Affect UV Levels",
            body: "Several environmental factors influence how much UV radiation reaches the ground:\n\nTime of day: UV is strongest between 10 a.m. and 4 p.m., when the sun is highest in the sky.\n\nSeason: UV levels peak during spring and summer months in your hemisphere.\n\nLatitude: Areas closer to the equator receive more direct sunlight year-round, leading to higher UV levels.\n\nCloud cover: Thin or scattered clouds block very little UV. Up to 80% of UV rays can penetrate light cloud cover.\n\nOzone layer: The stratospheric ozone layer absorbs some UV radiation. Thinner ozone means higher surface UV."
        ),
        (
            heading: "UV and Altitude",
            body: "UV radiation increases approximately 10-12% for every 1,000 meters (3,280 feet) of elevation gain. At higher altitudes, the atmosphere is thinner and filters out less UV radiation. This is why skiers, hikers, and mountaineers can get sunburned surprisingly quickly, even on cold or overcast days. If you are spending time at high elevation, increase your sun protection accordingly and be especially mindful of reflected UV from snow."
        ),
        (
            heading: "UV and Reflective Surfaces",
            body: "Certain surfaces reflect UV radiation, effectively increasing your total exposure:\n\nFresh snow reflects up to 80% of UV rays, nearly doubling your exposure.\n\nSand reflects about 15-25% of UV, making beach environments particularly intense.\n\nWater reflects around 10-20%, and UV can also penetrate below the surface, affecting swimmers.\n\nConcrete and glass reflect smaller amounts but still contribute to cumulative exposure in urban settings.\n\nBecause of these reflections, you can receive significant UV exposure even while sitting in the shade near reflective surfaces."
        ),
        (
            heading: "Why Monitoring UV Matters",
            body: "According to the WHO, overexposure to UV radiation is a leading cause of skin cancers, premature skin aging, and eye conditions such as cataracts and photokeratitis. The UV Index provides an actionable number you can check daily, just like the temperature, so you can plan outdoor activities with appropriate protection. Making UV awareness a habit is one of the simplest and most effective steps you can take for long-term skin and eye health."
        )
    ]

    // MARK: - Sun Protection Content

    private static let sunProtectionSections: [(heading: String, body: String)] = [
        (
            heading: "UVA vs. UVB Rays",
            body: "The sun emits two types of ultraviolet radiation that reach the earth's surface:\n\nUVA rays (320-400 nm) make up about 95% of the UV radiation reaching the ground. They penetrate deep into the skin's dermis layer, contributing to premature aging, wrinkles, and long-term skin damage. UVA intensity remains relatively constant throughout the day and can penetrate clouds and glass.\n\nUVB rays (280-320 nm) are the primary cause of sunburn and play a key role in the development of skin cancer. They are most intense between 10 a.m. and 4 p.m. and are partially blocked by clouds and glass.\n\nEffective sun protection must guard against both UVA and UVB radiation."
        ),
        (
            heading: "Protective Clothing",
            body: "Clothing is one of the most effective barriers against UV radiation. The EPA and WHO recommend:\n\nTightly woven fabrics in dark or bright colors offer more UV protection than loosely woven, light-colored fabrics.\n\nLong-sleeved shirts and long pants cover more skin and reduce your exposed surface area significantly.\n\nWide-brimmed hats (at least 3 inches / 7.5 cm brim) shade your face, ears, and neck. Baseball caps leave the ears and neck exposed.\n\nUPF-rated clothing has been laboratory-tested to block UV rays. A UPF 50 garment allows only 1/50th of UV radiation through, blocking 98% of rays.\n\nDry fabric generally provides better protection than wet fabric, which can lose up to half its UPF rating."
        ),
        (
            heading: "Seeking Shade Effectively",
            body: "Shade reduces your UV exposure but does not eliminate it entirely. UV radiation scatters in the atmosphere and reflects off surfaces, so you can still receive indirect exposure in the shade.\n\nSeek shade during peak UV hours (10 a.m. to 4 p.m.) when the sun is most intense.\n\nUse the shadow rule: if your shadow is shorter than you are, the UV level is high and you should find shade.\n\nTree canopy shade varies widely. Dense foliage can block up to 90% of UV, while sparse canopy may block less than 50%.\n\nPortable shade structures like umbrellas and pop-up tents provide good protection for outdoor activities, but combine them with sunscreen for areas that are still exposed to scattered UV."
        ),
        (
            heading: "Sunglasses and Eye Protection",
            body: "Your eyes are highly susceptible to UV damage. Prolonged exposure can lead to cataracts, macular degeneration, and photokeratitis (sunburn of the cornea).\n\nChoose sunglasses labeled as blocking 99-100% of both UVA and UVB rays, or labeled UV400.\n\nWrap-around styles prevent UV rays from entering from the sides.\n\nLarger lenses provide more coverage and better protection for the delicate skin around the eyes.\n\nPolarized lenses reduce glare but do not necessarily provide more UV protection unless also labeled UV400.\n\nChildren's eyes are especially vulnerable because their lenses transmit more UV to the retina. Ensure kids wear quality sunglasses outdoors."
        ),
        (
            heading: "Daily Protection Habits",
            body: "The WHO recommends making sun protection part of your daily routine, not just something you do at the beach:\n\nCheck the UV Index every morning just as you check the weather forecast.\n\nApply sunscreen to exposed skin before leaving the house, even on cloudy days.\n\nKeep sunglasses, a hat, and sunscreen in your bag or car so they are always available.\n\nBe extra cautious near water, sand, snow, and at high altitudes where UV exposure is amplified.\n\nRemember that cumulative UV exposure adds up over a lifetime. Daily low-level exposure contributes significantly to long-term skin damage and cancer risk, so consistent protection matters even on days that do not feel particularly sunny."
        )
    ]

    // MARK: - Safe Exposure Content

    private static let safeExposureSections: [(heading: String, body: String)] = [
        (
            heading: "How Skin Type Affects Burn Time",
            body: "Your skin type plays a major role in how quickly you burn under UV radiation. The Fitzpatrick Skin Type scale classifies skin into six types:\n\nType I (very fair): Always burns, never tans. Can burn in as little as 5-10 minutes at UV Index 8.\n\nType II (fair): Burns easily, tans minimally. May burn within 10-15 minutes at UV Index 8.\n\nType III (medium): Sometimes burns, tans gradually. Approximately 15-25 minutes to burn at UV Index 8.\n\nType IV (olive): Rarely burns, tans easily. Around 25-40 minutes to burn at UV Index 8.\n\nType V (brown): Very rarely burns, tans profusely. Approximately 40-60 minutes at UV Index 8.\n\nType VI (very dark): Almost never burns. Over 60 minutes at UV Index 8.\n\nRegardless of skin type, all skin is susceptible to UV damage and long-term cancer risk."
        ),
        (
            heading: "Time-of-Day Variations",
            body: "UV intensity follows a predictable daily pattern driven by the sun's angle:\n\nEarly morning (before 9 a.m.): UV levels are typically low (1-2), making this a safer window for extended outdoor activities.\n\nMid-morning (9-11 a.m.): UV begins to rise rapidly. Protection becomes increasingly important.\n\nSolar noon (11 a.m. - 1 p.m.): UV peaks when the sun is directly overhead and rays travel the shortest path through the atmosphere. This is the most dangerous window.\n\nAfternoon (1-4 p.m.): UV remains high but gradually declines. Significant burn risk still exists.\n\nLate afternoon (after 4 p.m.): UV drops to moderate or low levels, though exposure still accumulates.\n\nPlanning outdoor exercise and activities for early morning or late afternoon can dramatically reduce your UV dose."
        ),
        (
            heading: "Seasonal Changes",
            body: "UV intensity varies significantly with the seasons due to changes in the earth's axial tilt:\n\nSummer: UV levels are at their highest. In many mid-latitude regions, the UV Index can routinely reach 8-11 during peak hours.\n\nSpring: UV levels begin to climb, often catching people off guard. March through May can produce moderate-to-high UV even though temperatures remain cool.\n\nAutumn: UV decreases but remains meaningful. Clear autumn days can still produce UV Index values of 4-6.\n\nWinter: UV is generally at its lowest in temperate zones, but snow reflection can significantly boost effective exposure, especially at altitude.\n\nIn tropical regions near the equator, UV remains high year-round with less seasonal variation."
        ),
        (
            heading: "Cloud Cover Myths",
            body: "One of the most common misconceptions is that clouds provide reliable sun protection:\n\nUp to 80% of UV radiation penetrates thin or scattered clouds. Overcast days can still carry a moderate or high UV Index.\n\nBroken cloud cover can actually increase UV exposure through a phenomenon called cloud enhancement, where UV rays are reflected and focused by cloud edges.\n\nYou can get sunburned on a cloudy day just as badly as on a clear day if you skip protection.\n\nFog provides minimal UV protection. Water droplets in fog scatter visible light more than UV rays.\n\nThe only reliable way to know your UV exposure is to check the UV Index rather than judging by how sunny or cloudy it appears outside."
        ),
        (
            heading: "Practical Exposure Guidelines",
            body: "Based on WHO and EPA recommendations, here are practical guidelines for managing your time outdoors:\n\nAt UV Index 1-2: No protection needed for most people. Enjoy outdoor activities freely.\n\nAt UV Index 3-5: Wear sunglasses and sunscreen. Seek shade during midday. Fair-skinned individuals should limit midday exposure to 30-60 minutes.\n\nAt UV Index 6-7: Reduce sun exposure between 10 a.m. and 4 p.m. Wear protective clothing, a hat, sunglasses, and apply SPF 30+ sunscreen every 2 hours.\n\nAt UV Index 8-10: Minimize outdoor time during midday. Full protection is essential. Fair-skinned people can burn in under 15 minutes.\n\nAt UV Index 11+: Avoid outdoor exposure during midday hours if possible. If you must be outside, take all precautions: shade, full clothing coverage, SPF 50+ sunscreen, hat, and sunglasses."
        ),
        (
            heading: "Building a Vitamin D Balance",
            body: "While excessive sun exposure is harmful, moderate sunlight is the body's primary source of vitamin D, which is essential for bone health and immune function.\n\nMost dermatologists and the WHO suggest that brief, incidental sun exposure during daily activities is usually sufficient for vitamin D production.\n\nFair-skinned individuals may need only 5-15 minutes of midday sun on arms and face a few times per week. Darker skin types may need longer exposure.\n\nVitamin D can also be obtained through diet (fatty fish, fortified dairy, eggs) and supplements, offering an alternative that avoids UV risk.\n\nNever use tanning or deliberate prolonged sun exposure as a strategy for vitamin D. The skin damage risks outweigh the benefits, especially since supplements are a safe alternative."
        )
    ]

    // MARK: - Sunscreen Guide Content

    private static let sunscreenGuideSections: [(heading: String, body: String)] = [
        (
            heading: "SPF Explained",
            body: "SPF stands for Sun Protection Factor and measures how well a sunscreen protects against UVB rays (the primary cause of sunburn).\n\nSPF 15 blocks approximately 93% of UVB rays.\nSPF 30 blocks approximately 97% of UVB rays.\nSPF 50 blocks approximately 98% of UVB rays.\nSPF 100 blocks approximately 99% of UVB rays.\n\nThe difference between SPF 30 and SPF 50 is small in terms of percentage filtered, but it can matter for extended exposure. No sunscreen blocks 100% of UV rays.\n\nSPF also indicates how much longer you can stay in the sun before burning compared to unprotected skin. If you would burn in 10 minutes without sunscreen, SPF 30 theoretically extends that to 300 minutes. However, this is a laboratory estimate. Real-world factors like sweating, swimming, incomplete application, and toweling off reduce the effective protection time significantly."
        ),
        (
            heading: "Broad Spectrum Protection",
            body: "SPF only measures UVB protection. For full protection, you need a sunscreen labeled \"broad spectrum,\" which means it also guards against UVA rays.\n\nUVA rays penetrate deeper into the skin and are the primary driver of photoaging (wrinkles, age spots, loss of elasticity) and contribute to skin cancer.\n\nIn the United States, the FDA requires broad-spectrum sunscreens to pass a critical wavelength test proving meaningful UVA protection.\n\nIn Europe and Australia, UVA protection is rated separately (the UVA circle logo or PA++++ rating in Asian sunscreens).\n\nAlways choose a sunscreen that is both SPF 30 or higher AND labeled broad spectrum to ensure you are protected against the full range of damaging solar radiation."
        ),
        (
            heading: "How Much to Apply",
            body: "Most people apply far too little sunscreen, dramatically reducing its effectiveness. Studies show the average person applies only 25-50% of the recommended amount.\n\nThe standard recommendation is 2 mg per square centimeter of skin, which translates to:\n\nAbout 1 ounce (a full shot glass) to cover an adult body in a swimsuit.\n\nA nickel-sized amount for the face alone.\n\nA full teaspoon for each arm, each leg, the front torso, and the back torso.\n\nApply sunscreen 15-30 minutes before sun exposure to allow it to bind to the skin.\n\nDon't forget commonly missed areas: ears, back of the neck, tops of the feet, the part line in your hair, and the backs of the hands. These overlooked spots are frequent sites of sun damage and skin cancer."
        ),
        (
            heading: "Reapplication Timing",
            body: "Sunscreen effectiveness degrades over time due to UV exposure, sweat, water, and physical contact. The EPA and dermatologists recommend:\n\nReapply every 2 hours during continuous sun exposure, regardless of the SPF level.\n\nReapply immediately after swimming, heavy sweating, or toweling off, even if using water-resistant sunscreen.\n\nWater-resistant sunscreens maintain their SPF for either 40 or 80 minutes of water exposure (as labeled), but they still need reapplication after that window.\n\nIf using sunscreen spray, apply a generous, even coat and rub it in. Sprays are convenient for reapplication but often result in uneven coverage if not applied carefully.\n\nSet a timer or use an app reminder (like SunshAid!) to prompt reapplication so you don't lose track during outdoor activities."
        ),
        (
            heading: "Water Resistance Ratings",
            body: "Sunscreen water resistance is tested under standardized conditions and labeled accordingly:\n\nWater Resistant (40 minutes): The sunscreen maintains its stated SPF after 40 minutes of water immersion. Suitable for light swimming or sweating.\n\nVery Water Resistant (80 minutes): The sunscreen maintains its SPF after 80 minutes of water immersion. Better for prolonged swimming or intense physical activity.\n\nNo sunscreen is truly \"waterproof\" or \"sweatproof.\" These terms have been banned from labeling by the FDA because they give a false sense of security.\n\nAfter the rated water-resistance period, you must reapply to maintain protection.\n\nToweling off removes sunscreen regardless of water resistance. Always reapply after drying yourself with a towel."
        ),
        (
            heading: "Chemical vs. Mineral Sunscreen",
            body: "There are two main categories of sunscreen, each with distinct advantages:\n\nChemical (organic) sunscreens contain ingredients like avobenzone, octinoxate, and oxybenzone that absorb UV radiation and convert it to heat. They tend to be lighter, more cosmetically elegant, and easier to apply without a white cast. However, some chemical filters can irritate sensitive skin and certain ingredients have raised environmental concerns, particularly regarding coral reef health.\n\nMineral (inorganic) sunscreens use zinc oxide and/or titanium dioxide to physically block and scatter UV rays. They are generally better tolerated by sensitive skin, are effective immediately upon application (no waiting period), and are considered reef-safe. The trade-off is that they can leave a visible white cast, though modern formulations with micronized particles have improved this significantly.\n\nFor most people, the best sunscreen is the one you will actually use consistently. If you dislike the texture or appearance, you are less likely to apply it properly and regularly."
        )
    ]
}

// MARK: - Education Detail View

struct EducationDetailView: View {
    let topic: EducationTopic

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Header
                VStack(spacing: 16) {
                    Image(systemName: topic.icon)
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                        .frame(width: 88, height: 88)
                        .background(topic.color)
                        .clipShape(Circle())
                        .shadow(color: topic.color.opacity(0.3), radius: 10, x: 0, y: 5)

                    Text(topic.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Content Sections
                ForEach(Array(topic.sections.enumerated()), id: \.offset) { index, section in
                    EducationSectionCard(
                        index: index + 1,
                        heading: section.heading,
                        content: section.body,
                        accentColor: topic.color
                    )
                }

                // Source attribution
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("Content based on WHO and EPA sun safety guidelines.")
                        .font(.caption)
                }
                .foregroundColor(AppColors.textMuted)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary)
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Education Section Card

struct EducationSectionCard: View {
    let index: Int
    let heading: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("\(index)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(accentColor)
                    .clipShape(Circle())

                Text(heading)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text(content)
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.shadowColor.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Preview

#Preview("UV Basics") {
    NavigationStack {
        EducationDetailView(topic: .uvBasics)
    }
}

#Preview("Sunscreen Guide") {
    NavigationStack {
        EducationDetailView(topic: .sunscreenGuide)
    }
}
