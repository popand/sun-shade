import SwiftUI

/// Onboarding view to collect user's skin type for safety recommendations
struct SkinTypeOnboardingView: View {
    @ObservedObject private var userProfile = UserProfile.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSkinType: SkinType = .type1
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 8) {
                            Text("What's Your Skin Type?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Help us provide personalized sun safety recommendations based on your Fitzpatrick Skin Type.")
                                .font(.body)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Safety Notice
                    HStack(spacing: 12) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(AppColors.primary)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Safety First")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("We start with the most protective recommendations. Choose your actual skin type for accurate guidance.")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Skin Type Selection
                    VStack(spacing: 16) {
                        Text("Select Your Skin Type")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(spacing: 12) {
                            ForEach(SkinType.allCases, id: \.self) { skinType in
                                OnboardingSkinTypeRow(
                                    skinType: skinType,
                                    isSelected: selectedSkinType == skinType,
                                    action: {
                                        selectedSkinType = skinType
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Continue Button
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.bottom, 32)
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Confirm Your Skin Type", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                userProfile.skinType = selectedSkinType
                userProfile.hasCompletedSkinTypeOnboarding = true
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You selected Type \(selectedSkinType.rawValue) - \(selectedSkinType.description). This will be used to provide personalized sun safety recommendations.")
        }
    }
}

// MARK: - Onboarding Skin Type Row

struct OnboardingSkinTypeRow: View {
    let skinType: SkinType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // Skin tone indicator
                    Circle()
                        .fill(skinTypeColor)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 3)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Type \(skinType.rawValue)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(skinType.description)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text(detailedDescription)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: 16) {
                            Label("Burns in \(skinType.baseProtectionTime) min", systemImage: "flame")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Label(safetyLevel, systemImage: safetyIcon)
                                .font(.caption)
                                .foregroundColor(safetyColor)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.primary)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(AppColors.textMuted)
                            .font(.title2)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var skinTypeColor: Color {
        switch skinType {
        case .type1: return Color(red: 0.98, green: 0.89, blue: 0.80)
        case .type2: return Color(red: 0.96, green: 0.82, blue: 0.69)
        case .type3: return Color(red: 0.87, green: 0.72, blue: 0.53)
        case .type4: return Color(red: 0.76, green: 0.60, blue: 0.42)
        case .type5: return Color(red: 0.55, green: 0.42, blue: 0.29)
        case .type6: return Color(red: 0.35, green: 0.25, blue: 0.18)
        }
    }
    
    private var detailedDescription: String {
        switch skinType {
        case .type1: 
            return "Always burns, never tans. Very fair skin with freckles, red or blonde hair, blue/green eyes."
        case .type2: 
            return "Usually burns, tans minimally. Fair skin, light hair, blue/hazel/green eyes."
        case .type3: 
            return "Sometimes burns, tans gradually. Medium skin tone, any hair/eye color."
        case .type4: 
            return "Rarely burns, tans easily. Light brown/olive skin, dark hair/eyes."
        case .type5: 
            return "Very rarely burns, tans darkly. Brown skin, dark hair/eyes."
        case .type6: 
            return "Never burns, tans very darkly. Black skin, dark hair/eyes."
        }
    }
    
    private var safetyLevel: String {
        switch skinType {
        case .type1, .type2: return "High Risk"
        case .type3, .type4: return "Medium Risk"
        case .type5, .type6: return "Lower Risk"
        }
    }
    
    private var safetyIcon: String {
        switch skinType {
        case .type1, .type2: return "exclamationmark.triangle"
        case .type3, .type4: return "exclamationmark.circle"
        case .type5, .type6: return "checkmark.circle"
        }
    }
    
    private var safetyColor: Color {
        switch skinType {
        case .type1, .type2: return .red
        case .type3, .type4: return .orange
        case .type5, .type6: return .green
        }
    }
}

#Preview {
    SkinTypeOnboardingView()
}