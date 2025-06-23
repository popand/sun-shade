# Location Services Setup

To enable location services for the SunSmart app, you need to add location usage descriptions to your app's Info.plist file.

## Adding Location Permissions

1. Open the project in Xcode
2. Select the SunSmart target in the project navigator
3. Go to the "Info" tab
4. Add the following keys and values:

### Required Info.plist Keys:

- **Key**: `NSLocationWhenInUseUsageDescription`
- **Value**: `SunSmart needs access to your location to provide accurate UV index and weather information for your area.`

- **Key**: `NSLocationAlwaysAndWhenInUseUsageDescription`  
- **Value**: `SunSmart needs access to your location to provide accurate UV index and weather information for your area.`

## Weather API Setup

To use real weather data instead of mock data:

1. Get a free API key from OpenWeatherMap:
   - Visit https://openweathermap.org/api
   - Create a free account
   - Get your API key from the dashboard

2. Create your Configuration.plist file:
   ```bash
   # Copy the example configuration
   cp Configuration.example.plist SunSmart/Configuration.plist
   ```

3. Edit `SunSmart/Configuration.plist` and replace the placeholder:
   ```xml
   <key>OpenWeatherMapAPIKey</key>
   <string>your_actual_api_key_here</string>
   ```

4. **Important**: Never commit `Configuration.plist` to version control. It's already excluded in `.gitignore`.

## Features Implemented

- ✅ Dynamic greeting based on time of day
- ✅ Real-time location detection
- ✅ Weather data integration (with fallback to mock data)
- ✅ UV index from weather API
- ✅ Error handling for location/weather failures
- ✅ Automatic data refresh when location changes