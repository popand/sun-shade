import Foundation
import SwiftUI

// For /onecall API (fallback)
struct WeatherResponseOnecall: Codable {
    let current: CurrentWeather
    let daily: [DailyWeather]?
}

// For /forecast API (primary)
struct WeatherResponseForecast: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: TimeInterval
    let main: MainWeather
    let weather: [WeatherCondition]
    let clouds: Clouds
    let wind: Wind?
    let visibility: Int?
    let pop: Double?
    let sys: SysInfo?
    let dt_txt: String?
    
    private enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys, dt_txt
    }
}

struct MainWeather: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
}

struct Clouds: Codable {
    let all: Int
}

struct Wind: Codable {
    let speed: Double
}

struct City: Codable {
    let name: String
}

struct SysInfo: Codable {
    let pod: String?
}

struct CurrentWeather: Codable {
    let dt: TimeInterval
    let temp: Double
    let humidity: Int
    let uvi: Double
    let clouds: Int
    let weather: [WeatherCondition]
}

struct DailyWeather: Codable {
    let dt: TimeInterval
    let temp: DailyTemperature
    let uvi: Double
    let clouds: Int
    let weather: [WeatherCondition]
}

struct DailyTemperature: Codable {
    let day: Double
    let min: Double
    let max: Double
}

struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct ForecastDay {
    let date: Date
    let highTemp: Int
    let lowTemp: Int
    let uvIndex: Double
    let cloudCover: Int
    let condition: String
    let iconName: String
    
    var tanningQuality: TanningQuality {
        TanningQuality.fromConditions(uvIndex: uvIndex, cloudCover: cloudCover)
    }
    
    init(from dailyWeather: DailyWeather) {
        self.date = Date(timeIntervalSince1970: dailyWeather.dt)
        // Convert from Fahrenheit (if using imperial units) to Celsius for internal storage
        let highTempCelsius = (dailyWeather.temp.max - 32) * 5/9
        let lowTempCelsius = (dailyWeather.temp.min - 32) * 5/9
        self.highTemp = Int(highTempCelsius.rounded())
        self.lowTemp = Int(lowTempCelsius.rounded())
        self.uvIndex = dailyWeather.uvi
        self.cloudCover = dailyWeather.clouds
        self.condition = dailyWeather.weather.first?.main ?? "Clear"
        self.iconName = dailyWeather.weather.first?.icon ?? "01d"
    }
    
    init(date: Date, highTemp: Int, lowTemp: Int, uvIndex: Double, cloudCover: Int, condition: String, iconName: String) {
        self.date = date
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.uvIndex = uvIndex
        self.cloudCover = cloudCover
        self.condition = condition
        self.iconName = iconName
    }
}

enum TanningQuality: String, CaseIterable {
    case excellent = "Great"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var color: Color {
        switch self {
        case .excellent: return AppColors.success
        case .good: return Color.green
        case .fair: return AppColors.warning
        case .poor: return AppColors.danger
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "hand.thumbsup.fill"
        case .good: return "hand.thumbsup"
        case .fair: return "hand.raised"
        case .poor: return "hand.thumbsdown"
        }
    }
    
    static func fromConditions(uvIndex: Double, cloudCover: Int) -> TanningQuality {
        // High UV with low clouds = great
        if uvIndex >= 6 && cloudCover <= 30 {
            return .excellent
        }
        // Moderate UV with low clouds = good
        else if uvIndex >= 4 && cloudCover <= 50 {
            return .good
        }
        // Low UV or moderate clouds = fair
        else if uvIndex >= 3 || cloudCover <= 70 {
            return .fair
        }
        // Very low UV or heavy clouds = poor
        else {
            return .poor
        }
    }
}

struct WeatherData {
    let temperature: Double
    let uvIndex: Double
    let humidity: Int
    let cloudCover: Int
    let condition: String
    let description: String
    let iconName: String
    let forecast: [ForecastDay]
    
    var currentTanningQuality: TanningQuality {
        TanningQuality.fromConditions(uvIndex: uvIndex, cloudCover: cloudCover)
    }
    
    init(from forecastResponse: WeatherResponseForecast, uvIndex: Double? = nil) {
        // Use the first forecast item for current weather
        let currentItem = forecastResponse.list.first
        
        // Convert from Fahrenheit (API returns imperial units) to Celsius for internal storage
        let tempInFahrenheit = currentItem?.main.temp ?? 70.0
        self.temperature = (tempInFahrenheit - 32) * 5/9
        self.humidity = currentItem?.main.humidity ?? 50
        self.cloudCover = currentItem?.clouds.all ?? 20
        self.condition = currentItem?.weather.first?.main ?? "Clear"
        self.description = currentItem?.weather.first?.description.capitalized ?? "Clear"
        self.iconName = currentItem?.weather.first?.icon ?? "01d"
        
        // Use UV API data if available, otherwise calculate
        if let apiUVIndex = uvIndex {
            self.uvIndex = apiUVIndex
            print("🌞 UV DEBUG - Using UV Index API:")
            print("   📡 API UV Index: \(String(format: "%.1f", apiUVIndex))")
            print("   ✅ Using Real UV Data from OpenWeatherMap")
        } else {
            self.uvIndex = Self.calculateCurrentUVIndex(cloudCover: self.cloudCover)
            print("🌞 UV DEBUG - Using Calculated UV:")
            print("   📡 API UV Index: Not available")
            print("   🧮 Calculated UV Index: \(String(format: "%.1f", self.uvIndex))")
        }
        
        print("   ☁️ Cloud Cover: \(self.cloudCover)%")
        print("   ⏰ Current Time: \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))")
        
        // Convert forecast list to daily forecasts
        self.forecast = Self.convertToDailyForecast(from: forecastResponse.list)
    }
    
    init(from onecallResponse: WeatherResponseOnecall) {
        // Convert from Fahrenheit (if using imperial units) to Celsius for internal storage
        self.temperature = (onecallResponse.current.temp - 32) * 5/9
        self.uvIndex = onecallResponse.current.uvi
        self.humidity = onecallResponse.current.humidity
        self.cloudCover = onecallResponse.current.clouds
        self.condition = onecallResponse.current.weather.first?.main ?? "Clear"
        self.description = onecallResponse.current.weather.first?.description.capitalized ?? "Clear"
        self.iconName = onecallResponse.current.weather.first?.icon ?? "01d"
        self.forecast = onecallResponse.daily?.prefix(5).map { ForecastDay(from: $0) } ?? []
        
        // Debug logging for UV values
        print("🌞 UV DEBUG - OnecCall API Response:")
        print("   📡 API UV Index: \(String(format: "%.1f", onecallResponse.current.uvi))")
        print("   ☁️ Cloud Cover: \(self.cloudCover)%")
        print("   ✅ Using API UV Index: \(String(format: "%.1f", self.uvIndex))")
        print("   ⏰ Current Time: \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))")
    }
    
    private static func convertToDailyForecast(from list: [ForecastItem]) -> [ForecastDay] {
        var dailyForecasts: [ForecastDay] = []
        let calendar = Calendar.current
        
        // Group by day and get one forecast per day
        var dailyGroups: [String: [ForecastItem]] = [:]
        
        for item in list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayKey = calendar.dateInterval(of: .day, for: date)?.start.timeIntervalSince1970.description ?? ""
            
            if dailyGroups[dayKey] == nil {
                dailyGroups[dayKey] = []
            }
            dailyGroups[dayKey]?.append(item)
        }
        
        // Convert to daily forecasts (max 5 days)
        let sortedDays = dailyGroups.keys.sorted()
        for dayKey in sortedDays.prefix(5) {
            if let dayItems = dailyGroups[dayKey], !dayItems.isEmpty {
                let dayForecast = Self.createDailyForecast(from: dayItems)
                dailyForecasts.append(dayForecast)
            }
        }
        
        return dailyForecasts
    }
    
    private static func createDailyForecast(from items: [ForecastItem]) -> ForecastDay {
        // Use midday item if available, otherwise first item
        let middayItem = items.first { item in
            let hour = Calendar.current.component(.hour, from: Date(timeIntervalSince1970: item.dt))
            return hour >= 12 && hour <= 15
        } ?? items.first!
        
        let minTemp = items.map { $0.main.temp_min }.min() ?? middayItem.main.temp_min
        let maxTemp = items.map { $0.main.temp_max }.max() ?? middayItem.main.temp_max
        
        // Convert from Fahrenheit (API returns imperial units) to Celsius for internal storage
        let highTempCelsius = (maxTemp - 32) * 5/9
        let lowTempCelsius = (minTemp - 32) * 5/9
        
        return ForecastDay(
            date: Date(timeIntervalSince1970: middayItem.dt),
            highTemp: Int(highTempCelsius.rounded()),
            lowTemp: Int(lowTempCelsius.rounded()),
            uvIndex: Self.estimateUVIndex(from: middayItem),
            cloudCover: middayItem.clouds.all,
            condition: middayItem.weather.first?.main ?? "Clear",
            iconName: middayItem.weather.first?.icon ?? "01d"
        )
    }
    
    private static func calculateCurrentUVIndex(cloudCover: Int) -> Double {
        // Calculate UV index based on current time and cloud cover
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)
        let timeDecimal = Double(hour) + Double(minute) / 60.0
        
        print("🧮 UV Calculation Details:")
        print("   ⏰ Current Time: \(hour):\(String(format: "%02d", minute)) (decimal: \(String(format: "%.2f", timeDecimal)))")
        
        var baseUV: Double
        
        // More detailed time-based UV calculation
        switch timeDecimal {
        case 0.0..<6.0:
            baseUV = 0.0 // Night: No UV
        case 6.0..<7.0:
            baseUV = 1.0 // Early morning: Very low
        case 7.0..<8.0:
            baseUV = 2.0 // Morning: Low
        case 8.0..<9.0:
            baseUV = 4.0 // Mid-morning: Moderate
        case 9.0..<10.0:
            baseUV = 6.0 // Late morning: High
        case 10.0..<12.0:
            baseUV = 9.0 // Peak morning: Very high
        case 12.0..<14.0:
            baseUV = 11.0 // Peak midday: Extreme
        case 14.0..<15.0:
            baseUV = 9.0 // Early afternoon: Very high
        case 15.0..<16.0:
            baseUV = 7.0 // Mid-afternoon: High
        case 16.0..<17.0:
            baseUV = 5.0 // Late afternoon: Moderate
        case 17.0..<18.0:
            baseUV = 3.0 // Early evening: Low
        case 18.0..<19.0:
            baseUV = 2.0 // Evening: Low
        case 19.0..<20.0:
            baseUV = 1.0 // Late evening: Very low
        default:
            baseUV = 0.0 // Night: No UV
        }
        
        // Adjust for cloud cover
        let cloudFactor = max(0.1, 1.0 - (Double(cloudCover) / 120.0))
        let cloudAdjustedUV = baseUV * cloudFactor
        let finalUV = min(11.0, max(0.0, cloudAdjustedUV))
        
        print("   ☀️ Base UV (time-based): \(String(format: "%.1f", baseUV))")
        print("   ☁️ Cloud Factor: \(String(format: "%.2f", cloudFactor)) (from \(cloudCover)% clouds)")
        print("   🎯 Final UV Index: \(String(format: "%.1f", finalUV))")
        
        return finalUV
    }
    
    private static func estimateUVIndex(from item: ForecastItem) -> Double {
        // Estimate UV index based on cloud cover and time of day
        let hour = Calendar.current.component(.hour, from: Date(timeIntervalSince1970: item.dt))
        let cloudCover = item.clouds.all
        
        var baseUV: Double = 7.0 // Default moderate UV
        
        // Adjust for time of day
        if hour >= 10 && hour <= 14 {
            baseUV = 9.0 // Peak hours
        } else if hour >= 8 && hour <= 16 {
            baseUV = 7.0 // Good hours
        } else {
            baseUV = 3.0 // Early/late hours
        }
        
        // Adjust for cloud cover
        let cloudFactor = max(0.2, 1.0 - (Double(cloudCover) / 100.0))
        baseUV *= cloudFactor
        
        return min(11.0, max(1.0, baseUV))
    }
    
    init(temperature: Double, uvIndex: Double, humidity: Int, cloudCover: Int, condition: String, description: String, iconName: String) {
        self.temperature = temperature
        self.uvIndex = uvIndex
        self.humidity = humidity
        self.cloudCover = cloudCover
        self.condition = condition
        self.description = description
        self.iconName = iconName
        self.forecast = []
    }
}