# Configuration Setup Guide

This guide explains how to set up API keys and configuration values securely for the Sunshade app.

## Quick Setup

1. **Copy the configuration template:**
   ```bash
   cp Configuration.example.plist Sunshade/Configuration.plist
   ```

2. **Add your OpenWeatherMap API key:**
   - Get a free API key from https://openweathermap.org/api
   - Edit `Sunshade/Configuration.plist`
   - Replace `YOUR_OPENWEATHERMAP_API_KEY_HERE` with your actual API key

3. **Verify the setup:**
   - The app will automatically use your API key
   - Without a valid key, the app falls back to mock weather data
   - Check the console for "⚠️ Configuration.plist not found" warnings

## Security Features

✅ **Configuration.plist is excluded from version control**
- Added to `.gitignore` to prevent accidental commits
- Only `Configuration.example.plist` is tracked in git
- Your actual API keys never get committed

✅ **Centralized configuration management**
- All secrets managed through `Configuration.swift`
- Easy to add new configuration values
- Built-in validation and fallback values

✅ **Runtime validation**
- App checks if API key is properly configured
- Graceful fallback to mock data when keys are missing
- Clear error messages for debugging

## Configuration Values

| Key | Description | Required |
|-----|-------------|----------|
| `OpenWeatherMapAPIKey` | Your OpenWeatherMap API key | Yes* |
| `WeatherAPIBaseURL` | API endpoint URL | No |

*Required for real weather data. App works with mock data if not provided.

## Troubleshooting

**"Configuration.plist not found" warning:**
- Copy `Configuration.example.plist` to `Sunshade/Configuration.plist`
- Make sure the file is in the correct location

**App using mock weather data:**
- Check that your API key is valid and not expired
- Verify the key is correctly set in `Configuration.plist`
- Check network connectivity for API requests

**API key in git history:**
- If you accidentally committed an API key, rotate it immediately
- Use `git filter-branch` or BFG to clean git history
- Generate a new API key from OpenWeatherMap

## Adding New Configuration Values

1. Add the key to `Configuration.example.plist`
2. Add a computed property in `Configuration.swift`
3. Use the new value via `Configuration.shared.yourNewValue`
4. Update this documentation