import Foundation
import SwiftUI
import Combine

/// Thread-safe recommendation manager with proper lifecycle management
@MainActor
class RecommendationManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recommendations: [SafetyRecommendation] = []
    @Published var isGenerating = false
    @Published var isIntelligentMode = false
    @Published var lastError: Error?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let generator: RecommendationGenerator
    
    // MARK: - Initialization
    
    init(generator: RecommendationGenerator = DefaultRecommendationGenerator()) {
        self.generator = generator
        setupInitialRecommendations()
    }
    
    // MARK: - Public Methods
    
    func toggleIntelligentMode() {
        isIntelligentMode.toggle()
        generateRecommendations()
    }
    
    func updateConditions(uvIndex: Double, temperature: Int, cloudCover: Int, condition: String) {
        if isIntelligentMode {
            generateRecommendations(uvIndex: uvIndex, temperature: temperature, cloudCover: cloudCover, condition: condition)
        }
    }
    
    func generateRecommendations(uvIndex: Double? = nil, temperature: Int? = nil, cloudCover: Int? = nil, condition: String? = nil) {
        guard !isGenerating else { return }
        
        isGenerating = true
        lastError = nil
        
        Task {
            do {
                let newRecommendations: [SafetyRecommendation]
                
                if isIntelligentMode {
                    newRecommendations = try await generator.generateIntelligentRecommendations(
                        uvIndex: uvIndex ?? 5.0,
                        temperature: temperature ?? 20,
                        cloudCover: cloudCover ?? 50,
                        condition: condition ?? "Clear"
                    )
                } else {
                    newRecommendations = generator.generateBasicRecommendations()
                }
                
                await MainActor.run {
                    self.recommendations = newRecommendations
                    self.isGenerating = false
                }
                
            } catch {
                await MainActor.run {
                    self.lastError = error
                    self.isGenerating = false
                    // Fallback to basic recommendations on error
                    self.recommendations = self.generator.generateBasicRecommendations()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialRecommendations() {
        recommendations = generator.generateBasicRecommendations()
    }
}

// MARK: - Recommendation Models

struct SafetyRecommendation: Identifiable, Equatable {
    let id = UUID()
    let priority: SafetyPriority
    let message: String
    let timeframe: String
    let category: String
    let iconName: String
    let color: Color
    
    static func == (lhs: SafetyRecommendation, rhs: SafetyRecommendation) -> Bool {
        lhs.id == rhs.id
    }
}

enum SafetyPriority: Int, CaseIterable {
    case critical = 0
    case urgent = 1
    case important = 2
    case routine = 3
    
    var displayName: String {
        switch self {
        case .critical: return "CRITICAL"
        case .urgent: return "URGENT"
        case .important: return "IMPORTANT"
        case .routine: return ""
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .critical: return .red
        case .urgent: return .orange
        case .important: return .blue
        case .routine: return .clear
        }
    }
}

// MARK: - Recommendation Generator Protocol

protocol RecommendationGenerator {
    func generateBasicRecommendations() -> [SafetyRecommendation]
    func generateIntelligentRecommendations(uvIndex: Double, temperature: Int, cloudCover: Int, condition: String) async throws -> [SafetyRecommendation]
}

// MARK: - Default Implementation

struct DefaultRecommendationGenerator: RecommendationGenerator {
    
    func generateBasicRecommendations() -> [SafetyRecommendation] {
        return [
            SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "Apply SPF 30+ sunscreen 15 minutes before exposure",
                timeframe: "Before going outside",
                category: "protection",
                iconName: "shield.fill",
                color: Color.blue
            ),
            SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "Reapply sunscreen every 2 hours",
                timeframe: "Throughout the day",
                category: "protection",
                iconName: "arrow.clockwise",
                color: Color.blue
            ),
            SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "Seek shade during peak hours (10 AM - 4 PM)",
                timeframe: "Peak hours",
                category: "timing",
                iconName: "sun.max.fill",
                color: Color.orange
            )
        ]
    }
    
    func generateIntelligentRecommendations(uvIndex: Double, temperature: Int, cloudCover: Int, condition: String) async throws -> [SafetyRecommendation] {
        
        // Simulate intelligent processing without artificial delays
        var recommendations: [SafetyRecommendation] = []
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Critical UV warning
        let validatedUV = SafetyConstants.UVIndex.validate(uvIndex)
        if validatedUV >= SafetyConstants.UVIndex.extremeThreshold {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.critical,
                message: "⚠️ EXTREME UV Alert! UV index of \(Int(validatedUV)) can cause severe burns in under 5 minutes.",
                timeframe: "Next 6 hours",
                category: "timing",
                iconName: "exclamationmark.triangle.fill",
                color: Color.red
            ))
        }
        
        // Peak hours warning
        if SafetyConstants.PeakHours.isDuringPeakHours(currentHour) && validatedUV >= SafetyConstants.UVIndex.moderateThreshold {
            let safeTime = SafetyConstants.ExposureTime.calculateSafeMinutes(uvIndex: validatedUV)
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.urgent,
                message: "☀️ Peak UV hours. Limit exposure to \(safeTime) minutes or seek shade.",
                timeframe: "Peak hours",
                category: "timing",
                iconName: "sun.max.fill",
                color: Color.orange
            ))
        }
        
        // Weather-specific advice
        let validatedCondition = SafetyConstants.Validation.validateWeatherCondition(condition)
        if validatedCondition == "clear" && validatedUV >= SafetyConstants.UVIndex.highThreshold {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.important,
                message: "🌞 Clear skies amplify UV. Use SPF 50+ and UV-blocking sunglasses.",
                timeframe: "All day",
                category: "protection",
                iconName: "eye.fill",
                color: Color.orange
            ))
        } else if validatedCondition.contains("cloud") {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "☁️ Clouds provide partial protection. UV still penetrates - use SPF 30+.",
                timeframe: "Throughout day",
                category: "protection",
                iconName: "cloud.sun.fill",
                color: Color.blue
            ))
        }
        
        // Temperature-based hydration
        let validatedTemp = SafetyConstants.Temperature.validateCelsius(Double(temperature))
        if validatedTemp >= SafetyConstants.Temperature.warmThresholdCelsius && validatedUV >= SafetyConstants.UVIndex.moderateThreshold {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.important,
                message: "🌡️ High temp (\(Int(validatedTemp))°C) + UV \(Int(validatedUV)) increases dehydration risk.",
                timeframe: "When active outdoors",
                category: "hydration",
                iconName: "drop.fill",
                color: Color.blue
            ))
        }
        
        // Activity timing
        if currentHour >= 6 && currentHour <= 9 && validatedUV <= SafetyConstants.UVIndex.lowThreshold + 2 {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "🏃 Great time for outdoor exercise! UV is moderate (\(Int(validatedUV))).",
                timeframe: "Morning hours",
                category: "activity",
                iconName: "figure.run",
                color: Color.green
            ))
        }
        
        // Evening recommendation
        if currentHour >= 17 && currentHour <= 19 && validatedUV <= SafetyConstants.UVIndex.lowThreshold {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "🌅 Golden hour! Low UV (\(Int(validatedUV))) - ideal for outdoor activities.",
                timeframe: "Evening",
                category: "activity",
                iconName: "camera.fill",
                color: Color.green
            ))
        }
        
        // Basic protection
        if validatedUV >= SafetyConstants.UVIndex.lowThreshold {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "🧴 Apply broad-spectrum SPF 30+ sunscreen 15 minutes before exposure.",
                timeframe: "Before going outside",
                category: "protection",
                iconName: "shield.fill",
                color: Color.blue
            ))
        }
        
        // Reapplication reminder
        if validatedUV >= SafetyConstants.UVIndex.moderateThreshold {
            recommendations.append(SafetyRecommendation(
                priority: SafetyPriority.routine,
                message: "🔄 High UV requires reapplication every \(SafetyConstants.ExposureTime.sunscreenReapplicationIntervalMinutes) minutes when outdoors.",
                timeframe: "Throughout exposure",
                category: "protection",
                iconName: "arrow.clockwise",
                color: Color.blue
            ))
        }
        
        // Sort by priority
        return recommendations.sorted(by: { $0.priority.rawValue < $1.priority.rawValue })
    }
}