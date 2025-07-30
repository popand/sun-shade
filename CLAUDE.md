# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sunshade is an iOS app built with SwiftUI that provides UV index monitoring and sun safety features. The app uses the OpenWeatherMap API for real-time weather and UV data, implements location services, and provides personalized safety recommendations.

## Development Commands

### Building and Testing
```bash
# Open project in Xcode
open Sunshade.xcodeproj

# Build from command line
xcodebuild -project Sunshade.xcodeproj -scheme Sunshade build

# Run tests
xcodebuild -project Sunshade.xcodeproj -scheme Sunshade test
```

### Configuration Setup
1. Copy `Configuration.example.plist` to `Sunshade/Configuration.plist`
2. Add your OpenWeatherMap API key to the configuration file
3. The app checks `Configuration.shared.isAPIKeyConfigured` before making API calls

## Architecture Overview

### MVVM Pattern
- **Models**: Data structures and business logic (`Models/`)
- **Views**: SwiftUI views (`Views/`)  
- **ViewModels**: Observable objects managing state (`Models/*ViewModel.swift`)
- **Services**: External API and system service integration (`Services/`)

### Key Components

#### State Management
- `DashboardViewModel`: Main app state with `@Published` properties
- Uses Combine framework for reactive data flow
- `@MainActor` annotation for UI thread safety

#### Location Services
- `LocationManager`: CoreLocation wrapper with authorization handling
- Publishes location updates via Combine
- Handles reverse geocoding for city names

#### Weather Integration
- `WeatherService`: OpenWeatherMap API client
- Concurrent API calls for weather data and UV index
- Automatic fallback to mock data on API failure
- Proper error handling with custom `WeatherError` enum

#### Data Models
- `WeatherData`: Comprehensive weather/forecast data with tanning quality assessment
- `ExposureLog`: Session tracking with environmental context
- `UserProfile`: Singleton for user preferences and settings
- `UVLevel`: UV index classification system

### Configuration System
- Uses `Configuration.plist` for API keys and settings
- `Configuration.swift` provides centralized config access
- Never commit API keys to repository

### Data Persistence
- `UserDefaults` for user preferences and exposure logs
- `UserProfile.shared` singleton pattern
- Exposure sessions stored as JSON-encoded arrays

## Development Guidelines

### API Integration
- Always check `Configuration.shared.isAPIKeyConfigured` before API calls
- Use async/await for network requests
- Implement proper error handling with fallback data
- Log API responses for debugging (coordinates, UV values)

### Location Handling  
- Request location permissions properly
- Handle all authorization states (denied, restricted, notDetermined)
- Use same coordinates for both weather and UV API calls
- Implement location error handling

### SwiftUI Best Practices
- Use `@Published` properties in ViewModels for reactive UI
- Mark ViewModels with `@MainActor` for thread safety
- Implement proper loading states and error handling
- Use `@StateObject` for ViewModel initialization

### Testing
- Unit tests in `SunshadeTests/`
- UI tests in `SunshadeUITests/`
- Mock data available via `WeatherService.getMockWeatherData()`

## Common Patterns

### Error Handling
```swift
do {
    let data = try await service.fetchData()
    // Handle success
} catch {
    // Set error state and use fallback data
    self.error = error.localizedDescription
    self.data = fallbackData
}
```

### Combine Subscriptions
```swift
service.$data
    .sink { [weak self] newData in
        self?.processData(newData)
    }
    .store(in: &cancellables)
```

### Location Updates
```swift
locationManager.$location
    .compactMap { $0 }
    .sink { location in
        Task { @MainActor in
            await self.updateWeather(for: location)
        }
    }
    .store(in: &cancellables)
```