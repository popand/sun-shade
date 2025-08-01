import Foundation
import CoreLocation

struct UVIndexResponse: Codable {
    let lat: Double
    let lon: Double
    let date_iso: String
    let date: TimeInterval
    let value: Double
}

class WeatherService: ObservableObject {
    private let configuration = Configuration.shared
    
    private var apiKey: String {
        configuration.openWeatherMapAPIKey
    }
    
    private var baseURL: String {
        configuration.weatherAPIBaseURL
    }
    
    private var uvIndexBaseURL: String {
        "https://api.openweathermap.org/data/2.5/uvi"
    }
    
    enum WeatherError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case networkError(String)
        case missingAPIKey
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode weather data"
            case .networkError(let message):
                return "Network error: \(message)"
            case .missingAPIKey:
                return "Missing OpenWeatherMap API key"
            }
        }
    }
    
    func fetchWeatherData(for location: CLLocation, locationName: String = "") async throws -> WeatherData {
        guard configuration.isAPIKeyConfigured else {
            throw WeatherError.missingAPIKey
        }
        
        // Debug: Log the location being used for both APIs
        print("📍 LOCATION DEBUG:")
        print("   🗺️ Input Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        if !locationName.isEmpty {
            print("   📍 Location Name: \(locationName)")
        }
        print("   🌐 Will use same coordinates for both Weather and UV APIs")
        print("   🌡️ Note: API returns temperatures in Fahrenheit (imperial units)")
        
        // Fetch weather data and UV index concurrently
        async let weatherDataTask = fetchForecastData(for: location)
        async let uvIndexTask = fetchUVIndex(for: location, locationName: locationName)
        
        do {
            let forecastResponse = try await weatherDataTask
            let uvIndexResponse = try await uvIndexTask
            
            let weatherData = WeatherData(from: forecastResponse, uvIndex: uvIndexResponse?.value)
            
            // Debug: Log final processed weather data
            print("📊 PROCESSED WEATHER DATA:")
            print("   🌡️ Internal Temperature: \(String(format: "%.1f", weatherData.temperature))°C (Converted for Storage)")
            if let currentTemp = forecastResponse.list.first?.main.temp {
                let convertedTemp = (currentTemp - 32) * 5/9
                print("   🔄 Conversion Check: \(String(format: "%.1f", currentTemp))°F → \(String(format: "%.1f", convertedTemp))°C")
            }
            print("   ☀️ Final UV Index: \(String(format: "%.1f", weatherData.uvIndex))")
            if !locationName.isEmpty {
                print("   🏙️ Location: \(locationName)")
            }
            
            return weatherData
            
        } catch {
            // If UV API fails, fall back to weather data only
            print("⚠️ UV API failed, using calculated UV: \(error)")
            let forecastResponse = try await fetchForecastData(for: location)
            let weatherData = WeatherData(from: forecastResponse, uvIndex: nil)
            
            // Debug: Log final processed weather data (fallback)
            print("📊 PROCESSED WEATHER DATA (Fallback):")
            print("   🌡️ Internal Temperature: \(String(format: "%.1f", weatherData.temperature))°C (Converted for Storage)")
            if let currentTemp = forecastResponse.list.first?.main.temp {
                let convertedTemp = (currentTemp - 32) * 5/9
                print("   🔄 Conversion Check: \(String(format: "%.1f", currentTemp))°F → \(String(format: "%.1f", convertedTemp))°C")
            }
            print("   ☀️ Final UV Index: \(String(format: "%.1f", weatherData.uvIndex)) (Calculated)")
            if !locationName.isEmpty {
                print("   🏙️ Location: \(locationName)")
            }
            
            return weatherData
        }
    }
    
    private func fetchForecastData(for location: CLLocation) async throws -> WeatherResponseForecast {
        guard let url = buildURL(for: location) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WeatherError.networkError("Invalid response")
        }
        
        let forecastResponse = try JSONDecoder().decode(WeatherResponseForecast.self, from: data)
        
        // Debug: Log weather API response details
        if let currentWeather = forecastResponse.list.first {
            print("🌤️ WEATHER API SUCCESS:")
            print("   🌡️ Temperature: \(currentWeather.main.temp)°F (API Response)")
            print("   🌡️ Temperature Range: \(currentWeather.main.temp_min)°F - \(currentWeather.main.temp_max)°F")
            print("   💧 Humidity: \(currentWeather.main.humidity)%")
            print("   ☁️ Cloud Cover: \(currentWeather.clouds.all)%")
            print("   🌦️ Condition: \(currentWeather.weather.first?.description.capitalized ?? "Unknown")")
            print("   📍 Response Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("   📅 Data Time: \(Date(timeIntervalSince1970: currentWeather.dt))")
        }
        
        return forecastResponse
    }
    
    private func fetchUVIndex(for location: CLLocation, locationName: String = "") async throws -> UVIndexResponse? {
        guard let url = buildUVIndexURL(for: location) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw WeatherError.networkError("UV API Invalid response")
            }
            
            let uvResponse = try JSONDecoder().decode(UVIndexResponse.self, from: data)
            print("🌞 UV API SUCCESS:")
            print("   ☀️ UV Index: \(uvResponse.value)")
            print("   📍 Response Coordinates: \(uvResponse.lat), \(uvResponse.lon)")
            if !locationName.isEmpty {
                print("   🏙️ Location: \(locationName)")
            }
            print("   📅 Date: \(uvResponse.date_iso)")
            return uvResponse
            
        } catch is DecodingError {
            print("❌ UV API Decoding Error")
            throw WeatherError.decodingError
        } catch {
            print("❌ UV API Network Error: \(error.localizedDescription)")
            throw WeatherError.networkError("UV API: \(error.localizedDescription)")
        }
    }
    
    private func buildURL(for location: CLLocation) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "APPID", value: apiKey),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "cnt", value: "40") // 5 days * 8 (3-hour intervals)
        ]
        
        let url = components?.url
        print("🌤️ Weather API URL: \(url?.absoluteString ?? "Invalid URL")")
        print("   📍 Weather API Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        return url
    }
    
    private func buildUVIndexURL(for location: CLLocation) -> URL? {
        var components = URLComponents(string: uvIndexBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "APPID", value: apiKey)
        ]
        
        let url = components?.url
        print("🌞 UV API URL: \(url?.absoluteString ?? "Invalid URL")")
        print("   📍 UV API Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        return url
    }
    
    // Mock data for development/demo purposes
    func getMockWeatherData() -> WeatherData {
        let mockResponse = WeatherResponseForecast(
            list: generateMockForecastList(),
            city: City(name: "Mock City")
        )
        
        return WeatherData(from: mockResponse)
    }
    
    private func generateMockForecastList() -> [ForecastItem] {
        var forecast: [ForecastItem] = []
        
        for i in 0..<40 { // 5 days * 8 items per day
            let date = Calendar.current.date(byAdding: .hour, value: i * 3, to: Date()) ?? Date()
            forecast.append(ForecastItem(
                dt: date.timeIntervalSince1970,
                main: MainWeather(
                    temp: Double.random(in: 65...85),
                    temp_min: Double.random(in: 55...75),
                    temp_max: Double.random(in: 75...95),
                    humidity: Int.random(in: 30...80)
                ),
                weather: [WeatherCondition(
                    id: [800, 801, 802, 803].randomElement() ?? 801,
                    main: ["Clear", "Clouds", "Rain"].randomElement() ?? "Clear",
                    description: ["Clear", "Partly Cloudy", "Cloudy", "Light Rain"].randomElement() ?? "Clear",
                    icon: ["01d", "02d", "03d", "10d"].randomElement() ?? "01d"
                )],
                clouds: Clouds(all: Int.random(in: 10...80)),
                wind: Wind(speed: Double.random(in: 2...15)),
                visibility: Int.random(in: 8000...10000),
                pop: Double.random(in: 0...0.3),
                sys: nil,
                dt_txt: DateFormatter().string(from: date)
            ))
        }
        
        return forecast
    }

}