# Apple Sign-In Setup Guide

This guide will help you set up Apple Sign-In for the Sunshade app.

## Prerequisites

1. Apple Developer account
2. Xcode 14.0+
3. iOS 13.0+ target (Apple Sign-In requires iOS 13+)

## Step 1: Enable Apple Sign-In Capability

### In Xcode:
1. Select your project in the Project Navigator
2. Select your app target (Sunshade)
3. Go to the **Signing & Capabilities** tab
4. Click the **+ Capability** button
5. Search for and add **Sign In with Apple**

### In Apple Developer Portal:
1. Go to [Apple Developer Console](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** and find your app identifier
4. Enable **Sign In with Apple** capability
5. Configure the capability (usually defaults are fine)
6. Save the changes

## Step 2: What's Already Implemented

The following components are already implemented in the codebase:

### ✅ Authentication Manager (`AuthenticationManager.swift`)
- Complete Apple Sign-In state management
- Secure credential storage using UserDefaults
- Automatic credential state checking
- Error handling and user feedback

### ✅ Authentication Views
- **AuthenticationView**: Welcome screen with Apple Sign-In button
- **MainContentView**: App wrapper handling auth/non-auth states
- **AuthenticatedProfileView**: Profile view for signed-in users

### ✅ Dashboard Integration
- **DashboardView**: Updated to show authenticated user's name
- **HeaderSection**: Displays personalized greeting
- **User Experience**: Seamless integration throughout the app

### ✅ Data Models
- **AuthenticatedUser**: User data structure
- **AuthenticationProvider**: Enum for different auth methods
- **Secure Storage**: Proper credential management

## Step 3: Testing Apple Sign-In

### In Simulator:
1. Open Settings app
2. Go to **Apple ID** (at the top)
3. Sign in with your Apple ID
4. Open the Sunshade app
5. Tap "Sign In with Apple"
6. Complete the authentication flow

### On Device:
1. Ensure you're signed in to iCloud
2. Open the Sunshade app
3. Tap "Sign In with Apple"
4. Choose whether to share or hide your email
5. Complete Face ID/Touch ID authentication

## Step 4: Features After Authentication

Once signed in, users will see:

### 🏠 Dashboard
- Personalized greeting: "Good morning, [User's Name]"
- All existing UV monitoring features
- Same great functionality with personalized touch

### 👤 Profile View
- User's name and email (if shared)
- Apple Sign-In indicator
- Account management options
- Sign out functionality

### 🔄 Persistent Sessions
- Authentication persists across app launches
- Automatic credential validation
- Secure session management

## Step 5: Privacy & Security Features

### User Privacy
- Users can choose to share or hide their email
- Names are stored securely on device
- No personal data is transmitted to external servers

### Security
- Uses Apple's secure authentication system
- Automatic credential state checking
- Secure local storage of user preferences

### Credential Management
- Automatic detection of revoked credentials
- Graceful handling of authentication state changes
- Proper cleanup on sign out

## Troubleshooting

### Common Issues:

1. **"Sign In with Apple capability not found"**
   - Ensure the capability is added in Xcode
   - Verify it's enabled in Apple Developer Portal
   - Clean build folder and rebuild

2. **Authentication fails**
   - Check that you're signed in to iCloud (device) or Apple ID (simulator)
   - Verify bundle identifier matches in Developer Portal
   - Ensure capability is properly configured

3. **User data not persisting**
   - Check UserDefaults access permissions
   - Verify data is being encoded/decoded properly
   - Clear app data and test fresh installation

4. **"This app cannot use Sign In with Apple"**
   - Verify Apple Developer account is active
   - Check that the app identifier has the capability enabled
   - Ensure you're testing on iOS 13+ device/simulator

## Additional Features

### Personalization
- Greeting changes based on time of day and user's name
- Profile view shows user's initials if no photo available
- Consistent user experience across all app features

### Account Management
- Easy sign out process
- Clear indication of authentication status
- Proper cleanup of user data on sign out

## Security Best Practices

- User credentials are validated on each app launch
- Secure storage of authentication tokens
- Automatic handling of credential revocation
- No storage of sensitive authentication data

## Support Resources

- [Apple Sign-In Documentation](https://developer.apple.com/documentation/authenticationservices)
- [Human Interface Guidelines for Sign In with Apple](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)
- [Apple Developer Portal](https://developer.apple.com)