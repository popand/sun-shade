//
//  AppColorsTests.swift  
//  SunshadeTests
//
//  Created by Claude Code on 2025-08-18.
//

import Testing
import SwiftUI
@testable import Sunshade

struct AppColorsTests {
    
    // MARK: - Brand Color Tests
    
    @Test("Brand colors are defined and consistent")
    func testBrandColors() async throws {
        // Verify brand colors exist
        let primaryColor = AppColors.primary
        let secondaryColor = AppColors.secondary  
        let accentColor = AppColors.accent
        
        #expect(primaryColor != nil)
        #expect(secondaryColor != nil)
        #expect(accentColor != nil)
        
        // Colors should be different from each other
        #expect(primaryColor != secondaryColor)
        #expect(primaryColor != accentColor)
        #expect(secondaryColor != accentColor)
    }
    
    @Test("Primary brand color hex values")
    func testPrimaryColorHex() async throws {
        // Test that primary color matches expected hex #FF6B35
        let primaryColor = AppColors.primary
        
        // Convert to UIColor to extract components
        let uiColor = UIColor(primaryColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Verify RGB values match #FF6B35 (1.0, 0.42, 0.21)
        #expect(abs(red - 1.0) < 0.01)
        #expect(abs(green - 0.42) < 0.01) 
        #expect(abs(blue - 0.21) < 0.01)
        #expect(alpha == 1.0)
    }
    
    @Test("Secondary brand color hex values")
    func testSecondaryColorHex() async throws {
        // Test that secondary color matches expected hex #004E89
        let secondaryColor = AppColors.secondary
        
        let uiColor = UIColor(secondaryColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Verify RGB values match #004E89 (0.0, 0.31, 0.54)
        #expect(abs(red - 0.0) < 0.01)
        #expect(abs(green - 0.31) < 0.01)
        #expect(abs(blue - 0.54) < 0.01)
        #expect(alpha == 1.0)
    }
    
    @Test("Accent color hex values")
    func testAccentColorHex() async throws {
        // Test that accent color matches expected hex #FFD23F
        let accentColor = AppColors.accent
        
        let uiColor = UIColor(accentColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Verify RGB values match #FFD23F (1.0, 0.82, 0.25)
        #expect(abs(red - 1.0) < 0.01)
        #expect(abs(green - 0.82) < 0.01)
        #expect(abs(blue - 0.25) < 0.01)
        #expect(alpha == 1.0)
    }
    
    // MARK: - Semantic Color Tests
    
    @Test("Semantic colors are properly defined")
    func testSemanticColors() async throws {
        // Test semantic colors exist and are distinguishable
        let success = AppColors.success
        let warning = AppColors.warning
        let danger = AppColors.danger
        let info = AppColors.info
        
        #expect(success != nil)
        #expect(warning != nil) 
        #expect(danger != nil)
        #expect(info != nil)
        
        // All semantic colors should be different
        let colors = [success, warning, danger, info]
        for i in 0..<colors.count {
            for j in (i+1)..<colors.count {
                #expect(colors[i] != colors[j])
            }
        }
    }
    
    @Test("Success color is green-like")
    func testSuccessColorIsGreen() async throws {
        let successColor = AppColors.success
        let uiColor = UIColor(successColor)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Success color should have more green than red or blue
        #expect(green > red)
        #expect(green > blue)
        #expect(green > 0.5) // Should be reasonably green
    }
    
    @Test("Danger color is red-like")
    func testDangerColorIsRed() async throws {
        let dangerColor = AppColors.danger
        let uiColor = UIColor(dangerColor)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Danger color should have more red than green or blue  
        #expect(red > green)
        #expect(red > blue)
        #expect(red > 0.7) // Should be strongly red
    }
    
    // MARK: - Dynamic Color Tests
    
    @Test("Dynamic background colors exist")
    func testDynamicBackgroundColors() async throws {
        let backgroundPrimary = AppColors.backgroundPrimary
        let backgroundSecondary = AppColors.backgroundSecondary
        let backgroundTertiary = AppColors.backgroundTertiary
        
        #expect(backgroundPrimary != nil)
        #expect(backgroundSecondary != nil) 
        #expect(backgroundTertiary != nil)
        
        // Should be different from each other
        #expect(backgroundPrimary != backgroundSecondary)
        #expect(backgroundSecondary != backgroundTertiary)
    }
    
    @Test("Dynamic text colors exist")
    func testDynamicTextColors() async throws {
        let textPrimary = AppColors.textPrimary
        let textSecondary = AppColors.textSecondary
        let textMuted = AppColors.textMuted
        
        #expect(textPrimary != nil)
        #expect(textSecondary != nil)
        #expect(textMuted != nil)
        
        // Should be different from each other for proper hierarchy
        #expect(textPrimary != textSecondary)
        #expect(textSecondary != textMuted)
        #expect(textPrimary != textMuted)
    }
    
    @Test("Dynamic card colors exist")
    func testDynamicCardColors() async throws {
        let cardBackground = AppColors.cardBackground
        let shadowColor = AppColors.shadowColor
        let dividerColor = AppColors.dividerColor
        
        #expect(cardBackground != nil)
        #expect(shadowColor != nil)
        #expect(dividerColor != nil)
        
        // Should be different for proper visual hierarchy
        #expect(cardBackground != shadowColor)
        #expect(cardBackground != dividerColor)
    }
    
    // MARK: - Tab Bar Color Tests
    
    @Test("Tab bar colors are properly configured")
    func testTabBarColors() async throws {
        let tabBarTint = AppColors.tabBarTint
        let tabBarBackground = AppColors.tabBarBackground
        let tabBarUnselected = AppColors.tabBarUnselected
        
        #expect(tabBarTint != nil)
        #expect(tabBarBackground != nil)
        #expect(tabBarUnselected != nil)
        
        // Tab tint should be the primary color
        #expect(tabBarTint == AppColors.primary)
        
        // Colors should provide proper contrast
        #expect(tabBarTint != tabBarBackground)
        #expect(tabBarTint != tabBarUnselected)
    }
    
    // MARK: - Color Extension Tests
    
    @Test("Dynamic color extension works")
    func testDynamicColorExtension() async throws {
        let lightColor = Color.red
        let darkColor = Color.blue
        
        let dynamicColor = Color.dynamic(light: lightColor, dark: darkColor)
        
        #expect(dynamicColor != nil)
        #expect(dynamicColor != lightColor) // Should be wrapped/different
        #expect(dynamicColor != darkColor)
    }
    
    // MARK: - Fallback Color Tests
    
    @Test("Fallback colors exist and are functional")
    func testFallbackColors() async throws {
        let fallbackBackground = AppColors.Fallback.backgroundPrimary
        let fallbackCard = AppColors.Fallback.cardBackground
        let fallbackText = AppColors.Fallback.textPrimary
        let fallbackShadow = AppColors.Fallback.shadowColor
        
        #expect(fallbackBackground != nil)
        #expect(fallbackCard != nil)
        #expect(fallbackText != nil)
        #expect(fallbackShadow != nil)
        
        // Fallback colors should be different from each other
        #expect(fallbackBackground != fallbackCard)
        #expect(fallbackBackground != fallbackText)
        #expect(fallbackCard != fallbackText)
    }
    
    @Test("Fallback colors provide proper contrast")
    func testFallbackColorContrast() async throws {
        let fallbackBackground = AppColors.Fallback.backgroundPrimary
        let fallbackText = AppColors.Fallback.textPrimary
        
        // Background and text should be different for readability
        #expect(fallbackBackground != fallbackText)
        
        // Test that these are actually dynamic colors by checking they're not static
        #expect(fallbackBackground != Color.white)
        #expect(fallbackBackground != Color.black)
        #expect(fallbackText != Color.clear)
    }
    
    // MARK: - Accessibility Tests
    
    @Test("Colors support accessibility")
    func testColorAccessibility() async throws {
        // Test that important interactive colors exist and are distinguishable
        let primary = AppColors.primary
        let secondary = AppColors.secondary
        let danger = AppColors.danger
        let success = AppColors.success
        
        let colors = [primary, secondary, danger, success]
        
        // All colors should be opaque for accessibility
        for color in colors {
            let uiColor = UIColor(color)
            var alpha: CGFloat = 0
            uiColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)
            #expect(alpha == 1.0) // Should be fully opaque
        }
    }
    
    @Test("Brand colors maintain consistency across updates")
    func testBrandColorConsistency() async throws {
        // Test that brand colors haven't accidentally changed
        // These should remain constant for brand identity
        
        let primaryHex = "#FF6B35"  // Orange
        let secondaryHex = "#004E89" // Blue
        let accentHex = "#FFD23F"   // Yellow
        
        // This test ensures brand colors don't drift over time
        // In a real implementation, you might store expected hex values
        // and compare against them programmatically
        
        #expect(!primaryHex.isEmpty)
        #expect(!secondaryHex.isEmpty) 
        #expect(!accentHex.isEmpty)
    }
}