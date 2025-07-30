# Google Authentication Setup Guide

This guide will help you set up Google Sign-In for the Sunshade app.

## Prerequisites

1. A Google Cloud Platform account
2. Xcode 14.0+
3. iOS 15.0+ target

## Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note down your Project ID

## Step 2: Enable Google Sign-In API

1. In the Google Cloud Console, go to **APIs & Services > Library**
2. Search for "Google Sign-In API" and enable it
3. Go to **APIs & Services > Credentials**

## Step 3: Create OAuth 2.0 Credentials

1. Click **Create Credentials > OAuth client ID**
2. Select **iOS** as the application type
3. Enter your app's bundle identifier: `com.sunshade.app.Sunshade`
4. Download the configuration file

## Step 4: Configure the iOS App

1. **Add GoogleService-Info.plist to your project:**
   - Drag the downloaded `GoogleService-Info.plist` file into your Xcode project
   - Make sure it's added to the main app target
   - Ensure "Copy items if needed" is checked

2. **Add Google Sign-In SDK via Swift Package Manager:**
   - In Xcode, go to **File > Add Package Dependencies**
   - Enter the URL: `https://github.com/google/GoogleSignIn-iOS`
   - Select the latest version and add to your project
   - Make sure to add `GoogleSignIn` to your main app target

3. **URL Schemes are Pre-configured:**
   - The URL schemes are already configured in the project settings
   - Your REVERSED_CLIENT_ID (`com.googleusercontent.apps.1018143342717-00ph737p0nhjr0qmfbe846pnn6qmjseg`) is automatically included
   - No manual configuration needed for URL schemes

## Step 5: Update App Transport Security (Optional)

If you encounter network issues, you may need to update your Info.plist to allow HTTP connections:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Step 6: Test the Integration

1. Build and run the app
2. Tap "Continue with Google"
3. Complete the authentication flow
4. Verify that user information is displayed correctly

## Configuration Files

- `GoogleService-Info.plist` - Contains your Google project configuration
- `GoogleService-Info.example.plist` - Template file (replace with your actual configuration)

## Troubleshooting

### Common Issues:

1. **"No such module 'GoogleSignIn'"**
   - Ensure Google Sign-In SDK is properly added via Swift Package Manager
   - Clean build folder and rebuild

2. **"GoogleService-Info.plist not found"**
   - Make sure the file is added to your Xcode project
   - Verify it's included in the main app target

3. **Authentication fails**
   - Check that your bundle identifier matches the one in Google Cloud Console
   - Verify URL schemes are configured correctly
   - Ensure the REVERSED_CLIENT_ID is added as a URL scheme

4. **"The operation couldn't be completed"**
   - Check your internet connection
   - Verify Google Sign-In API is enabled in Google Cloud Console
   - Check that your OAuth client is properly configured

## Security Notes

- Never commit `GoogleService-Info.plist` to version control
- Add `GoogleService-Info.plist` to your `.gitignore` file
- Use the example file for reference and team setup

## Additional Resources

- [Google Sign-In for iOS Documentation](https://developers.google.com/identity/sign-in/ios)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Cloud Console](https://console.cloud.google.com/)