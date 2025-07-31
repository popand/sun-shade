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
    
    @Test func testOpenWeatherMapAPIIntegration() async throws {
        let weatherService = WeatherService()
        let sanFrancisco = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        do {
            let weatherData = try await weatherService.fetchWeatherData(for: sanFrancisco)
            
            // Verify we got valid weather data
            #expect(weatherData.temperature > 0)
            #expect(weatherData.uvIndex >= 0 && weatherData.uvIndex <= 15)
            #expect(weatherData.humidity >= 0 && weatherData.humidity <= 100)
            #expect(weatherData.cloudCover >= 0 && weatherData.cloudCover <= 100)
            #expect(!weatherData.condition.isEmpty)
            #expect(!weatherData.description.isEmpty)
            #expect(!weatherData.iconName.isEmpty)
            
            print("✅ Weather API Test Results:")
            print("   🌡️ Temperature: \(Int(weatherData.temperature))°F")
            print("   ☀️ UV Index: \(String(format: "%.1f", weatherData.uvIndex))")
            print("   ☁️ Cloud Cover: \(weatherData.cloudCover)%")
            print("   🌤️ Condition: \(weatherData.description)")
            
        } catch WeatherService.WeatherError.missingAPIKey {
            throw WeatherService.WeatherError.missingAPIKey
        } catch {
            print("⚠️ API Test failed with error: \(error)")
            throw error
        }
    }

}
