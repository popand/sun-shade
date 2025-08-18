//
//  UVLevelTests.swift
//  SunshadeTests
//
//  Created by Claude Code on 2025-08-18.
//

import Testing
import SwiftUI
@testable import Sunshade

struct UVLevelTests {
    
    // MARK: - UV Level Classification Tests
    
    @Test("Low UV level classification (0-2)")
    func testLowUVLevel() async throws {
        let lowUVValues = [0.0, 0.5, 1.0, 1.5, 2.0, 2.9]
        
        for uvIndex in lowUVValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .low)
            #expect(uvLevel.description == "Low")
            
            // Low UV should be green (success color)
            let color = uvLevel.color
            #expect(color == AppColors.success)
        }
    }
    
    @Test("Moderate UV level classification (3-5)")
    func testModerateUVLevel() async throws {
        let moderateUVValues = [3.0, 3.5, 4.0, 4.5, 5.0, 5.9]
        
        for uvIndex in moderateUVValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .moderate)
            #expect(uvLevel.description == "Moderate")
            
            // Moderate UV should be warning color
            let color = uvLevel.color
            #expect(color == AppColors.warning)
        }
    }
    
    @Test("High UV level classification (6-7)")
    func testHighUVLevel() async throws {
        let highUVValues = [6.0, 6.5, 7.0, 7.9]
        
        for uvIndex in highUVValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .high)
            #expect(uvLevel.description == "High")
            
            // High UV should be primary color
            let color = uvLevel.color
            #expect(color == AppColors.primary)
        }
    }
    
    @Test("Very High UV level classification (8-10)")
    func testVeryHighUVLevel() async throws {
        let veryHighUVValues = [8.0, 8.5, 9.0, 9.5, 10.0, 10.9]
        
        for uvIndex in veryHighUVValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .veryHigh)
            #expect(uvLevel.description == "Very High")
            
            // Very High UV should be danger color
            let color = uvLevel.color
            #expect(color == AppColors.danger)
        }
    }
    
    @Test("Extreme UV level classification (11+)")
    func testExtremeUVLevel() async throws {
        let extremeUVValues = [11.0, 11.5, 12.0, 13.0, 15.0, 20.0]
        
        for uvIndex in extremeUVValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .extreme)
            #expect(uvLevel.description == "Extreme")
            
            // Extreme UV should be purple
            let color = uvLevel.color
            #expect(color == Color.purple)
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Negative UV index handling")
    func testNegativeUVIndex() async throws {
        let negativeValues = [-1.0, -0.5, -10.0]
        
        for uvIndex in negativeValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .low) // Should default to low for negative values (0..<3 range)
        }
    }
    
    @Test("Boundary value testing")
    func testBoundaryValues() async throws {
        // Test exact boundary values (0..<3 = low, 3..<6 = moderate, etc.)
        #expect(UVLevel.level(for: 2.9) == .low)
        #expect(UVLevel.level(for: 3.0) == .moderate)
        
        #expect(UVLevel.level(for: 5.9) == .moderate)
        #expect(UVLevel.level(for: 6.0) == .high)
        
        #expect(UVLevel.level(for: 7.9) == .high)
        #expect(UVLevel.level(for: 8.0) == .veryHigh)
        
        #expect(UVLevel.level(for: 10.9) == .veryHigh)
        #expect(UVLevel.level(for: 11.0) == .extreme)
    }
    
    @Test("Very high UV index values")
    func testVeryHighUVValues() async throws {
        let extremeValues = [50.0, 100.0, 999.0]
        
        for uvIndex in extremeValues {
            let uvLevel = UVLevel.level(for: uvIndex)
            #expect(uvLevel == .extreme) // Should handle very high values gracefully
        }
    }
    
    // MARK: - Color Consistency Tests
    
    @Test("UV level colors are consistent")
    func testUVLevelColorConsistency() async throws {
        // Colors should be consistent across calls
        let lowColor1 = UVLevel.low.color
        let lowColor2 = UVLevel.low.color
        #expect(lowColor1 == lowColor2)
        
        let extremeColor1 = UVLevel.extreme.color
        let extremeColor2 = UVLevel.extreme.color
        #expect(extremeColor1 == extremeColor2)
    }
    
    @Test("UV level colors are distinct")
    func testUVLevelColorsAreDistinct() async throws {
        let allLevels: [UVLevel] = [.low, .moderate, .high, .veryHigh, .extreme]
        let colors = allLevels.map { $0.color }
        
        // All colors should be different from each other
        for i in 0..<colors.count {
            for j in (i+1)..<colors.count {
                #expect(colors[i] != colors[j], "UV level colors should be distinct: \(allLevels[i]) vs \(allLevels[j])")
            }
        }
    }
    
    // MARK: - Description Tests
    
    @Test("UV level descriptions are appropriate")
    func testUVLevelDescriptions() async throws {
        let descriptions = [
            UVLevel.low.description,
            UVLevel.moderate.description,
            UVLevel.high.description,
            UVLevel.veryHigh.description,
            UVLevel.extreme.description
        ]
        
        // All descriptions should be non-empty and reasonable length
        for description in descriptions {
            #expect(!description.isEmpty)
            #expect(description.count >= 3)
            #expect(description.count <= 20)
            
            // Should be properly capitalized
            #expect(description.first?.isUppercase == true)
        }
        
        // Descriptions should be distinct
        let uniqueDescriptions = Set(descriptions)
        #expect(uniqueDescriptions.count == descriptions.count)
    }
    
    @Test("UV level progression makes sense")
    func testUVLevelProgression() async throws {
        // Test that the progression low -> moderate -> high -> very high -> extreme makes sense
        let levels: [UVLevel] = [.low, .moderate, .high, .veryHigh, .extreme]
        let descriptions = levels.map { $0.description }
        
        // Should progress from less concerning to more concerning language
        #expect(descriptions[0] == "Low")
        #expect(descriptions[1] == "Moderate")
        #expect(descriptions[2] == "High")
        #expect(descriptions[3] == "Very High")
        #expect(descriptions[4] == "Extreme")
    }
    
    // MARK: - Integration with WeatherData
    
    @Test("UV level integration with WeatherData")
    func testUVLevelWeatherDataIntegration() async throws {
        let testCases: [(uvIndex: Double, expectedLevel: UVLevel)] = [
            (1.0, .low),
            (4.0, .moderate),
            (6.5, .high),
            (9.0, .veryHigh),
            (12.0, .extreme)
        ]
        
        for (uvIndex, expectedLevel) in testCases {
            let weatherData = WeatherData(
                temperature: 25.0,
                uvIndex: uvIndex,
                humidity: 50,
                cloudCover: 20,
                condition: "Clear",
                description: "Clear sky",
                iconName: "01d"
            )
            
            // Test that UV level calculation works for the UV index
            let calculatedLevel = UVLevel.level(for: weatherData.uvIndex)
            #expect(calculatedLevel == expectedLevel)
            
            // WeatherData should have tanning quality
            #expect(weatherData.currentTanningQuality != nil)
        }
    }
    
    // MARK: - Safety Implications
    
    @Test("UV levels correlate with safety concerns")
    func testUVLevelSafetyConcerns() async throws {
        // Low UV should be safest
        let lowUV = UVLevel.level(for: 1.0)
        #expect(lowUV == .low)
        
        // Extreme UV should be most dangerous
        let extremeUV = UVLevel.level(for: 12.0)
        #expect(extremeUV == .extreme)
        
        // Progression should make sense for safety recommendations
        let uvValues = [1.0, 4.0, 6.5, 9.0, 12.0]
        let levels = uvValues.map { UVLevel.level(for: $0) }
        
        // Should progress from least to most dangerous
        #expect(levels == [.low, .moderate, .high, .veryHigh, .extreme])
    }
    
    @Test("UV level performance")
    func testUVLevelPerformance() async throws {
        // Test that UV level calculation is fast (should be O(1))
        let startTime = Date()
        
        for i in 0..<1000 {
            let uvIndex = Double(i) / 100.0 // 0.0 to 10.0
            let _ = UVLevel.level(for: uvIndex)
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Should complete 1000 calculations in well under a second
        #expect(duration < 0.1)
    }
}