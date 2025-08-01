import SwiftUI
import Combine
import CoreLocation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var currentUVIndex: Double = 7.2
    @Published var currentLocation: String = "Loading location..."
    @Published var temperature: Int = 72
    @Published var weatherCondition: String = "Partly Cloudy"
    @Published var cloudCover: Int = 35
    @Published var totalExposureToday: String = "45 min"
    @Published var sessionsToday: Int = 2
    @Published var isLoading: Bool = false
    @Published var weatherError: String?
    @Published var greeting: String = ""
    @Published var forecast: [ForecastDay] = []
    @Published var currentTanningQuality: TanningQuality = .fair
    
    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    private let userProfile = UserProfile.shared
    private var cancellables = Set<AnyCancellable>()
    
    var uvLevel: UVLevel {
        UVLevel.level(for: currentUVIndex)
    }
    
    var formattedTemperature: String {
        let tempInUserUnit = userProfile.temperatureUnit.convert(from: Double(temperature))
        return "\(Int(tempInUserUnit.rounded()))\(userProfile.temperatureUnit.symbol)"
    }
    
    func formatTemperature(_ tempInCelsius: Double) -> String {
        let tempInUserUnit = userProfile.temperatureUnit.convert(from: tempInCelsius)
        return "\(Int(tempInUserUnit.rounded()))\(userProfile.temperatureUnit.symbol)"
    }
    
    func formatTemperatureValue(_ tempInCelsius: Int) -> Int {
        let tempInUserUnit = userProfile.temperatureUnit.convert(from: Double(tempInCelsius))
        return Int(tempInUserUnit.rounded())
    }
    
    var safeExposureTime: String {
        let baseTime = max(15, Int(120 / max(currentUVIndex, 1.0)))
        return "\(baseTime) minutes"
    }
    
    var safetyRecommendations: [String] {
        var recommendations: [String] = []
        
        if currentUVIndex >= 6 {
            recommendations.append("Seek shade between 10 AM - 4 PM")
            recommendations.append("Wear protective clothing and wide-brimmed hat")
        }
        
        recommendations.append("Apply SPF 30+ sunscreen 15 minutes before exposure")
        recommendations.append("Reapply sunscreen every 2 hours")
        
        if currentUVIndex >= 8 {
            recommendations.append("Wear UV-blocking sunglasses")
            recommendations.append("Consider staying indoors during peak hours")
        }
        
        return recommendations
    }
    
    init() {
        updateGreeting()
        setupLocationObserver()
        setupPeriodicGreetingUpdate()
        setupUserProfileObserver()
    }
    
    private func setupLocationObserver() {
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                Task { @MainActor in
                    await self?.fetchWeatherData(for: location)
                }
            }
            .store(in: &cancellables)
        
        locationManager.$city
            .sink { [weak self] city in
                if !city.isEmpty {
                    self?.currentLocation = city
                }
            }
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                switch status {
                case .denied, .restricted:
                    self?.currentLocation = "Location access denied"
                case .notDetermined:
                    self?.currentLocation = "Location permission required"
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        locationManager.$locationError
            .sink { [weak self] error in
                self?.weatherError = error
            }
            .store(in: &cancellables)
    }
    
    private func setupPeriodicGreetingUpdate() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateGreeting()
            }
            .store(in: &cancellables)
    }
    
    private func setupUserProfileObserver() {
        userProfile.$name
            .sink { [weak self] _ in
                self?.updateGreeting()
            }
            .store(in: &cancellables)
        
        // Observe temperature unit changes to trigger view updates
        userProfile.$temperatureUnit
            .sink { [weak self] _ in
                // Force view update by triggering objectWillChange
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func updateGreeting() {
        greeting = TimeUtils.getPersonalizedGreeting(name: userProfile.name)
    }
    
    func updateGreetingForUser(_ userName: String) {
        greeting = TimeUtils.getPersonalizedGreeting(name: userName)
    }
    
    private func fetchWeatherData(for location: CLLocation) async {
        isLoading = true
        weatherError = nil
        
        do {
            // Only pass location name if it's not a loading/error state
            let locationName = currentLocation.starts(with: "Loading") || currentLocation.starts(with: "Location access") || currentLocation.starts(with: "Location permission") ? "" : currentLocation
            let weatherData = try await weatherService.fetchWeatherData(for: location, locationName: locationName)
            

            
            currentUVIndex = weatherData.uvIndex
            // weatherData.temperature is already in Celsius (converted in WeatherData init)
            temperature = Int(weatherData.temperature.rounded())
            weatherCondition = weatherData.description
            cloudCover = weatherData.cloudCover
            forecast = weatherData.forecast
            currentTanningQuality = weatherData.currentTanningQuality
            
        } catch {

            weatherError = error.localizedDescription
            
            // Use mock data as fallback only when API fails
            let mockData = weatherService.getMockWeatherData()
            currentUVIndex = mockData.uvIndex
            // mockData.temperature is already in Celsius (converted in WeatherData init)
            temperature = Int(mockData.temperature.rounded())
            weatherCondition = mockData.description
            cloudCover = mockData.cloudCover
            forecast = mockData.forecast
            currentTanningQuality = mockData.currentTanningQuality
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        isLoading = true
        updateGreeting()
        
        // Clear any existing errors
        weatherError = nil
        
        // Request fresh location first
        locationManager.requestLocation()
        
        // If we have a cached location, use it immediately while waiting for fresh location
        if let location = locationManager.location {
            await fetchWeatherData(for: location)
        } else {
            // If no cached location, set loading message and wait for location
            currentLocation = "Loading location..."
            // The location observer will trigger weather fetch when location is obtained
        }
        
        // Note: isLoading will be set to false in fetchWeatherData
        if locationManager.location == nil {
            isLoading = false
        }
    }
    
    func refreshData() {
        Task {
            await refreshData()
        }
    }
}