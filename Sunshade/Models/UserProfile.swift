import Foundation

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
            UserDefaults.standard.set(name, forKey: "userName")
        }
    }
    
    @Published var skinType: String {
        didSet {
            UserDefaults.standard.set(skinType, forKey: "userSkinType")
        }
    }
    
    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(temperatureUnit.rawValue, forKey: "temperatureUnit")
        }
    }
    
    init() {
        self.name = UserDefaults.standard.string(forKey: "userName") ?? "John Doe"
        self.skinType = UserDefaults.standard.string(forKey: "userSkinType") ?? "Fair"
        
        let savedUnit = UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: savedUnit) ?? .celsius
    }
    
    static let shared = UserProfile()
} 