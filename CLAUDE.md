# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SunSmart is an iOS SwiftUI application for UV index monitoring and sun safety. The app provides real-time UV data, safety recommendations, exposure tracking, and educational content about sun protection.

## Architecture

The app follows a SwiftUI/MVVM architecture pattern:

- **Single File Structure**: All components are currently in `ContentView.swift` for simplicity
- **View Models**: `DashboardViewModel` manages UV data and safety calculations using `@MainActor` and `@ObservableObject`
- **Modular Components**: Views are broken into reusable cards (UVIndexCard, WeatherCard, SafetyCard, etc.)
- **Tab-based Navigation**: Four main sections - Dashboard, Timer, Learn, Profile
- **Color System**: Centralized `AppColors` struct with semantic color definitions

### Key Components

- **UVLevel Enum**: Categorizes UV index values (1-11) into safety levels with associated colors
- **DashboardViewModel**: Manages current UV data, location, weather, and calculates safe exposure times
- **Safety Timer**: Countdown timer for safe sun exposure periods
- **Educational Content**: Static cards for sun safety information

## Development Commands

### Building
```bash
# Build for device/simulator
xcodebuild -scheme SunSmart -configuration Debug build

# Clean build
xcodebuild -scheme SunSmart clean build
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme SunSmart -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests  
xcodebuild test -scheme SunSmart -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SunSmartUITests
```

### Analysis
```bash
# Static analysis
xcodebuild analyze -scheme SunSmart

# Check for warnings
xcodebuild -scheme SunSmart -configuration Debug | grep warning
```

## Code Patterns

- Use `@MainActor` for view models that update UI
- Follow SwiftUI naming conventions for view structs
- Organize code with `// MARK:` comments for sections
- Use computed properties for derived data in view models
- Leverage SwiftUI's declarative syntax with modifier chaining
- Use semantic colors from `AppColors` rather than hardcoded values

## Weather Integration

The app integrates real-time weather and location services:

- **LocationManager**: Handles Core Location permissions and location detection
- **WeatherService**: Fetches weather data from OpenWeatherMap API with fallback to mock data
- **DashboardViewModel**: Reactive data binding with Combine publishers
- **Dynamic Features**: Time-based greetings, real location display, automatic data refresh

### Setup Requirements

1. Add location permissions to Info.plist (see LOCATION_SETUP.md)
2. Copy `Configuration.example.plist` to `SunSmart/Configuration.plist` and add real OpenWeatherMap API key
3. Test location permissions in device/simulator settings

### Configuration Management

API keys are stored in `Configuration.plist` (excluded from version control):
- `Configuration.swift` provides centralized access to configuration values
- `Configuration.example.plist` serves as a template for required keys
- `.gitignore` ensures secrets don't get committed

## Testing Framework

The project uses Swift Testing (not XCTest) - note the `import Testing` and `@Test` attributes in test files.