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
        self.highTemp = Int(dailyWeather.temp.max.rounded())
        self.lowTemp = Int(dailyWeather.temp.min.rounded())
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
    
    init(from forecastResponse: WeatherResponseForecast) {
        // Use the first forecast item for current weather
        let currentItem = forecastResponse.list.first
        
        self.temperature = currentItem?.main.temp ?? 70.0
        self.uvIndex = 7.0 // Forecast API doesn't include UV, we'll estimate based on conditions
        self.humidity = currentItem?.main.humidity ?? 50
        self.cloudCover = currentItem?.clouds.all ?? 20
        self.condition = currentItem?.weather.first?.main ?? "Clear"
        self.description = currentItem?.weather.first?.description.capitalized ?? "Clear"
        self.iconName = currentItem?.weather.first?.icon ?? "01d"
        
        // Convert forecast list to daily forecasts
        self.forecast = Self.convertToDailyForecast(from: forecastResponse.list)
    }
    
    init(from onecallResponse: WeatherResponseOnecall) {
        self.temperature = onecallResponse.current.temp
        self.uvIndex = onecallResponse.current.uvi
        self.humidity = onecallResponse.current.humidity
        self.cloudCover = onecallResponse.current.clouds
        self.condition = onecallResponse.current.weather.first?.main ?? "Clear"
        self.description = onecallResponse.current.weather.first?.description.capitalized ?? "Clear"
        self.iconName = onecallResponse.current.weather.first?.icon ?? "01d"
        self.forecast = onecallResponse.daily?.prefix(5).map { ForecastDay(from: $0) } ?? []
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
        
        return ForecastDay(
            date: Date(timeIntervalSince1970: middayItem.dt),
            highTemp: Int(maxTemp.rounded()),
            lowTemp: Int(minTemp.rounded()),
            uvIndex: Self.estimateUVIndex(from: middayItem),
            cloudCover: middayItem.clouds.all,
            condition: middayItem.weather.first?.main ?? "Clear",
            iconName: middayItem.weather.first?.icon ?? "01d"
        )
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