import SwiftUI

/// Dynamic color system that adapts to light and dark mode
struct AppColors {
    // MARK: - Brand Colors (remain consistent)
    static let primary = Color(red: 1.0, green: 0.42, blue: 0.21) // #FF6B35
    static let secondary = Color(red: 0.0, green: 0.31, blue: 0.54) // #004E89
    static let accent = Color(red: 1.0, green: 0.82, blue: 0.25) // #FFD23F
    
    // MARK: - Semantic Colors (adapt to color scheme)
    static let success = Color(red: 0.16, green: 0.65, blue: 0.27) // #28A745
    static let warning = Color(red: 1.0, green: 0.76, blue: 0.03) // #FFC107
    static let danger = Color(red: 0.86, green: 0.20, blue: 0.27) // #DC3545
    static let info = Color(red: 0.09, green: 0.64, blue: 0.72) // #17A2B8
    
    // MARK: - Dynamic Background Colors
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let backgroundTertiary = Color("BackgroundTertiary")
    
    // MARK: - Dynamic Card Colors
    static let cardBackground = Color("CardBackground")
    static let cardBackgroundElevated = Color("CardBackgroundElevated")
    
    // MARK: - Dynamic Text Colors
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textMuted = Color("TextMuted")
    
    // MARK: - Dynamic Border and Divider Colors
    static let borderColor = Color("BorderColor")
    static let dividerColor = Color("DividerColor")
    
    // MARK: - Shadow Colors
    static let shadowColor = Color("ShadowColor")
    
    // MARK: - Tab Bar Colors
    static let tabBarBackground = Color("TabBarBackground")
    static let tabBarTint = primary
    static let tabBarUnselected = Color("TabBarUnselected")
}

// MARK: - Color Extensions for Dark Mode Support

extension Color {
    /// Initialize colors with light and dark mode variants
    init(_ name: String) {
        self = Color(name, bundle: nil)
    }
    
    /// Create dynamic colors programmatically
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Programmatic Dynamic Colors (Fallback)

extension AppColors {
    /// Fallback colors for when Asset Catalog colors are not available
    struct Fallback {
        static let backgroundPrimary = Color.dynamic(
            light: Color(red: 0.98, green: 0.98, blue: 0.99), // #FAFBFC
            dark: Color(red: 0.11, green: 0.11, blue: 0.12)   // #1C1C1E
        )
        
        static let backgroundSecondary = Color.dynamic(
            light: Color(red: 0.97, green: 0.98, blue: 0.98), // #F8F9FA
            dark: Color(red: 0.17, green: 0.17, blue: 0.18)   // #2C2C2E
        )
        
        static let backgroundTertiary = Color.dynamic(
            light: Color(red: 0.91, green: 0.93, blue: 0.94), // #E9ECEF
            dark: Color(red: 0.22, green: 0.22, blue: 0.23)   // #38383A
        )
        
        static let cardBackground = Color.dynamic(
            light: Color.white,
            dark: Color(red: 0.17, green: 0.17, blue: 0.18)   // #2C2C2E
        )
        
        static let cardBackgroundElevated = Color.dynamic(
            light: Color.white,
            dark: Color(red: 0.22, green: 0.22, blue: 0.23)   // #38383A
        )
        
        static let textPrimary = Color.dynamic(
            light: Color(red: 0.13, green: 0.15, blue: 0.16), // #212529
            dark: Color(red: 0.92, green: 0.92, blue: 0.96)   // #EBEBF5
        )
        
        static let textSecondary = Color.dynamic(
            light: Color(red: 0.42, green: 0.46, blue: 0.51), // #6C757D
            dark: Color(red: 0.64, green: 0.64, blue: 0.68)   // #A3A3A8
        )
        
        static let textMuted = Color.dynamic(
            light: Color(red: 0.68, green: 0.71, blue: 0.74), // #ADB5BD
            dark: Color(red: 0.48, green: 0.48, blue: 0.50)   // #7A7A7E
        )
        
        static let borderColor = Color.dynamic(
            light: Color(red: 0.86, green: 0.86, blue: 0.86), // #DBDBDB
            dark: Color(red: 0.30, green: 0.30, blue: 0.31)   // #4D4D4F
        )
        
        static let dividerColor = Color.dynamic(
            light: Color(red: 0.91, green: 0.91, blue: 0.91), // #E8E8E8
            dark: Color(red: 0.25, green: 0.25, blue: 0.26)   // #404042
        )
        
        static let shadowColor = Color.dynamic(
            light: Color.black.opacity(0.1),
            dark: Color.black.opacity(0.3)
        )
        
        static let tabBarBackground = Color.dynamic(
            light: Color(red: 0.97, green: 0.97, blue: 0.97), // #F7F7F7
            dark: Color(red: 0.11, green: 0.11, blue: 0.12)   // #1C1C1E
        )
        
        static let tabBarUnselected = Color.dynamic(
            light: Color(red: 0.58, green: 0.58, blue: 0.58), // #949494
            dark: Color(red: 0.48, green: 0.48, blue: 0.50)   // #7A7A7E
        )
    }
}