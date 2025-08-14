import Foundation

/// Feature flags for managing experimental and future features
struct FeatureFlags {
    
    // MARK: - Current Feature Flags
    
    /// Enable intelligent recommendations using rule-based system
    static let intelligentRecommendations = true
    
    /// Enable advanced UI animations
    static let advancedAnimations = true
    
    // MARK: - Future Feature Flags (will be enabled when available)
    
    /// Enable Apple Intelligence integration when Foundation Models becomes available
    /// This will be set to true when iOS supports Foundation Models framework
    static var appleIntelligenceEnabled: Bool {
        #if canImport(FoundationModels)
        return true
        #else
        return false
        #endif
    }
    
    /// Check if the device supports on-device AI processing
    static var supportsOnDeviceAI: Bool {
        // This will check for specific hardware capabilities in the future
        // For now, return false as the framework isn't available
        return false
    }
    
    // MARK: - Development Flags
    
    #if DEBUG
    /// Enable debug logging for recommendations
    static let debugRecommendations = true
    #else
    static let debugRecommendations = false
    #endif
    
    // MARK: - Methods
    
    /// Check if AI features should be available
    static func shouldShowAIFeatures() -> Bool {
        return intelligentRecommendations || appleIntelligenceEnabled
    }
    
    /// Get the appropriate recommendation service based on availability
    static func recommendationServiceType() -> RecommendationServiceType {
        if appleIntelligenceEnabled {
            return .appleIntelligence
        } else if intelligentRecommendations {
            return .intelligent
        } else {
            return .basic
        }
    }
}

/// Types of recommendation services available
enum RecommendationServiceType {
    case basic              // Static recommendations
    case intelligent        // Rule-based intelligent recommendations
    case appleIntelligence  // Future: Foundation Models powered
}