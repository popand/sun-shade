# Apple Sign-In Troubleshooting Guide

## 🔍 Error Analysis

### Your Specific Errors:

#### 1. **Authorization Error -7026**
```
Authorization failed: Error Domain=AKAuthenticationError Code=-7026
```
**Cause**: Apple ID authentication issue
**Solutions**:
- Sign out and back into Apple ID in Settings
- Check Apple ID is verified and active
- Try different Apple ID for testing

#### 2. **ASAuthorizationController Error 1000**
```
ASAuthorizationController credential request failed with error: Code=1000
```
**Cause**: Apple Sign-In capability not properly configured
**Solutions**:
- Enable "Sign In with Apple" capability in Xcode
- Configure capability in Apple Developer Portal

#### 3. **Authorization Error -7003**
```
Authorization failed: Error Domain=AKAuthenticationError Code=-7003
```
**Cause**: Apple ID not signed in or not verified on device
**Solutions**:
- Sign in to Apple ID in iOS Settings
- Verify Apple ID account is active
- Check network connectivity

#### 4. **ASAuthorizationController Error 1001**
```
ASAuthorizationController credential request failed with error: Code=1001
```
**Cause**: User canceled authentication or Apple ID authentication failed
**Solutions**:
- Ensure you're signed in to Apple ID
- Try authentication again
- Check Apple ID account status

#### 5. **Simulator Warnings** (Can be ignored)
```
load_eligibility_plist: Failed to open /Users/.../eligibility.plist: No such file or directory
Failed to send CA Event for app launch measurements...
MCPasscodeManager passcode set check is not supported on this device
```
**Cause**: Normal simulator limitations - these are warnings, not errors
**Solutions**: 
- These warnings are completely normal in simulator
- They don't affect your app functionality
- Test on physical device for cleaner console output
- Or simply ignore these warnings

## 🆘 Current Issue - Error -7003 & 1001

**Your Current Error Status:**
- ✅ Apple Sign-In capability is now properly configured (no more Error 1000)
- ❌ Apple ID authentication is failing (Error -7003, 1001)

**Immediate Steps to Fix:**

### Option 1: Use Simulator with Proper Apple ID Setup
1. **Open iOS Simulator Settings**
2. **Go to Apple ID section (at top)**
3. **Sign in with a valid Apple ID**
4. **Ensure you're signed in to iCloud**
5. **Try Apple Sign-In again**

### Option 2: Test on Physical Device
1. **Go to Settings > [Your Name] on your iPhone**
2. **Verify you're signed in to Apple ID**
3. **Check Sign-In & Security settings**
4. **Run the app on your physical device**

### Option 3: Use Simulation Mode (Immediate Testing)
1. **In the debug view, tap "Simulate User Authentication"**
2. **This will bypass Apple Sign-In and test the UI**
3. **You can see the personalized greeting functionality**

## 🛠️ Step-by-Step Fix

### Step 1: Enable Apple Sign-In Capability in Xcode

1. Open your project in Xcode
2. Select your project in Project Navigator
3. Select the **Sunshade** target
4. Go to **Signing & Capabilities** tab
5. Click **+ Capability**
6. Search for "Sign In with Apple"
7. Add the capability

### Step 2: Configure Apple Developer Portal (If you have a paid developer account)

1. Go to [Apple Developer Console](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers**
4. Find your app identifier: `com.sunshade.app.Sunshade`
5. Edit the identifier
6. Enable **Sign In with Apple** capability
7. Save changes

### Step 3: Test Environment Setup

#### For Simulator Testing:
1. Open **Settings** app in simulator
2. Go to **Apple ID** (at the top)
3. Sign in with your Apple ID
4. Ensure you're signed in to iCloud

#### For Device Testing:
1. Ensure device is signed in to Apple ID
2. Go to **Settings > Apple ID > Sign-In & Security**
3. Verify Apple ID is active and verified

### Step 4: Use Debug View for Testing

I've created a debug view that will help diagnose issues:

1. **Build and run the app**
2. **Use "Test Apple Sign-In" button** to see detailed error messages
3. **Try "Simulate User Authentication"** to test UI without Apple Sign-In
4. **Check debug log** for detailed error information

## 🧪 Testing Different Scenarios

### Scenario 1: No Apple Developer Account
If you don't have a paid Apple Developer account:
- Use the "Simulate User Authentication" button in debug view
- This will test all the UI functionality without requiring Apple Sign-In
- You can see how the personalized greeting works

### Scenario 2: Free Developer Account
If you have a free developer account:
- Apple Sign-In capability might not be available
- Use simulation mode for testing
- Consider upgrading to paid account for full functionality

### Scenario 3: Paid Developer Account
If you have a paid developer account:
- Follow all configuration steps above
- Test on both simulator and device
- Full Apple Sign-In functionality should work

## 🔧 Quick Fixes

### Fix 1: Reset Simulator
```bash
# Reset iOS Simulator
xcrun simctl erase all
```

### Fix 2: Clean Build
1. In Xcode: **Product > Clean Build Folder**
2. Delete derived data
3. Rebuild project

### Fix 3: Check Bundle Identifier
- Ensure bundle identifier matches: `com.sunshade.app.Sunshade`
- Verify it's consistent in both Xcode and Developer Portal

## 📱 Alternative Testing Approach

Since you're encountering configuration issues, I've set up the app to use a debug view that allows you to:

1. **Test Without Apple Sign-In**: Use "Simulate User Authentication"
2. **See Detailed Errors**: View exact error messages and codes
3. **Test UI Flow**: Experience the full authenticated user journey
4. **Debug Configuration**: Check system requirements and capability status

## 🎯 Immediate Actions

1. **Run the app** - you'll see the debug view
2. **Try "Simulate User Authentication"** - this will test the greeting functionality
3. **Check the debug information** - see what's missing in your configuration
4. **Enable Apple Sign-In capability** in Xcode if you want to test real authentication

## 🔄 Switch Back to Production

Once Apple Sign-In is working, change this line in `SunshadeApp.swift`:

```swift
// Change from:
AuthenticationDebugView()

// Back to:
MainContentView()
```

## 📞 Support

If issues persist:
1. Check the debug view for specific error codes
2. Verify Apple Developer account status
3. Test on different devices/simulators
4. Consider using simulation mode for development

The debug view will give you all the information needed to identify exactly what's preventing Apple Sign-In from working in your specific setup!