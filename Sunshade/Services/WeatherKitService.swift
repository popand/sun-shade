import Foundation
import WeatherKit
import CoreLocation

typealias WKWeatherCondition = WeatherKit.WeatherCondition

@available(iOS 16.0, *)
class WeatherKitService: ObservableObject {
    
    enum WeatherKitError: Error, LocalizedError {
        case notAvailable
        case locationError
        case networkError(String)
        case unauthorized
        case authenticationFailed(String)
        case developerAccountRequired
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "WeatherKit is not available on this device"
            case .locationError:
                return "Invalid location provided"
            case .networkError(let message):
                return "Network error: \(message)"
            case .unauthorized:
                return "WeatherKit authorization failed. Please check your Apple Developer account configuration."
            case .authenticationFailed(let details):
                return "WeatherKit authentication failed: \(details)"
            case .developerAccountRequired:
                return "WeatherKit requires an active Apple Developer account. Please ensure you're signed in to Xcode with a valid developer account and that WeatherKit is enabled for your app identifier."
            }
        }
    }
    
    func fetchWeatherData(for location: CLLocation, locationName: String = "") async throws -> WeatherData {
        print("📍 WEATHERKIT DEBUG:")
        print("   🗺️ Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        if !locationName.isEmpty {
            print("   📍 Location Name: \(locationName)")
        }
        
        // Check if WeatherKit is available
        guard Self.isAvailable() else {
            print("⚠️ WeatherKit not available on this device")
            throw WeatherKitError.notAvailable
        }
        
        // Verify location is valid
        guard location.coordinate.latitude >= -90 && location.coordinate.latitude <= 90 &&
              location.coordinate.longitude >= -180 && location.coordinate.longitude <= 180 else {
            print("⚠️ Invalid location coordinates")
            throw WeatherKitError.locationError
        }
        
        do {
            let weatherService = WeatherKit.WeatherService()
            let weather = try await weatherService.weather(for: location)
            
            print("🌤️ WEATHERKIT SUCCESS:")
            print("   🌡️ Temperature: \(weather.currentWeather.temperature.value)°\(weather.currentWeather.temperature.unit.symbol)")
            print("   ☀️ UV Index: \(weather.currentWeather.uvIndex.value)")
            print("   💧 Humidity: \(weather.currentWeather.humidity * 100)%")
            print("   ☁️ Cloud Cover: \(weather.currentWeather.cloudCover * 100)%")
            print("   🌦️ Condition: \(weather.currentWeather.condition.description)")
            
            return createWeatherData(from: weather, locationName: locationName)
            
        } catch let error as NSError {
            print("❌ WEATHERKIT ERROR: \(error)")
            print("   🔍 Error Domain: \(error.domain)")
            print("   🔢 Error Code: \(error.code)")
            print("   📝 Error Description: \(error.localizedDescription)")
            
            // Handle specific WeatherKit authentication errors
            if error.domain.contains("WeatherDaemon.WDSJWTAuthenticatorService") || 
               error.domain.contains("WDSJWTAuthenticatorServiceListener") {
                
                switch error.code {
                case 2:
                    throw WeatherKitError.authenticationFailed("JWT token generation failed. Please ensure your Apple Developer account is active and WeatherKit is enabled for your app identifier.")
                case 1:
                    throw WeatherKitError.unauthorized
                default:
                    throw WeatherKitError.authenticationFailed("Authentication error code \(error.code). Please check your Apple Developer account configuration.")
                }
            } else if error.domain.contains("WeatherService") {
                throw WeatherKitError.networkError("WeatherKit service unavailable: \(error.localizedDescription)")
            } else {
                throw WeatherKitError.networkError(error.localizedDescription)
            }
        }
    }
    
    private func createWeatherData(from weather: Weather, locationName: String) -> WeatherData {
        let current = weather.currentWeather
        
        let temperatureInCelsius = current.temperature.converted(to: .celsius).value
        let uvIndex = Double(current.uvIndex.value)
        let humidity = Int(current.humidity * 100)
        let cloudCover = Int(current.cloudCover * 100)
        let condition = mapWKCondition(current.condition)
        let description = current.condition.description
        let iconName = mapIconName(current.symbolName)
        
        var forecast: [ForecastDay] = []
        
        let dailyForecastArray = Array(weather.dailyForecast.forecast.prefix(5))
        if !dailyForecastArray.isEmpty {
            forecast = dailyForecastArray.map { day in
                let highTempCelsius = day.highTemperature.converted(to: .celsius).value
                let lowTempCelsius = day.lowTemperature.converted(to: .celsius).value
                
                // Estimate cloud cover based on weather condition since daily forecast may not have cloudCover
                let dayCloudCover = estimateCloudCoverFromCondition(day.condition)
                
                return ForecastDay(
                    date: day.date,
                    highTemp: Int(highTempCelsius.rounded()),
                    lowTemp: Int(lowTempCelsius.rounded()),
                    uvIndex: Double(day.uvIndex.value),
                    cloudCover: dayCloudCover,
                    condition: mapWKCondition(day.condition),
                    iconName: mapIconName(day.symbolName)
                )
            }
        }
        
        print("📊 PROCESSED WEATHERKIT DATA:")
        print("   🌡️ Temperature: \(String(format: "%.1f", temperatureInCelsius))°C")
        print("   ☀️ UV Index: \(String(format: "%.1f", uvIndex))")
        print("   💧 Humidity: \(humidity)%")
        print("   ☁️ Cloud Cover: \(cloudCover)%")
        if !locationName.isEmpty {
            print("   🏙️ Location: \(locationName)")
        }
        
        return WeatherData(
            temperature: temperatureInCelsius,
            uvIndex: uvIndex,
            humidity: humidity,
            cloudCover: cloudCover,
            condition: condition,
            description: description,
            iconName: iconName,
            forecast: forecast
        )
    }
    
    private func mapWKCondition(_ condition: WKWeatherCondition) -> String {
        // Map WeatherKit conditions to our simplified conditions
        // Using string representation as WeatherCondition cases may vary by iOS version
        let conditionString = String(describing: condition)
        
        if conditionString.contains("clear") || conditionString.contains("Clear") {
            return "Clear"
        } else if conditionString.contains("cloud") || conditionString.contains("Cloud") {
            return "Clouds"
        } else if conditionString.contains("rain") || conditionString.contains("Rain") || 
                  conditionString.contains("drizzle") || conditionString.contains("Drizzle") {
            return "Rain"
        } else if conditionString.contains("snow") || conditionString.contains("Snow") || 
                  conditionString.contains("flurr") || conditionString.contains("sleet") ||
                  conditionString.contains("blizzard") || conditionString.contains("wintry") {
            return "Snow"
        } else if conditionString.contains("thunder") || conditionString.contains("Thunder") {
            return "Thunderstorm"
        } else if conditionString.contains("fog") || conditionString.contains("Fog") {
            return "Fog"
        } else if conditionString.contains("haz") || conditionString.contains("Haz") ||
                  conditionString.contains("smok") || conditionString.contains("Smok") {
            return "Haze"
        } else if conditionString.contains("wind") || conditionString.contains("Wind") ||
                  conditionString.contains("breez") || conditionString.contains("Breez") {
            return "Wind"
        } else {
            return "Clear"
        }
    }
    
    private func mapIconName(_ symbolName: String) -> String {
        if symbolName.contains("sun.max") {
            return "01d"
        } else if symbolName.contains("cloud.sun") {
            return "02d"
        } else if symbolName.contains("cloud.fill") {
            return "03d"
        } else if symbolName.contains("cloud") {
            return "04d"
        } else if symbolName.contains("rain") && symbolName.contains("sun") {
            return "10d"
        } else if symbolName.contains("rain") {
            return "09d"
        } else if symbolName.contains("thunderstorm") {
            return "11d"
        } else if symbolName.contains("snow") {
            return "13d"
        } else if symbolName.contains("fog") || symbolName.contains("haze") {
            return "50d"
        } else {
            return "01d"
        }
    }
    
    private func estimateCloudCoverFromCondition(_ condition: WeatherKit.WeatherCondition) -> Int {
        let conditionString = String(describing: condition)
        
        // Estimate cloud cover percentage based on weather condition
        if conditionString.contains("clear") || conditionString.contains("Clear") {
            return 10 // Clear skies, minimal clouds
        } else if conditionString.contains("partly") || conditionString.contains("Partly") ||
                  conditionString.contains("few") || conditionString.contains("Few") {
            return 30 // Partly cloudy
        } else if conditionString.contains("mostly") || conditionString.contains("Mostly") ||
                  conditionString.contains("scattered") || conditionString.contains("Scattered") {
            return 60 // Mostly cloudy
        } else if conditionString.contains("cloudy") || conditionString.contains("Cloudy") ||
                  conditionString.contains("overcast") || conditionString.contains("Overcast") {
            return 90 // Overcast
        } else if conditionString.contains("rain") || conditionString.contains("Rain") ||
                  conditionString.contains("storm") || conditionString.contains("Storm") ||
                  conditionString.contains("drizzle") || conditionString.contains("Drizzle") {
            return 85 // Rainy conditions typically have heavy cloud cover
        } else if conditionString.contains("snow") || conditionString.contains("Snow") {
            return 95 // Snow conditions typically overcast
        } else if conditionString.contains("fog") || conditionString.contains("Fog") ||
                  conditionString.contains("haze") || conditionString.contains("Haze") {
            return 75 // Fog/haze often indicates significant cloud cover
        } else {
            return 50 // Default fallback for unknown conditions
        }
    }
    
}

@available(iOS 16.0, *)
extension WeatherKitService {
    static func isAvailable() -> Bool {
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
}