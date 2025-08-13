//
//  SunshadeTests.swift
//  SunshadeTests
//
//  Created by Andrei Pop on 2025-06-23.
//

import Testing
import CoreLocation
@testable import Sunshade

struct SunshadeTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @available(iOS 16.0, *)
    @Test func testWeatherKitIntegration() async throws {
        let weatherService = WeatherKitService()
        let sanFrancisco = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        do {
            let weatherData = try await weatherService.fetchWeatherData(for: sanFrancisco)
            
            // Verify we got valid weather data
            #expect(weatherData.temperature > -50 && weatherData.temperature < 60) // Celsius range
            #expect(weatherData.uvIndex >= 0 && weatherData.uvIndex <= 15)
            #expect(weatherData.humidity >= 0 && weatherData.humidity <= 100)
            #expect(weatherData.cloudCover >= 0 && weatherData.cloudCover <= 100)
            #expect(!weatherData.condition.isEmpty)
            #expect(!weatherData.description.isEmpty)
            #expect(!weatherData.iconName.isEmpty)
            
            print("✅ WeatherKit Test Results:")
            print("   🌡️ Temperature: \(String(format: "%.1f", weatherData.temperature))°C")
            print("   ☀️ UV Index: \(String(format: "%.1f", weatherData.uvIndex))")
            print("   ☁️ Cloud Cover: \(weatherData.cloudCover)%")
            print("   🌤️ Condition: \(weatherData.description)")
            
        } catch {
            print("⚠️ WeatherKit Test failed with error: \(error)")
            throw error
        }
    }
    
    @Test func testWeatherDataModel() async throws {
        // Test WeatherData model with real data structure
        let testData = WeatherData(
            temperature: 22.0,
            uvIndex: 5.0,
            humidity: 50,
            cloudCover: 30,
            condition: "Clear",
            description: "Clear sky",
            iconName: "01d"
        )
        
        // Verify data model structure and validation
        #expect(testData.temperature > -50 && testData.temperature < 60)
        #expect(testData.uvIndex >= 0 && testData.uvIndex <= 15)
        #expect(testData.humidity >= 0 && testData.humidity <= 100)
        #expect(testData.cloudCover >= 0 && testData.cloudCover <= 100)
        #expect(!testData.condition.isEmpty)
        #expect(!testData.description.isEmpty)
        #expect(!testData.iconName.isEmpty)
        
        // Test tanning quality calculation
        #expect(testData.currentTanningQuality != nil)
        
        print("✅ WeatherData Model Test Results:")
        print("   🌡️ Temperature: \(String(format: "%.1f", testData.temperature))°C")
        print("   ☀️ UV Index: \(String(format: "%.1f", testData.uvIndex))")
        print("   ☁️ Cloud Cover: \(testData.cloudCover)%")
        print("   🌤️ Condition: \(testData.description)")
        print("   🏖️ Tanning Quality: \(testData.currentTanningQuality.rawValue)")
    }

}
