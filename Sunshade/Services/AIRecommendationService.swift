import Foundation
import SwiftUI
// Note: FoundationModels import will be available in iOS 26
// import FoundationModels

/// AI-powered sun safety recommendation service using Apple's Foundation Models
@available(iOS 26.0, *)
class AIRecommendationService: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isGenerating = false
    @Published var lastError: Error?
    @Published var isAvailable = false
    
    private var foundationModelSession: Any? // FoundationModelSession when available
    private let fallbackService = FallbackRecommendationService()
    
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
        
        // Check if Foundation Models is available
        guard isAvailable else {
            return await generateFallbackRecommendations(
                uvIndex: uvIndex,
                weather: weather,
                userProfile: userProfile,
                currentTime: currentTime
            )
        }
        
        do {
            let context = buildEnvironmentalContext(
                uvIndex: uvIndex,
                weather: weather,
                currentTime: currentTime
            )
            
            let recommendations = try await generateAIRecommendations(
                context: context,
                userProfile: userProfile ?? getDefaultUserProfile(),
                location: location
            )
            
            return recommendations.sortedByPriority
            
        } catch {
            lastError = error
            print("❌ AI Recommendation generation failed: \(error.localizedDescription)")
            
            // Fallback to rule-based recommendations
            return await generateFallbackRecommendations(
                uvIndex: uvIndex,
                weather: weather,
                userProfile: userProfile,
                currentTime: currentTime
            )
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
        // In iOS 26, this will check FoundationModel.isAvailable
        // For now, we'll simulate the check
        #if targetEnvironment(simulator)
        isAvailable = false // Simulators may not support Foundation Models
        #else
        // Check device capabilities and iOS version
        if #available(iOS 26.0, *) {
            // isAvailable = FoundationModel.isAvailable
            isAvailable = true // Will be actual check when iOS 26 is available
        } else {
            isAvailable = false
        }
        #endif
        
        print("🤖 AI Recommendation Service - Available: \(isAvailable)")
    }
    
    private func generateAIRecommendations(
        context: EnvironmentalContext,
        userProfile: UserSunProfile,
        location: String
    ) async throws -> [AIRecommendation] {
        
        // Build the AI prompt
        let prompt = buildComprehensivePrompt(
            context: context,
            userProfile: userProfile,
            location: location
        )
        
        // TODO: Replace with actual Foundation Models call when iOS 26 is available
        /*
        guard let session = foundationModelSession as? FoundationModelSession else {
            throw AIRecommendationError.sessionNotAvailable
        }
        
        let response = try await session.generate(
            prompt: prompt,
            outputType: [AIRecommendation].self
        )
        
        return response
        */
        
        // For now, return intelligent rule-based recommendations
        // This will be replaced with actual AI generation
        return generateIntelligentFallback(context: context, userProfile: userProfile)
    }
    
    private func generateRecommendationsFromPrompt(_ prompt: String) async -> [AIRecommendation] {
        // TODO: Implement Foundation Models generation
        // For now, return fallback recommendations
        return []
    }
    
    private func buildComprehensivePrompt(
        context: EnvironmentalContext,
        userProfile: UserSunProfile,
        location: String
    ) -> String {
        return """
        Generate personalized sun safety recommendations based on the following context:
        
        ENVIRONMENTAL CONDITIONS:
        - UV Index: \(context.uvIndex)
        - Weather: \(context.weather.rawValue)
        - Time: \(context.timeOfDay.rawValue)
        - Season: \(context.season.rawValue)
        - Location: \(location)
        
        USER PROFILE:
        - Skin Type: \(userProfile.skinType.description) (Type \(userProfile.skinType.rawValue))
        - Age Range: \(userProfile.ageRange.rawValue)
        - Photosensitive Medications: \(userProfile.photosentitivemedications)
        - Activities: \(userProfile.activities.map { $0.rawValue }.joined(separator: ", "))
        - Preferences: Shade(\(userProfile.preferences.prefersShade)), Sunscreen(\(userProfile.preferences.usesSunscreen))
        
        REQUIREMENTS:
        - Generate 3-5 personalized recommendations
        - Prioritize by urgency and relevance
        - Include specific timing and protection advice
        - Use natural, conversational language
        - Provide reasoning for each recommendation
        - Consider user's skin type and activity patterns
        
        Return recommendations as structured AIRecommendation objects with appropriate priority, category, and color coding.
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
        
        let weatherCondition: WeatherCondition = {
            let condition = weather.condition.lowercased()
            if condition.contains("clear") { return .clear }
            if condition.contains("partly") { return .partlyCloudy }
            if condition.contains("cloudy") { return .cloudy }
            if condition.contains("overcast") { return .overcast }
            if condition.contains("rain") { return .rainy }
            if condition.contains("storm") { return .stormy }
            if condition.contains("snow") { return .snowy }
            if condition.contains("fog") { return .foggy }
            if condition.contains("wind") { return .windy }
            return .clear
        }()
        
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
        // TODO: Load from user preferences or onboarding
        return UserSunProfile(
            skinType: .type3, // Medium skin as default
            ageRange: .adult,
            photosentitivemedications: false,
            activities: [.walking, .running],
            preferences: SunExposurePreferences(
                prefersShade: true,
                usesSunscreen: true,
                wearsProtectiveClothing: false,
                flexibleTiming: true,
                seeksTan: false
            )
        )
    }
    
    private func generateIntelligentFallback(
        context: EnvironmentalContext,
        userProfile: UserSunProfile
    ) -> [AIRecommendation] {
        
        var recommendations: [AIRecommendation] = []
        
        // Critical recommendations for extreme UV
        if context.uvIndex >= 10 {
            recommendations.append(AIRecommendation(
                priority: .critical,
                message: "Extreme UV alert! Avoid outdoor activities between 10 AM - 4 PM. If you must go outside, seek immediate shade and use maximum protection.",
                timeframe: "Next 6 hours",
                reasoning: "UV index of \(context.uvIndex) can cause severe burns in under 5 minutes for all skin types.",
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
        
        if protectionTime < 15 {
            recommendations.append(AIRecommendation(
                priority: .urgent,
                message: "Your \(userProfile.skinType.description.lowercased()) skin can burn in just \(protectionTime) minutes today. Apply SPF 50+ immediately and seek shade.",
                timeframe: "Before going outside",
                reasoning: "UV index \(context.uvIndex) significantly reduces safe exposure time for skin type \(userProfile.skinType.rawValue).",
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
        if context.uvIndex >= 6 && context.weather != .rainy {
            recommendations.append(AIRecommendation(
                priority: .routine,
                message: "High UV and clear weather increase dehydration risk. Drink water every 15-20 minutes when outdoors.",
                timeframe: "Throughout the day",
                reasoning: "UV exposure combined with \(context.weather.rawValue) weather conditions accelerate fluid loss.",
                category: .hydration,
                iconName: "drop.fill",
                colorScheme: .blue
            ))
        }
        
        // Medication considerations
        if userProfile.photosentitivemedications {
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
        
        return max(5, Int(weatherAdjustment))
    }
    
    private func generateFallbackRecommendations(
        uvIndex: Double,
        weather: WeatherData,
        userProfile: UserSunProfile?,
        currentTime: Date
    ) async -> [AIRecommendation] {
        
        // Use fallback service for older iOS versions
        let legacyRecommendations = fallbackService.generateRecommendations(
            uvIndex: uvIndex,
            weather: weather,
            currentTime: currentTime
        )
        
        // Convert to AI recommendation format
        return legacyRecommendations.map { legacy in
            AIRecommendation(
                priority: RecommendationPriority(rawValue: legacy.priority) ?? .routine,
                message: legacy.message,
                timeframe: legacy.timeframe,
                reasoning: legacy.reasoning,
                category: RecommendationCategory(rawValue: legacy.category) ?? .protection,
                iconName: legacy.iconName,
                colorScheme: RecommendationColor(rawValue: legacy.colorName) ?? .blue
            )
        }
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

// MARK: - Fallback Service for older iOS versions

class FallbackRecommendationService {
    
    func generateRecommendations(
        uvIndex: Double,
        weather: WeatherData,
        currentTime: Date
    ) -> [LegacyRecommendation] {
        
        var recommendations: [LegacyRecommendation] = []
        
        // Basic UV-based recommendations (existing logic)
        if uvIndex >= 6 {
            recommendations.append(LegacyRecommendation(
                priority: "important",
                message: "Seek shade between 10 AM - 4 PM",
                timeframe: "Peak hours",
                reasoning: "High UV index requires shade protection",
                category: "timing",
                iconName: "sun.max.fill",
                colorName: "orange"
            ))
        }
        
        recommendations.append(LegacyRecommendation(
            priority: "routine",
            message: "Apply SPF 30+ sunscreen 15 minutes before exposure",
            timeframe: "Before going outside",
            reasoning: "Standard sun protection practice",
            category: "protection",
            iconName: "shield.fill",
            colorName: "blue"
        ))
        
        recommendations.append(LegacyRecommendation(
            priority: "routine",
            message: "Reapply sunscreen every 2 hours",
            timeframe: "Throughout the day",
            reasoning: "Sunscreen effectiveness decreases over time",
            category: "protection",
            iconName: "arrow.clockwise",
            colorName: "blue"
        ))
        
        return recommendations
    }
}

// MARK: - Backwards Compatibility

@available(iOS 26.0, *)
extension AIRecommendationService {
    
    /// Legacy method for iOS < 26 compatibility
    func getLegacyRecommendations(
        uvIndex: Double,
        weather: WeatherData
    ) -> [String] {
        
        let legacyRecommendations = fallbackService.generateRecommendations(
            uvIndex: uvIndex,
            weather: weather,
            currentTime: Date()
        )
        
        return legacyRecommendations.map { $0.message }
    }
}