import Foundation

/// Centralized constants for safety calculations and validation
enum SafetyConstants {
    
    // MARK: - UV Index Constants
    
    enum UVIndex {
        static let minimum: Double = 0.0
        static let maximum: Double = 20.0  // Extreme cases can exceed 11
        static let lowThreshold: Double = 3.0
        static let moderateThreshold: Double = 6.0
        static let highThreshold: Double = 8.0
        static let veryHighThreshold: Double = 10.0
        static let extremeThreshold: Double = 11.0
        
        /// Validate UV index is within acceptable range
        static func validate(_ value: Double) -> Double {
            return min(max(value, minimum), maximum)
        }
        
        /// Get risk level for UV index
        static func riskLevel(for uvIndex: Double) -> String {
            switch uvIndex {
            case ..<lowThreshold: return "Low"
            case ..<moderateThreshold: return "Moderate"
            case ..<highThreshold: return "High"
            case ..<veryHighThreshold: return "Very High"
            case ..<extremeThreshold: return "Extreme"
            default: return "Extreme+"
            }
        }
    }
    
    // MARK: - Temperature Constants
    
    enum Temperature {
        static let minimumCelsius: Double = -50.0
        static let maximumCelsius: Double = 60.0
        static let minimumFahrenheit: Double = -58.0
        static let maximumFahrenheit: Double = 140.0
        
        static let coldThresholdCelsius: Double = 10.0
        static let coolThresholdCelsius: Double = 18.0
        static let warmThresholdCelsius: Double = 25.0
        static let hotThresholdCelsius: Double = 30.0
        static let extremeHeatThresholdCelsius: Double = 35.0
        
        /// Validate temperature in Celsius
        static func validateCelsius(_ value: Double) -> Double {
            return min(max(value, minimumCelsius), maximumCelsius)
        }
        
        /// Validate temperature in Fahrenheit
        static func validateFahrenheit(_ value: Double) -> Double {
            return min(max(value, minimumFahrenheit), maximumFahrenheit)
        }
        
        /// Convert Fahrenheit to Celsius
        static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
            return (fahrenheit - 32) * 5 / 9
        }
        
        /// Convert Celsius to Fahrenheit
        static func celsiusToFahrenheit(_ celsius: Double) -> Double {
            return celsius * 9 / 5 + 32
        }
    }
    
    // MARK: - Exposure Time Constants
    
    enum ExposureTime {
        /// Minimum safe exposure time in minutes
        static let minimumSafeExposureMinutes = 5
        
        /// Maximum tracked exposure time in minutes
        static let maximumExposureMinutes = 480 // 8 hours
        
        /// Base factor for exposure calculation (minutes * UV index)
        static let baseExposureCalculationFactor = 120.0
        
        /// Reapplication interval for sunscreen in minutes
        static let sunscreenReapplicationIntervalMinutes = 120
        
        /// Water/sweat resistant sunscreen reapplication in minutes
        static let waterResistantReapplicationMinutes = 80
        
        /// Calculate safe exposure time based on UV index
        static func calculateSafeMinutes(uvIndex: Double) -> Int {
            guard uvIndex > 0 else { return maximumExposureMinutes }
            let calculatedTime = baseExposureCalculationFactor / uvIndex
            return max(minimumSafeExposureMinutes, Int(calculatedTime))
        }
    }
    
    // MARK: - SPF Constants
    
    enum SPF {
        static let minimum = 15
        static let recommended = 30
        static let high = 50
        static let veryHigh = 70
        static let maximum = 100
        
        /// Get recommended SPF based on UV index
        static func recommended(for uvIndex: Double) -> Int {
            switch uvIndex {
            case ..<UVIndex.lowThreshold: return minimum
            case ..<UVIndex.moderateThreshold: return recommended
            case ..<UVIndex.highThreshold: return high
            case ..<UVIndex.veryHighThreshold: return veryHigh
            default: return maximum
            }
        }
    }
    
    // MARK: - Hydration Constants
    
    enum Hydration {
        /// Recommended water intake interval in minutes during sun exposure
        static let waterIntakeIntervalMinutes = 15
        
        /// Minimum water intake per hour in milliliters
        static let minimumWaterPerHourML = 250
        
        /// Recommended water intake per hour in hot weather in milliliters
        static let hotWeatherWaterPerHourML = 500
    }
    
    // MARK: - Peak Hours Constants
    
    enum PeakHours {
        static let morningStart = 10  // 10 AM
        static let afternoonEnd = 16   // 4 PM (16:00)
        
        /// Check if current hour is during peak UV hours
        static func isDuringPeakHours(_ hour: Int) -> Bool {
            return hour >= morningStart && hour <= afternoonEnd
        }
    }
    
    // MARK: - Cloud Cover Constants
    
    enum CloudCover {
        static let minimum = 0      // Clear sky
        static let maximum = 100    // Fully overcast
        static let partlyCloudyThreshold = 30
        static let mostlyCloudyThreshold = 70
        
        /// Validate cloud cover percentage
        static func validate(_ value: Int) -> Int {
            return min(max(value, minimum), maximum)
        }
        
        /// UV reduction factor based on cloud cover (0.0 to 1.0)
        static func uvReductionFactor(_ cloudCover: Int) -> Double {
            let validatedCover = validate(cloudCover)
            // Clouds can reduce UV by 20-90% depending on thickness
            // Linear approximation: 0% clouds = 1.0 factor, 100% clouds = 0.3 factor
            return 1.0 - (Double(validatedCover) * 0.007)
        }
    }
    
    // MARK: - Validation Constants
    
    enum Validation {
        /// Valid weather condition strings
        static let validWeatherConditions = [
            "clear", "partly cloudy", "cloudy", "overcast",
            "rain", "drizzle", "storm", "thunderstorm",
            "snow", "sleet", "fog", "mist", "haze",
            "windy", "breezy", "calm"
        ]
        
        /// Validate weather condition string
        static func validateWeatherCondition(_ condition: String) -> String {
            let lowercased = condition.lowercased()
            return validWeatherConditions.first { lowercased.contains($0) } ?? "unknown"
        }
    }
}