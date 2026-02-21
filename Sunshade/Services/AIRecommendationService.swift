import Foundation
import SwiftUI

import FoundationModels

// MARK: - Weather Condition Mapping

/// Type-safe weather condition mapper that replaces error-prone string parsing
struct WeatherConditionMapper {
    
    /// Comprehensive mapping of weather condition strings to enum values
    private static let conditionMappings: [String: WeatherCondition] = [
        // Clear conditions
        "clear": .clear,
        "sunny": .clear,
        "fair": .clear,
        "bright": .clear,
        
        // Partly cloudy conditions
        "partly cloudy": .partlyCloudy,
        "partly sunny": .partlyCloudy,
        "mostly sunny": .partlyCloudy,
        "mostly clear": .partlyCloudy,
        "few clouds": .partlyCloudy,
        
        // Cloudy conditions
        "cloudy": .cloudy,
        "mostly cloudy": .cloudy,
        "broken clouds": .cloudy,
        "scattered clouds": .cloudy,
        
        // Overcast conditions
        "overcast": .overcast,
        "grey": .overcast,
        "gray": .overcast,
        
        // Rainy conditions
        "rain": .rainy,
        "showers": .rainy,
        "drizzle": .rainy,
        "light rain": .rainy,
        "moderate rain": .rainy,
        "heavy rain": .rainy,
        
        // Stormy conditions
        "thunderstorm": .stormy,
        "storm": .stormy,
        "severe weather": .stormy,
        "lightning": .stormy,
        
        // Snowy conditions
        "snow": .snowy,
        "light snow": .snowy,
        "heavy snow": .snowy,
        "blizzard": .snowy,
        "flurries": .snowy,
        
        // Foggy conditions
        "fog": .foggy,
        "mist": .foggy,
        "haze": .foggy,
        "smoky": .foggy,
        
        // Windy conditions
        "windy": .windy,
        "breezy": .windy,
        "gusty": .windy
    ]
    
    /// Fallback keywords for partial matching when exact match fails
    private static let fallbackKeywords: [(keyword: String, condition: WeatherCondition)] = [
        ("clear", .clear),
        ("sunny", .clear),
        ("partly", .partlyCloudy),
        ("cloud", .cloudy),
        ("overcast", .overcast),
        ("rain", .rainy),
        ("storm", .stormy),
        ("snow", .snowy),
        ("fog", .foggy),
        ("wind", .windy)
    ]
    
    /// Maps a weather condition string to a WeatherCondition enum with type safety
    /// - Parameter conditionString: Raw weather condition string from API
    /// - Returns: Mapped WeatherCondition enum value
    static func mapCondition(_ conditionString: String) -> WeatherCondition {
        let normalizedCondition = conditionString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try exact match first for best accuracy
        if let exactMatch = conditionMappings[normalizedCondition] {
            return exactMatch
        }
        
        // Try partial matching with fallback keywords
        for (keyword, condition) in fallbackKeywords {
            if normalizedCondition.contains(keyword) {
                return condition
            }
        }
        
        // Default to clear if no match found (conservative choice)
        #if DEBUG
        print("⚠️ Unknown weather condition: '\(conditionString)' - defaulting to clear")
        #endif
        return .clear
    }
    
    #if DEBUG
    /// Debug method to test weather condition mappings
    /// - Parameter conditions: Array of weather condition strings to test
    /// - Returns: Dictionary of input conditions to mapped enum values
    static func testMappings(_ conditions: [String]) -> [String: WeatherCondition] {
        return conditions.reduce(into: [:]) { result, condition in
            result[condition] = mapCondition(condition)
        }
    }
    #endif
}

// MARK: - Recommendation Caching

/// Cache entry for AI recommendations with TTL support
private struct RecommendationCacheEntry {
    let recommendations: [AIRecommendation]
    let timestamp: Date
    let parameters: CacheKey
    
    /// Check if cache entry is still valid based on TTL
    func isValid(ttl: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) < ttl
    }
}

/// Cache key for recommendations based on environmental parameters
private struct CacheKey: Hashable {
    let uvIndex: Int  // Rounded to nearest integer for cache efficiency
    let temperature: Int // Rounded temperature
    let weatherCondition: WeatherCondition
    let userProfileHash: Int // Hash of user profile for personalization
    let timeSlot: Int // Hour of day for time-based recommendations
    
    init(uvIndex: Double, weather: WeatherData, userProfile: UserSunProfile, currentTime: Date) {
        self.uvIndex = Int(uvIndex.rounded())
        self.temperature = Int(weather.temperature.rounded())
        self.weatherCondition = WeatherConditionMapper.mapCondition(weather.condition)
        self.userProfileHash = userProfile.hashValue
        self.timeSlot = Calendar.current.component(.hour, from: currentTime)
    }
}

/// Hash extension for UserSunProfile to enable caching
extension UserSunProfile: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(skinType)
        hasher.combine(ageRange)
        hasher.combine(photosensitiveMedications)
        hasher.combine(activities.map { $0.rawValue }.sorted()) // Sort for consistent hashing
    }
    
    static func == (lhs: UserSunProfile, rhs: UserSunProfile) -> Bool {
        return lhs.skinType == rhs.skinType &&
               lhs.ageRange == rhs.ageRange &&
               lhs.photosensitiveMedications == rhs.photosensitiveMedications &&
               Set(lhs.activities) == Set(rhs.activities)
    }
}

/// AI-powered sun safety recommendation service
/// Currently uses intelligent rule-based system, will integrate Apple's Foundation Models when available
class AIRecommendationService: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isGenerating = false
    @Published var lastError: Error?
    @Published var isAvailable = false
    
    // MARK: - Caching Properties
    
    /// In-memory cache for recommendations with TTL support
    private var recommendationCache: [CacheKey: RecommendationCacheEntry] = [:]
    
    /// Cache TTL in seconds (5 minutes default)
    private let cacheTTL: TimeInterval = 300
    
    /// Maximum cache size to prevent memory issues
    private let maxCacheSize = 50
    
    /// Queue for thread-safe cache operations
    private let cacheQueue = DispatchQueue(label: "ai.recommendation.cache", qos: .utility)
    
    private var languageModelSession: LanguageModelSession?
    
    // MARK: - Initialization
    
    init() {
        checkAvailability()
    }
    
    // MARK: - Public Methods
    
    /// Generate personalized AI recommendations
    func generateRecommendations(
        uvIndex: Double,
        weather: WeatherData,
        userProfile: UserSunProfile? = nil,
        currentTime: Date = Date(),
        location: String = ""
    ) async -> [AIRecommendation] {
        
        isGenerating = true
        defer { isGenerating = false }
        
        // Use actual user profile if available, otherwise use safe defaults
        let actualProfile = userProfile ?? UserProfile.shared.toUserSunProfile()
        
        // Check cache first
        let cacheKey = CacheKey(uvIndex: uvIndex, weather: weather, userProfile: actualProfile, currentTime: currentTime)
        
        if let cachedRecommendations = getCachedRecommendations(for: cacheKey) {
            return cachedRecommendations
        }
        
        // Check if Foundation Models is available
        guard isAvailable else {
            let fallbackRecommendations = await generateFallbackRecommendations(
                uvIndex: uvIndex,
                weather: weather,
                userProfile: actualProfile,
                currentTime: currentTime
            )
            cacheRecommendations(fallbackRecommendations, for: cacheKey)
            return fallbackRecommendations
        }
        
        do {
            let context = buildEnvironmentalContext(
                uvIndex: uvIndex,
                weather: weather,
                currentTime: currentTime
            )
            
            let recommendations = try await generateAIRecommendations(
                context: context,
                userProfile: actualProfile,
                location: location
            )
            
            let sortedRecommendations = recommendations.sortedByPriority
            cacheRecommendations(sortedRecommendations, for: cacheKey)
            return sortedRecommendations
            
        } catch {
            lastError = error
            #if DEBUG
            print("❌ AI Recommendation generation failed: \(error.localizedDescription)")
            #endif
            
            // Fallback to rule-based recommendations
            let fallbackRecommendations = await generateFallbackRecommendations(
                uvIndex: uvIndex,
                weather: weather,
                userProfile: actualProfile,
                currentTime: currentTime
            )
            cacheRecommendations(fallbackRecommendations, for: cacheKey)
            return fallbackRecommendations
        }
    }
    
    /// Generate recommendations for specific activity
    func generateActivityRecommendations(
        activity: OutdoorActivity,
        duration: TimeInterval,
        uvIndex: Double,
        weather: WeatherData,
        userProfile: UserSunProfile? = nil
    ) async -> [AIRecommendation] {
        
        let prompt = buildActivityPrompt(
            activity: activity,
            duration: duration,
            uvIndex: uvIndex,
            weather: weather,
            userProfile: userProfile ?? getDefaultUserProfile()
        )
        
        return await generateRecommendationsFromPrompt(prompt)
    }
    
    /// Generate planning recommendations for future activities
    func generatePlanningRecommendations(
        plannedTime: Date,
        activity: OutdoorActivity?,
        forecast: [ForecastDay]
    ) async -> [AIRecommendation] {
        
        let prompt = buildPlanningPrompt(
            plannedTime: plannedTime,
            activity: activity,
            forecast: forecast
        )
        
        return await generateRecommendationsFromPrompt(prompt)
    }
    
    // MARK: - Private Methods
    
    private func checkAvailability() {
        if case .available = SystemLanguageModel.default.availability {
            isAvailable = true
            languageModelSession = LanguageModelSession()
        } else {
            isAvailable = false
        }

        #if DEBUG
        print("🤖 AI Recommendation Service - Available: \(isAvailable)")
        #endif
    }
    
    private func generateAIRecommendations(
        context: EnvironmentalContext,
        userProfile: UserSunProfile,
        location: String
    ) async throws -> [AIRecommendation] {
        let prompt = buildComprehensivePrompt(
            context: context,
            userProfile: userProfile,
            location: location
        )

        guard let session = languageModelSession else {
            return generateIntelligentFallback(context: context, userProfile: userProfile)
        }

        let response = try await session.respond(to: prompt, generating: AIRecommendationResponse.self)
        let result = response.content

        if result.recommendations.isEmpty {
            return generateIntelligentFallback(context: context, userProfile: userProfile)
        }

        return result.recommendations
    }

    private func generateRecommendationsFromPrompt(_ prompt: String) async -> [AIRecommendation] {
        guard let session = languageModelSession else {
            return []
        }

        do {
            let response = try await session.respond(to: prompt, generating: AIRecommendationResponse.self)
            return response.content.recommendations
        } catch {
            #if DEBUG
            print("❌ Failed to generate from prompt: \(error)")
            #endif
            return []
        }
    }
    
    private func buildComprehensivePrompt(
        context: EnvironmentalContext,
        userProfile: UserSunProfile,
        location: String
    ) -> String {
        return """
        Sun safety recommendations needed.

        UV: \(context.uvIndex) | Weather: \(context.weather.rawValue) | Time: \(context.timeOfDay.rawValue) | Season: \(context.season.rawValue) | Location: \(location)
        Skin: Type \(userProfile.skinType.rawValue) (\(userProfile.skinType.description)) | Age: \(userProfile.ageRange.rawValue) | Photosensitive meds: \(userProfile.photosensitiveMedications)
        Activities: \(userProfile.activities.map { $0.rawValue }.joined(separator: ", "))

        Generate 3-5 personalized recommendations prioritized by urgency. Include specific timing, protection advice, and reasoning.
        """
    }
    
    private func buildActivityPrompt(
        activity: OutdoorActivity,
        duration: TimeInterval,
        uvIndex: Double,
        weather: WeatherData,
        userProfile: UserSunProfile
    ) -> String {
        let durationMinutes = Int(duration / 60)
        return """
        User is planning \(activity.rawValue) for \(durationMinutes) minutes.
        UV Index: \(uvIndex), Weather: \(weather.condition)
        Skin Type: \(userProfile.skinType.description)
        
        Provide specific recommendations for this activity including:
        - Optimal timing
        - Protection requirements
        - Hydration needs
        - Activity-specific precautions
        """
    }
    
    private func buildPlanningPrompt(
        plannedTime: Date,
        activity: OutdoorActivity?,
        forecast: [ForecastDay]
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let activityText = activity?.rawValue ?? "outdoor activities"
        
        return """
        User is planning \(activityText) for \(formatter.string(from: plannedTime)).
        
        Forecast data: \(forecast.map { "UV: \($0.uvIndex), Condition: \($0.condition)" }.joined(separator: "; "))
        
        Provide planning recommendations including:
        - Best times for the activity
        - Weather considerations
        - Preparation advice
        - Alternative timing if conditions are poor
        """
    }
    
    private func buildEnvironmentalContext(
        uvIndex: Double,
        weather: WeatherData,
        currentTime: Date
    ) -> EnvironmentalContext {
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let month = calendar.component(.month, from: currentTime)
        
        let timeOfDay: TimeOfDay = {
            switch hour {
            case 5..<8: return .earlyMorning
            case 8..<11: return .morning
            case 11..<12: return .latemorning
            case 12..<13: return .noon
            case 13..<15: return .earlyAfternoon
            case 15..<17: return .lateAfternoon
            case 17..<19: return .evening
            case 19..<21: return .sunset
            default: return .night
            }
        }()
        
        let season: Season = {
            switch month {
            case 3...5: return .spring
            case 6...8: return .summer
            case 9...11: return .autumn
            default: return .winter
            }
        }()
        
        let weatherCondition = WeatherConditionMapper.mapCondition(weather.condition)
        
        return EnvironmentalContext(
            uvIndex: uvIndex,
            weather: weatherCondition,
            airQuality: nil, // TODO: Integrate air quality data
            pollenLevel: nil, // TODO: Integrate pollen data
            altitude: 0, // TODO: Get altitude from location
            timeOfDay: timeOfDay,
            season: season
        )
    }
    
    private func getDefaultUserProfile() -> UserSunProfile {
        // Use most conservative skin type for safety
        // This should only be used when user hasn't completed onboarding
        return UserSunProfile(
            skinType: .type1, // Most conservative - very fair skin (burns easily)
            ageRange: .adult,
            photosensitiveMedications: false, // Conservative assumption
            activities: [.walking], // Conservative activity set
            preferences: SunExposurePreferences(
                prefersShade: true,   // Conservative: prefer shade
                usesSunscreen: true,  // Conservative: always use sunscreen
                wearsProtectiveClothing: true, // Conservative: wear protection
                flexibleTiming: true, // Conservative: flexible for safety
                seeksTan: false      // Conservative: no tanning
            )
        )
    }
    
    private func generateIntelligentFallback(
        context: EnvironmentalContext,
        userProfile: UserSunProfile
    ) -> [AIRecommendation] {
        
        var recommendations: [AIRecommendation] = []
        
        // Critical recommendations for extreme UV
        let validatedUV = SafetyConstants.UVIndex.validate(context.uvIndex)
        if validatedUV >= SafetyConstants.UVIndex.extremeThreshold {
            recommendations.append(AIRecommendation(
                priority: .critical,
                message: "Extreme UV alert! Avoid outdoor activities between 10 AM - 4 PM. If you must go outside, seek immediate shade and use maximum protection.",
                timeframe: "Next 6 hours",
                reasoning: "UV index of \(validatedUV) can cause severe burns in under 5 minutes for all skin types.",
                category: .timing,
                iconName: "exclamationmark.triangle.fill",
                colorScheme: .red
            ))
        }
        
        // Skin type specific recommendations
        let protectionTime = calculateProtectionTime(
            uvIndex: context.uvIndex,
            skinType: userProfile.skinType,
            weather: context.weather
        )
        
        if protectionTime < SafetyConstants.ExposureTime.minimumSafeExposureMinutes {
            recommendations.append(AIRecommendation(
                priority: .urgent,
                message: "Your \(userProfile.skinType.description.lowercased()) skin can burn in just \(protectionTime) minutes today. Apply SPF 50+ immediately and seek shade.",
                timeframe: "Before going outside",
                reasoning: "UV index \(validatedUV) significantly reduces safe exposure time for skin type \(userProfile.skinType.rawValue).",
                category: .protection,
                iconName: "shield.fill",
                colorScheme: .orange
            ))
        }
        
        // Time-based recommendations
        if context.timeOfDay.uvRisk == .extreme {
            recommendations.append(AIRecommendation(
                priority: .important,
                message: "Peak UV hours detected. Consider rescheduling outdoor activities to early morning (before 10 AM) or evening (after 4 PM).",
                timeframe: "Next 4 hours",
                reasoning: "\(context.timeOfDay.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) is when UV radiation is strongest.",
                category: .timing,
                iconName: "clock.fill",
                colorScheme: .orange
            ))
        }
        
        // Activity-specific recommendations
        for activity in userProfile.activities {
            if activity.exposureMultiplier > 1.2 {
                recommendations.append(AIRecommendation(
                    priority: .important,
                    message: "\(activity.rawValue.capitalized) increases sun exposure by \(Int((activity.exposureMultiplier - 1) * 100))%. Use water-resistant SPF 30+ and reapply every hour.",
                    timeframe: "During activity",
                    reasoning: "\(activity.rawValue.capitalized) involves higher exposure due to sweating, water reflection, or prolonged time outdoors.",
                    category: .activity,
                    iconName: activity == .swimming ? "figure.pool.swim" : "figure.walk",
                    colorScheme: .blue
                ))
            }
        }
        
        // Hydration recommendations
        if validatedUV >= SafetyConstants.UVIndex.moderateThreshold && context.weather != .rainy {
            recommendations.append(AIRecommendation(
                priority: .routine,
                message: "High UV and clear weather increase dehydration risk. Drink water every \(SafetyConstants.Hydration.waterIntakeIntervalMinutes) minutes when outdoors.",
                timeframe: "Throughout the day",
                reasoning: "UV exposure combined with \(context.weather.rawValue) weather conditions accelerate fluid loss.",
                category: .hydration,
                iconName: "drop.fill",
                colorScheme: .blue
            ))
        }
        
        // Medication considerations
        if userProfile.photosensitiveMedications {
            recommendations.append(AIRecommendation(
                priority: .urgent,
                message: "Your medication increases sun sensitivity. Reduce outdoor time by 50% and use extra protection today.",
                timeframe: "All day",
                reasoning: "Photosensitive medications can increase burn risk by 2-10 times normal levels.",
                category: .medical,
                iconName: "pills.fill",
                colorScheme: .red
            ))
        }
        
        return recommendations.sortedByPriority
    }
    
    private func calculateProtectionTime(
        uvIndex: Double,
        skinType: SkinType,
        weather: WeatherCondition
    ) -> Int {
        let baseTime = Double(skinType.baseProtectionTime)
        let uvAdjustment = baseTime / max(uvIndex, 1.0)
        let weatherAdjustment = uvAdjustment * weather.uvModifier
        
        return max(SafetyConstants.ExposureTime.minimumSafeExposureMinutes, Int(weatherAdjustment))
    }
    
    private func generateFallbackRecommendations(
        uvIndex: Double,
        weather: WeatherData,
        userProfile: UserSunProfile,
        currentTime: Date
    ) async -> [AIRecommendation] {
        let context = buildEnvironmentalContext(
            uvIndex: uvIndex,
            weather: weather,
            currentTime: currentTime
        )

        var recommendations = generateIntelligentFallback(context: context, userProfile: userProfile)

        if !UserProfile.shared.hasCompletedSkinTypeOnboarding {
            recommendations.insert(AIRecommendation(
                priority: .urgent,
                message: "⚠️ Using conservative skin type defaults. Set your actual skin type in settings for personalized recommendations.",
                timeframe: "Update settings",
                reasoning: "Accurate skin type information is essential for safe sun exposure recommendations.",
                category: .medical,
                iconName: "person.crop.circle.badge.exclamationmark",
                colorScheme: .orange
            ), at: 0)
        }

        return recommendations
    }
}

// MARK: - Error Types

enum AIRecommendationError: Error, LocalizedError {
    case sessionNotAvailable
    case generationFailed(String)
    case invalidResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .sessionNotAvailable:
            return "Foundation Models session is not available"
        case .generationFailed(let reason):
            return "AI generation failed: \(reason)"
        case .invalidResponse:
            return "Invalid response from AI model"
        case .networkError:
            return "Network error occurred"
        }
    }
}

// MARK: - Cache Management

extension AIRecommendationService {

    // MARK: - Cache Management Methods
    
    /// Retrieves cached recommendations if valid and available
    /// - Parameter key: Cache key for the request parameters
    /// - Returns: Cached recommendations if valid, nil otherwise
    private func getCachedRecommendations(for key: CacheKey) -> [AIRecommendation]? {
        return cacheQueue.sync {
            guard let cacheEntry = recommendationCache[key],
                  cacheEntry.isValid(ttl: cacheTTL) else {
                return nil
            }
            
            return cacheEntry.recommendations
        }
    }
    
    /// Caches recommendations with the given key
    /// - Parameters:
    ///   - recommendations: Recommendations to cache
    ///   - key: Cache key for the parameters
    private func cacheRecommendations(_ recommendations: [AIRecommendation], for key: CacheKey) {
        cacheQueue.async {
            // Clean expired entries before adding new one
            self.cleanExpiredCache()
            
            // Limit cache size to prevent memory issues
            if self.recommendationCache.count >= self.maxCacheSize {
                self.evictOldestCacheEntry()
            }
            
            // Add new cache entry
            let cacheEntry = RecommendationCacheEntry(
                recommendations: recommendations,
                timestamp: Date(),
                parameters: key
            )
            
            self.recommendationCache[key] = cacheEntry
        }
    }
    
    /// Removes expired cache entries
    private func cleanExpiredCache() {
        recommendationCache = recommendationCache.filter { _, entry in
            entry.isValid(ttl: cacheTTL)
        }
    }
    
    /// Evicts the oldest cache entry when cache is full
    private func evictOldestCacheEntry() {
        guard let oldestKey = recommendationCache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key else {
            return
        }
        recommendationCache.removeValue(forKey: oldestKey)
    }
    
    /// Clears all cached recommendations (useful for testing or memory pressure)
    func clearCache() {
        cacheQueue.async {
            self.recommendationCache.removeAll()
        }
    }
    
    /// Returns current cache statistics for monitoring
    var cacheStats: (count: Int, memoryUsage: String) {
        return cacheQueue.sync {
            let count = recommendationCache.count
            let bytesPerEntry = MemoryLayout<RecommendationCacheEntry>.size
            let totalBytes = count * bytesPerEntry
            let memoryUsage = ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .memory)
            return (count: count, memoryUsage: memoryUsage)
        }
    }
}