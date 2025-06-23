import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    private let configuration = Configuration.shared
    
    private var apiKey: String {
        configuration.openWeatherMapAPIKey
    }
    
    private var baseURL: String {
        configuration.weatherAPIBaseURL
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
    
    func fetchWeatherData(for location: CLLocation) async throws -> WeatherData {
        guard configuration.isAPIKeyConfigured else {
            throw WeatherError.missingAPIKey
        }
        
        guard let url = buildURL(for: location) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw WeatherError.networkError("Invalid response")
            }
            
            let forecastResponse = try JSONDecoder().decode(WeatherResponseForecast.self, from: data)
            return WeatherData(from: forecastResponse)
            
        } catch is DecodingError {
            throw WeatherError.decodingError
        } catch {
            throw WeatherError.networkError(error.localizedDescription)
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
        return components?.url
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
                wind: Wind(speed: Double.random(in: 2...15))
            ))
        }
        
        return forecast
    }

}