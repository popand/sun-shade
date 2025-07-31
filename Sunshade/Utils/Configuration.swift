import Foundation

struct Configuration {
    static let shared = Configuration()
    
    private let configDict: [String: Any]
    
    private init() {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ Configuration.plist not found. Using fallback values.")
            configDict = [:]
            return
        }
        configDict = dict
    }
    
    var openWeatherMapAPIKey: String {
        return configDict["OpenWeatherMapAPIKey"] as? String ?? "YOUR_OPENWEATHERMAP_API_KEY"
    }
    
    var isAPIKeyConfigured: Bool {
        return openWeatherMapAPIKey != "YOUR_OPENWEATHERMAP_API_KEY" && !openWeatherMapAPIKey.isEmpty
    }
    
    // Add other configuration values here as needed
    var weatherAPIBaseURL: String {
        return configDict["WeatherAPIBaseURL"] as? String ?? "https://api.openweathermap.org/data/2.5/forecast"
    }
}