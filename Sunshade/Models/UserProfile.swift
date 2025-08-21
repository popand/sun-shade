import Foundation
import SwiftUI

enum TemperatureUnit: String, CaseIterable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    
    var displayName: String {
        switch self {
        case .celsius:
            return "Celsius (°C)"
        case .fahrenheit:
            return "Fahrenheit (°F)"
        }
    }
    
    var symbol: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
    
    func convert(from celsius: Double) -> Double {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            return (celsius * 9/5) + 32
        }
    }
    
    func convertToCelsius(from value: Double) -> Double {
        switch self {
        case .celsius:
            return value
        case .fahrenheit:
            return (value - 32) * 5/9
        }
    }
}

class UserProfile: ObservableObject {
    @Published var name: String {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.name, forKey: "userName")
            }
        }
    }
    
    @Published var skinType: SkinType {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.skinType.rawValue, forKey: "userSkinType")
                // Update onboarding flag directly without triggering didSet
                if !self.hasCompletedSkinTypeOnboarding {
                    self.hasCompletedSkinTypeOnboarding = true
                }
            }
        }
    }
    
    @Published var ageRange: AgeRange {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.ageRange.rawValue, forKey: "userAgeRange")
            }
        }
    }
    
    @Published var photosensitiveMedications: Bool {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.photosensitiveMedications, forKey: "userPhotosensitiveMedications")
            }
        }
    }
    
    @Published var preferredActivities: [OutdoorActivity] {
        didSet {
            DispatchQueue.main.async {
                let activityStrings = self.preferredActivities.map { $0.rawValue }
                UserDefaults.standard.set(activityStrings, forKey: "userPreferredActivities")
            }
        }
    }
    
    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.temperatureUnit.rawValue, forKey: "temperatureUnit")
            }
        }
    }
    
    @Published var hasCompletedSkinTypeOnboarding: Bool {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.hasCompletedSkinTypeOnboarding, forKey: "hasCompletedSkinTypeOnboarding")
            }
        }
    }
    
    init() {
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        
        // Load skin type with safe default
        let savedSkinType = UserDefaults.standard.integer(forKey: "userSkinType")
        self.skinType = SkinType(rawValue: savedSkinType) ?? .type1 // Most conservative default
        
        // Load age range
        let savedAgeRange = UserDefaults.standard.string(forKey: "userAgeRange") ?? AgeRange.adult.rawValue
        self.ageRange = AgeRange(rawValue: savedAgeRange) ?? .adult
        
        // Load medication status (default to false for safety)
        self.photosensitiveMedications = UserDefaults.standard.bool(forKey: "userPhotosensitiveMedications")
        
        // Load preferred activities
        let savedActivityStrings = UserDefaults.standard.stringArray(forKey: "userPreferredActivities") ?? []
        let loadedActivities = savedActivityStrings.compactMap { OutdoorActivity(rawValue: $0) }
        self.preferredActivities = loadedActivities.isEmpty ? [.walking] : loadedActivities
        
        // Load temperature unit
        let savedUnit = UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: savedUnit) ?? .celsius
        
        // Check if user has completed onboarding
        self.hasCompletedSkinTypeOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedSkinTypeOnboarding")
    }
    
    /// Create a UserSunProfile from the current user profile
    func toUserSunProfile() -> UserSunProfile {
        return UserSunProfile(
            skinType: skinType,
            ageRange: ageRange,
            photosensitiveMedications: photosensitiveMedications,
            activities: preferredActivities,
            preferences: SunExposurePreferences(
                prefersShade: true,
                usesSunscreen: true,
                wearsProtectiveClothing: false,
                flexibleTiming: true,
                seeksTan: false
            )
        )
    }
    
    /// Check if profile is using potentially unsafe default values
    var isUsingDefaults: Bool {
        return !hasCompletedSkinTypeOnboarding
    }
    
    /// Get a safety warning if using default profile
    var safetyWarning: String? {
        guard isUsingDefaults else { return nil }
        return "⚠️ Using conservative defaults. Please set your actual skin type in settings for personalized recommendations."
    }
    
    static let shared = UserProfile()
} 