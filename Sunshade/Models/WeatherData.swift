import Foundation
import SwiftUI

// WeatherKit uses native Swift types, no custom API models needed

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
    
    
    
    
    init(temperature: Double, uvIndex: Double, humidity: Int, cloudCover: Int, condition: String, description: String, iconName: String, forecast: [ForecastDay] = []) {
        self.temperature = temperature
        self.uvIndex = uvIndex
        self.humidity = humidity
        self.cloudCover = cloudCover
        self.condition = condition
        self.description = description
        self.iconName = iconName
        self.forecast = forecast
    }
}