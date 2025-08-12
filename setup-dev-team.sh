#!/bin/bash

# Sunshade Development Team Setup Script
# This script helps configure your Apple Developer Team ID for building the project

set -e

echo "🍎 Sunshade Development Team Setup"
echo "=================================="
echo

# Check if team ID is already set
if [ -n "$SUNSHADE_DEVELOPMENT_TEAM" ]; then
    echo "✅ Development team already set: $SUNSHADE_DEVELOPMENT_TEAM"
    echo
    read -p "Do you want to change it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing team ID: $SUNSHADE_DEVELOPMENT_TEAM"
        exit 0
    fi
fi

echo "To find your Team ID:"
echo "1. Open Xcode"
echo "2. Go to Xcode → Settings → Accounts"
echo "3. Select your Apple ID → Your development team"
echo "4. Copy the Team ID (10-character string like XXXXXXXXXX)"
echo

# Get team ID from user
while true; do
    read -p "Enter your Apple Developer Team ID: " team_id
    
    # Validate format (10 alphanumeric characters)
    if [[ $team_id =~ ^[A-Z0-9]{10}$ ]]; then
        break
    else
        echo "❌ Invalid format. Team ID should be 10 alphanumeric characters (e.g., 389Y5DY6GV)"
    fi
done

# Determine shell profile
if [ -n "$ZSH_VERSION" ]; then
    PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    PROFILE="$HOME/.bashrc"
else
    PROFILE="$HOME/.profile"
fi

# Add to shell profile
echo
echo "📝 Adding to shell profile: $PROFILE"

# Remove existing entry if present
if [ -f "$PROFILE" ]; then
    sed -i.bak '/export SUNSHADE_DEVELOPMENT_TEAM/d' "$PROFILE"
fi

# Add new entry
echo "export SUNSHADE_DEVELOPMENT_TEAM=\"$team_id\"" >> "$PROFILE"

# Set for current session
export SUNSHADE_DEVELOPMENT_TEAM="$team_id"

echo "✅ Development team configured: $team_id"
echo
echo "🔄 To apply the changes:"
echo "   source $PROFILE"
echo "   # OR restart your terminal"
echo
echo "🚀 You can now build the project:"
echo "   xcodebuild -project Sunshade.xcodeproj -scheme Sunshade build"
echo
echo "Note: You can also configure the team directly in Xcode if you prefer."