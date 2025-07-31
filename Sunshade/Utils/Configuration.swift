import Foundation
import Security

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
        // First try environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENWEATHERMAP_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // Then try keychain
        if let keychainKey = getFromKeychain(key: "OpenWeatherMapAPIKey"), !keychainKey.isEmpty {
            return keychainKey
        }
        
        // Fallback to plist (for development only)
        if let plistKey = configDict["OpenWeatherMapAPIKey"] as? String, 
           plistKey != "YOUR_OPENWEATHERMAP_API_KEY_HERE" && !plistKey.isEmpty {
            return plistKey
        }
        
        return "YOUR_OPENWEATHERMAP_API_KEY"
    }
    
    var isAPIKeyConfigured: Bool {
        let key = openWeatherMapAPIKey
        return key != "YOUR_OPENWEATHERMAP_API_KEY" && key != "YOUR_OPENWEATHERMAP_API_KEY_HERE" && !key.isEmpty
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let keyValue = String(data: data, encoding: .utf8) {
            return keyValue
        }
        
        return nil
        //return configDict["OpenWeatherMapAPIKey"] as? String ?? "YOUR_OPENWEATHERMAP_API_KEY"
    }
    
    var isAPIKeyConfigured: Bool {
        return openWeatherMapAPIKey != "YOUR_OPENWEATHERMAP_API_KEY" && !openWeatherMapAPIKey.isEmpty
    }
    
    // Add other configuration values here as needed
    var weatherAPIBaseURL: String {
        return configDict["WeatherAPIBaseURL"] as? String ?? "https://api.openweathermap.org/data/3.0/onecall"
    }
}