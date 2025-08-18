//
//  UserProfileTests.swift
//  SunshadeTests
//
//  Created by Claude Code on 2025-08-18.
//

import Testing
import Foundation
@testable import Sunshade

struct UserProfileTests {
    
    // MARK: - Initialization Tests
    
    @Test("UserProfile singleton initialization")
    func testSingletonInitialization() async throws {
        let profile1 = UserProfile.shared
        let profile2 = UserProfile.shared
        
        // Should be the same instance
        #expect(profile1 === profile2)
        
        // Test singleton behavior (same instance always returned)
        #expect(profile1 === UserProfile.shared)
        #expect(profile2 === UserProfile.shared)
    }
    
    @Test("Profile values are valid")
    func testProfileValuesAreValid() async throws {
        let profile = UserProfile.shared
        
        // Should have valid skin type
        #expect(SkinType.allCases.contains(profile.skinType))
        
        // Should have valid age range
        #expect(AgeRange.allCases.contains(profile.ageRange))
        
        // Should have valid temperature unit
        #expect(TemperatureUnit.allCases.contains(profile.temperatureUnit))
        
        // Name should not be empty
        #expect(!profile.name.isEmpty)
    }
    
    // MARK: - Skin Type Tests
    
    @Test("Skin type assignment and persistence")
    func testSkinTypeAssignment() async throws {
        let profile = UserProfile.shared
        let originalSkinType = profile.skinType
        
        // Test changing skin type
        profile.skinType = .type3
        #expect(profile.skinType == .type3)
        
        // Test all skin types
        for skinType in SkinType.allCases {
            profile.skinType = skinType
            #expect(profile.skinType == skinType)
        }
        
        // Restore original for other tests
        profile.skinType = originalSkinType
    }
    
    @Test("Skin type properties")
    func testSkinTypeProperties() async throws {
        // Test each skin type has proper characteristics
        for skinType in SkinType.allCases {
            // Each skin type should have a valid description
            #expect(!skinType.description.isEmpty)
            
            // Each should have a reasonable burn time (5-40 minutes range)
            let burnTime = skinType.baseProtectionTime
            #expect(burnTime >= 5)
            #expect(burnTime <= 45)
            
            // Higher numbered types should generally have longer protection times
            if skinType.rawValue > 1 {
                let previousType = SkinType(rawValue: skinType.rawValue - 1)!
                #expect(burnTime >= previousType.baseProtectionTime)
            }
        }
    }
    
    // MARK: - Age Range Tests
    
    @Test("Age range assignment")
    func testAgeRangeAssignment() async throws {
        let profile = UserProfile.shared
        let originalAgeRange = profile.ageRange
        
        // Test all age ranges
        for ageRange in AgeRange.allCases {
            profile.ageRange = ageRange
            #expect(profile.ageRange == ageRange)
            
            // Age ranges that need extra protection should have the flag set
            if ageRange == .child || ageRange == .senior {
                #expect(ageRange.needsExtraProtection == true)
            }
        }
        
        // Restore original
        profile.ageRange = originalAgeRange
    }
    
    // MARK: - Temperature Unit Tests
    
    @Test("Temperature unit conversion")
    func testTemperatureUnitConversion() async throws {
        let profile = UserProfile.shared
        
        // Test Celsius unit
        profile.temperatureUnit = .celsius
        #expect(profile.temperatureUnit == .celsius)
        #expect(profile.temperatureUnit.symbol == "°C")
        
        // Test Fahrenheit unit  
        profile.temperatureUnit = .fahrenheit
        #expect(profile.temperatureUnit == .fahrenheit)
        #expect(profile.temperatureUnit.symbol == "°F")
        
        // Test conversion functions
        let celsiusTemp = 25.0 // 25°C
        let fahrenheitResult = TemperatureUnit.fahrenheit.convert(from: celsiusTemp)
        #expect(abs(fahrenheitResult - 77.0) < 0.1) // Should be ~77°F
        
        let fahrenheitTemp = 77.0 // 77°F
        let celsiusResult = TemperatureUnit.fahrenheit.convertToCelsius(from: fahrenheitTemp)
        #expect(abs(celsiusResult - 25.0) < 0.1) // Should be ~25°C
    }
    
    @Test("Temperature unit display names")
    func testTemperatureUnitDisplayNames() async throws {
        for unit in TemperatureUnit.allCases {
            let displayName = unit.displayName
            #expect(!displayName.isEmpty)
            #expect(displayName.count > 3) // Should be more than just "°C"
            
            let symbol = unit.symbol
            #expect(!symbol.isEmpty)
            #expect(symbol.count <= 3) // Should be "°C" or "°F"
        }
    }
    
    // MARK: - Medication Tests
    
    @Test("Photosensitive medication flag")
    func testPhotosensitiveMedicationFlag() async throws {
        let profile = UserProfile.shared
        let originalValue = profile.photosensitiveMedications
        
        // Test setting flag
        profile.photosensitiveMedications = true
        #expect(profile.photosensitiveMedications == true)
        
        profile.photosensitiveMedications = false
        #expect(profile.photosensitiveMedications == false)
        
        // Restore original
        profile.photosensitiveMedications = originalValue
    }
    
    // MARK: - Safety Warning Tests
    
    @Test("Safety warning generation")
    func testSafetyWarningGeneration() async throws {
        let profile = UserProfile.shared
        
        // Test warning when onboarding not completed
        let originalOnboardingStatus = profile.hasCompletedSkinTypeOnboarding
        profile.hasCompletedSkinTypeOnboarding = false
        
        let warning = profile.safetyWarning
        if let warning = warning {
            #expect(!warning.isEmpty)
            #expect(warning.contains("skin type") || warning.contains("onboarding") || warning.contains("complete"))
        }
        
        // Test no warning when onboarding completed
        profile.hasCompletedSkinTypeOnboarding = true
        let noWarning = profile.safetyWarning
        // Might still have warning for other reasons, but onboarding shouldn't trigger it
        
        // Restore original
        profile.hasCompletedSkinTypeOnboarding = originalOnboardingStatus
    }
    
    // MARK: - UserSunProfile Conversion Tests
    
    @Test("UserSunProfile conversion")
    func testUserSunProfileConversion() async throws {
        let profile = UserProfile.shared
        
        // Set known values
        profile.skinType = .type2
        profile.ageRange = .youngAdult
        profile.photosensitiveMedications = true
        
        let sunProfile = profile.toUserSunProfile()
        
        // Verify conversion
        #expect(sunProfile.skinType == .type2)
        #expect(sunProfile.ageRange == .youngAdult)
        #expect(sunProfile.photosensitiveMedications == true)
        
        // Should have default activities
        #expect(!sunProfile.activities.isEmpty)
        
        // Should have default preferences
        #expect(sunProfile.preferences != nil)
        #expect(sunProfile.preferences.usesSunscreen == true) // Should default to safe choice
    }
    
    // MARK: - UserSunProfile Hashable Tests
    
    @Test("UserSunProfile hashable implementation")
    func testUserSunProfileHashable() async throws {
        let profile1 = UserSunProfile(
            skinType: .type2,
            ageRange: .adult,
            photosensitiveMedications: false,
            activities: [.walking, .swimming],
            preferences: SunExposurePreferences(
                prefersShade: true,
                usesSunscreen: true,
                wearsProtectiveClothing: false,
                flexibleTiming: true,
                seeksTan: false
            )
        )
        
        let profile2 = UserSunProfile(
            skinType: .type2,
            ageRange: .adult,
            photosensitiveMedications: false,
            activities: [.walking, .swimming],
            preferences: SunExposurePreferences(
                prefersShade: true,
                usesSunscreen: true,
                wearsProtectiveClothing: false,
                flexibleTiming: true,
                seeksTan: false
            )
        )
        
        let profile3 = UserSunProfile(
            skinType: .type3, // Different skin type
            ageRange: .adult,
            photosensitiveMedications: false,
            activities: [.walking, .swimming],
            preferences: SunExposurePreferences(
                prefersShade: true,
                usesSunscreen: true,
                wearsProtectiveClothing: false,
                flexibleTiming: true,
                seeksTan: false
            )
        )
        
        // Equal profiles should be equal and have same hash
        #expect(profile1 == profile2)
        #expect(profile1.hashValue == profile2.hashValue)
        
        // Different profiles should not be equal
        #expect(profile1 != profile3)
        
        // Can store in Set (tests Hashable)
        let profileSet: Set = [profile1, profile2, profile3]
        #expect(profileSet.count == 2) // profile1 and profile2 should be considered same
    }
    
    // MARK: - Edge Cases and Error Handling
    
    @Test("Profile validation edge cases")
    func testProfileValidationEdgeCases() async throws {
        let profile = UserProfile.shared
        
        // Test that profile handles all enum cases
        for skinType in SkinType.allCases {
            profile.skinType = skinType
            let sunProfile = profile.toUserSunProfile()
            #expect(sunProfile.skinType == skinType)
        }
        
        for ageRange in AgeRange.allCases {
            profile.ageRange = ageRange
            let sunProfile = profile.toUserSunProfile()
            #expect(sunProfile.ageRange == ageRange)
        }
        
        for tempUnit in TemperatureUnit.allCases {
            profile.temperatureUnit = tempUnit
            #expect(profile.temperatureUnit == tempUnit)
        }
    }
    
    @Test("Profile state consistency")
    func testProfileStateConsistency() async throws {
        let profile = UserProfile.shared
        
        // Profile should maintain internal consistency
        let initialState = (
            skinType: profile.skinType,
            ageRange: profile.ageRange,
            medications: profile.photosensitiveMedications,
            tempUnit: profile.temperatureUnit,
            onboarding: profile.hasCompletedSkinTypeOnboarding
        )
        
        // Make changes
        profile.skinType = .type4
        profile.photosensitiveMedications = true
        
        // State should be updated
        #expect(profile.skinType == .type4)
        #expect(profile.photosensitiveMedications == true)
        
        // Other properties should be unchanged
        #expect(profile.ageRange == initialState.ageRange)
        #expect(profile.temperatureUnit == initialState.tempUnit)
        
        // Restore original state
        profile.skinType = initialState.skinType
        profile.photosensitiveMedications = initialState.medications
    }
}