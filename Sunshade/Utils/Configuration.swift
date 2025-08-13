import Foundation

struct Configuration {
    static let shared = Configuration()
    
    private let configDict: [String: Any]
    
    private init() {
        // Configuration.plist is now optional since WeatherKit doesn't require API keys
        if let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            configDict = dict
        } else {
            configDict = [:]
        }
    }
    
    // Add any app-specific configuration here as needed
}