import Foundation
import SwiftUI

// MARK: - AI Recommendation Data Models

/// Structured data model for AI-generated sun safety recommendations
/// Will integrate with Foundation Models framework when available
/// Note: @Generable macro will be added when FoundationModels becomes available
struct AIRecommendation {
    /// Priority level of the recommendation
    let priority: RecommendationPriority
    
    /// Main recommendation message
    let message: String
    
    /// Time context for the recommendation
    let timeframe: String
    
    /// AI reasoning behind the recommendation
    let reasoning: String
    
    /// Category of the recommendation
    let category: RecommendationCategory
    
    /// Icon name for visual representation
    let iconName: String
    
    /// Color scheme for the recommendation
    let colorScheme: RecommendationColor
}

/// Priority levels for recommendations
enum RecommendationPriority: String, CaseIterable {
    case critical = "critical"      // Immediate danger (UV 10+, extreme conditions)
    case urgent = "urgent"          // High risk (UV 8-9, needs immediate action)
    case important = "important"    // Moderate risk (UV 6-7, plan ahead)
    case routine = "routine"        // Normal precautions (UV 3-5)
    case informational = "info"     // General tips and insights
    
    var displayName: String {
        switch self {
        case .critical: return "Critical Alert"
        case .urgent: return "Urgent"
        case .important: return "Important"
        case .routine: return "Routine"
        case .informational: return "Good to Know"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .urgent: return 1
        case .important: return 2
        case .routine: return 3
        case .informational: return 4
        }
    }
}

/// Categories of sun safety recommendations
enum RecommendationCategory: String, CaseIterable {
    case timing = "timing"           // When to go outside/avoid sun
    case protection = "protection"   // SPF, clothing, accessories
    case hydration = "hydration"     // Water intake, cooling
    case activity = "activity"       // Exercise, outdoor plans
    case medical = "medical"         // Health considerations
    case planning = "planning"       // Future activities, travel
    case recovery = "recovery"       // Post-exposure care
    case environmental = "environmental" // Air quality, pollen, weather
    
    var displayName: String {
        switch self {
        case .timing: return "Timing"
        case .protection: return "Protection"
        case .hydration: return "Hydration"
        case .activity: return "Activities"
        case .medical: return "Health"
        case .planning: return "Planning"
        case .recovery: return "Recovery"
        case .environmental: return "Environment"
        }
    }
    
    var defaultIcon: String {
        switch self {
        case .timing: return "clock.fill"
        case .protection: return "shield.fill"
        case .hydration: return "drop.fill"
        case .activity: return "figure.walk"
        case .medical: return "cross.fill"
        case .planning: return "calendar"
        case .recovery: return "heart.fill"
        case .environmental: return "cloud.sun.fill"
        }
    }
}

/// Color schemes for recommendations
enum RecommendationColor: String, CaseIterable {
    case red = "red"         // Critical/urgent
    case orange = "orange"   // Important/warning
    case blue = "blue"       // Informational/routine
    case green = "green"     // Positive/safe
    case purple = "purple"   // Planning/future
    case teal = "teal"       // Health/medical
    
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .teal: return .teal
        }
    }
    
    var lightColor: Color {
        return color.opacity(0.1)
    }
}

// MARK: - User Context Models

/// User profile information for personalized recommendations
struct UserSunProfile {
    /// Skin type (Fitzpatrick scale 1-6)
    let skinType: SkinType
    
    /// Age range for age-appropriate advice
    let ageRange: AgeRange
    
    /// Current medications that affect photosensitivity
    let photosensitiveMedications: Bool
    
    /// Typical outdoor activities
    let activities: [OutdoorActivity]
    
    /// Sun exposure preferences
    let preferences: SunExposurePreferences
    
    /// Create a validated user profile with safe defaults
    /// Uses most conservative settings for user safety
    static func validated(
        skinType: SkinType = .type1, // Most conservative - burns easily
        ageRange: AgeRange = .adult,
        photosensitiveMedications: Bool = false,
        activities: [OutdoorActivity] = [.walking],
        preferences: SunExposurePreferences = SunExposurePreferences()
    ) -> UserSunProfile {
        return UserSunProfile(
            skinType: skinType,
            ageRange: ageRange,
            photosensitiveMedications: photosensitiveMedications,
            activities: activities.isEmpty ? [.walking] : activities,
            preferences: preferences
        )
    }
}

enum SkinType: Int, CaseIterable {
    case type1 = 1  // Very fair, always burns, never tans
    case type2 = 2  // Fair, usually burns, tans minimally
    case type3 = 3  // Medium, sometimes burns, tans gradually
    case type4 = 4  // Olive, rarely burns, tans easily
    case type5 = 5  // Brown, very rarely burns, tans darkly
    case type6 = 6  // Black, never burns, tans very darkly
    
    var description: String {
        switch self {
        case .type1: return "Very Fair"
        case .type2: return "Fair"
        case .type3: return "Medium"
        case .type4: return "Olive"
        case .type5: return "Brown"
        case .type6: return "Black"
        }
    }
    
    var baseProtectionTime: Int {
        switch self {
        case .type1: return 5   // Burns in 5 minutes
        case .type2: return 10  // Burns in 10 minutes
        case .type3: return 15  // Burns in 15 minutes
        case .type4: return 20  // Burns in 20 minutes
        case .type5: return 25  // Burns in 25 minutes
        case .type6: return 30  // Burns in 30 minutes
        }
    }
}

enum AgeRange: String, CaseIterable {
    case child = "child"           // Under 18
    case youngAdult = "young"      // 18-30
    case adult = "adult"           // 31-50
    case middleAge = "middle"      // 51-65
    case senior = "senior"         // 65+
    
    var needsExtraProtection: Bool {
        return self == .child || self == .senior
    }
}

enum OutdoorActivity: String, CaseIterable {
    case walking = "walking"
    case running = "running"
    case cycling = "cycling"
    case swimming = "swimming"
    case beach = "beach"
    case hiking = "hiking"
    case sports = "sports"
    case gardening = "gardening"
    case work = "work"
    case travel = "travel"
    
    var exposureMultiplier: Double {
        switch self {
        case .walking, .work: return 1.0
        case .running, .cycling: return 1.2  // More sweating
        case .swimming, .beach: return 1.5   // Water reflection
        case .hiking: return 1.3             // Altitude/reflection
        case .sports: return 1.4             // High activity
        case .gardening: return 1.1          // Prolonged exposure
        case .travel: return 1.0             // Variable
        }
    }
}

struct SunExposurePreferences {
    /// Prefers shade when available
    let prefersShade: Bool
    
    /// Usually applies sunscreen
    let usesSunscreen: Bool
    
    /// Wears protective clothing
    let wearsProtectiveClothing: Bool
    
    /// Willing to adjust outdoor timing
    let flexibleTiming: Bool
    
    /// Interested in tanning
    let seeksTan: Bool
    
    /// Create preferences with safe defaults
    init(
        prefersShade: Bool = true,
        usesSunscreen: Bool = true,
        wearsProtectiveClothing: Bool = false,
        flexibleTiming: Bool = true,
        seeksTan: Bool = false
    ) {
        self.prefersShade = prefersShade
        self.usesSunscreen = usesSunscreen
        self.wearsProtectiveClothing = wearsProtectiveClothing
        self.flexibleTiming = flexibleTiming
        self.seeksTan = seeksTan
    }
}

// MARK: - Environmental Context

/// Environmental conditions for AI analysis
struct EnvironmentalContext {
    /// Current UV index
    let uvIndex: Double
    
    /// Weather conditions
    let weather: WeatherCondition
    
    /// Air quality index (if available)
    let airQuality: AirQualityLevel?
    
    /// Pollen count (if available)
    let pollenLevel: PollenLevel?
    
    /// Altitude above sea level
    let altitude: Double
    
    /// Time of day
    let timeOfDay: TimeOfDay
    
    /// Season
    let season: Season
    
    /// Create validated environmental context
    static func validated(
        uvIndex: Double,
        weather: WeatherCondition = .clear,
        airQuality: AirQualityLevel? = nil,
        pollenLevel: PollenLevel? = nil,
        altitude: Double = 0,
        timeOfDay: TimeOfDay,
        season: Season
    ) -> EnvironmentalContext {
        return EnvironmentalContext(
            uvIndex: SafetyConstants.UVIndex.validate(uvIndex),
            weather: weather,
            airQuality: airQuality,
            pollenLevel: pollenLevel,
            altitude: max(0, altitude), // Ensure non-negative altitude
            timeOfDay: timeOfDay,
            season: season
        )
    }
    
    /// Check if conditions are safe for outdoor activities
    var isSafeForOutdoorActivity: Bool {
        return uvIndex < SafetyConstants.UVIndex.extremeThreshold &&
               weather != .stormy &&
               airQuality != .hazardous
    }
    
    /// Get recommended SPF based on conditions
    var recommendedSPF: Int {
        return SafetyConstants.SPF.recommended(for: uvIndex)
    }
}

enum WeatherCondition: String, CaseIterable {
    case clear = "clear"
    case partlyCloudy = "partly_cloudy"
    case cloudy = "cloudy"
    case overcast = "overcast"
    case rainy = "rainy"
    case stormy = "stormy"
    case snowy = "snowy"
    case foggy = "foggy"
    case windy = "windy"
    
    var uvModifier: Double {
        switch self {
        case .clear: return 1.0
        case .partlyCloudy: return 0.85
        case .cloudy: return 0.6
        case .overcast: return 0.4
        case .rainy, .stormy: return 0.3
        case .snowy: return 1.2  // Snow reflection
        case .foggy: return 0.5
        case .windy: return 1.0
        }
    }
}

enum AirQualityLevel: String, CaseIterable {
    case good = "good"
    case moderate = "moderate"
    case unhealthy = "unhealthy"
    case hazardous = "hazardous"
}

enum PollenLevel: String, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
}

enum TimeOfDay: String, CaseIterable {
    case earlyMorning = "early_morning"  // 5-8 AM
    case morning = "morning"             // 8-11 AM
    case latemorning = "late_morning"    // 11 AM-12 PM
    case noon = "noon"                   // 12-1 PM
    case earlyAfternoon = "early_afternoon" // 1-3 PM
    case lateAfternoon = "late_afternoon"   // 3-5 PM
    case evening = "evening"             // 5-7 PM
    case sunset = "sunset"               // 7-9 PM
    case night = "night"                 // 9 PM-5 AM
    
    var uvRisk: UVRiskLevel {
        switch self {
        case .earlyMorning, .evening, .sunset, .night: return .low
        case .morning, .lateAfternoon: return .moderate
        case .latemorning: return .high
        case .noon, .earlyAfternoon: return .extreme
        }
    }
}

enum Season: String, CaseIterable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    
    var uvIntensityModifier: Double {
        switch self {
        case .spring: return 1.0
        case .summer: return 1.2
        case .autumn: return 0.9
        case .winter: return 0.7
        }
    }
}

enum UVRiskLevel: String, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
    case extreme = "extreme"
}

// MARK: - Fallback for older iOS versions

/// Simplified recommendation model for backwards compatibility
struct LegacyRecommendation {
    let priority: String
    let message: String
    let timeframe: String
    let reasoning: String
    let category: String
    let iconName: String
    let colorName: String
}

// MARK: - Helper Extensions

extension Array where Element == AIRecommendation {
    /// Sort recommendations by priority
    var sortedByPriority: [AIRecommendation] {
        return sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }
    
    /// Get recommendations by category
    func recommendations(for category: RecommendationCategory) -> [AIRecommendation] {
        return filter { $0.category == category }
    }
    
    /// Get critical and urgent recommendations only
    var highPriorityRecommendations: [AIRecommendation] {
        return filter { $0.priority == .critical || $0.priority == .urgent }
    }
}

// MARK: - Foundation Models Integration (Future)

#if canImport(FoundationModels)
import FoundationModels

extension AIRecommendation {
    /// Convert to Foundation Models compatible format when available
    func toFoundationModelFormat() -> Any {
        // Implementation will be added when FoundationModels is available
        return self
    }
}
#endif