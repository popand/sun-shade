# Fix Apple Sign-In Error 1000

## Issue
You're encountering error 1000 which indicates the Sign in with Apple capability is not properly configured in your Xcode project.

## Solution Steps

### 1. Open Project in Xcode
```bash
open Sunshade.xcodeproj
```

### 2. Add Sign in with Apple Capability
1. Select the **Sunshade** project in the navigator
2. Select the **Sunshade** target
3. Go to the **Signing & Capabilities** tab
4. Click the **"+"** button (top left of capabilities section)
5. Search for **"Sign In with Apple"**
6. Double-click to add it

### 3. Link Entitlements File
The entitlements file already exists at `Sunshade/Sunshade.entitlements` but needs to be linked:

1. Still in **Signing & Capabilities** tab
2. Look for **Code Signing Entitlements** field
3. Set it to: `Sunshade/Sunshade.entitlements`

OR manually in Build Settings:
1. Go to **Build Settings** tab
2. Search for **"CODE_SIGN_ENTITLEMENTS"**
3. Set value to: `Sunshade/Sunshade.entitlements`

### 4. Verify Apple Developer Portal Configuration
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers**
4. Find **com.sunshade.app.Sunshade**
5. Ensure **Sign In with Apple** is enabled
6. Save any changes

### 5. Clean and Rebuild
```bash
# In Xcode:
# Product → Clean Build Folder (Shift+Cmd+K)
# Product → Build (Cmd+B)

# Or from terminal:
xcodebuild -project Sunshade.xcodeproj -scheme Sunshade clean build
```

### 6. Test on Simulator
1. Ensure you're signed into an Apple ID in the simulator:
   - Settings → Sign in to your iPhone
   - Enter your Apple ID credentials
2. Run the app
3. Try Sign in with Apple again

## Troubleshooting

### If Error Persists:
1. **Verify Provisioning Profile**: Ensure your provisioning profile includes the Sign In with Apple capability
2. **Check Team ID**: Verify your Team ID is correctly set in Signing & Capabilities
3. **Regenerate Provisioning**: Sometimes you need to regenerate provisioning profiles after adding capabilities

### Common Error Codes:
- **Error 1000**: Capability not configured in Xcode
- **Error -7026**: Device Apple ID authentication issue
- **Error -7003**: Not signed into Apple ID on device
- **Error 1001**: User canceled or authentication failed

## Additional Notes
- The entitlements file at `Sunshade/Sunshade.entitlements` is already properly configured with the Sign In with Apple capability
- The bundle identifier `com.sunshade.app.Sunshade` matches what's expected
- The main issue is that Xcode doesn't know about the entitlements file (CODE_SIGN_ENTITLEMENTS is not set)

## Quick Fix Command (if you have xcodeproj gem):
```bash
# Install xcodeproj if needed
gem install xcodeproj

# Run this Ruby script to add entitlements
ruby -e "
require 'xcodeproj'
project = Xcodeproj::Project.open('Sunshade.xcodeproj')
target = project.targets.find { |t| t.name == 'Sunshade' }
target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Sunshade/Sunshade.entitlements'
end
project.save
puts 'Entitlements file linked successfully!'
"
```