import SwiftUI

struct AccountSettingsView: View {
    @ObservedObject private var userProfile = UserProfile.shared
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSkinTypeOnboarding = false
    @State private var showingNameEdit = false
    @State private var editingName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Safety Warning Section
                    if let warning = userProfile.safetyWarning {
                        SafetyWarningBanner(message: warning)
                    }
                    
                    // Display Name Section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(AppColors.primary)
                                .font(.title3)
                            
                            Text("Display Name")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                editingName = authManager.userDisplayName
                                showingNameEdit = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(AppColors.primary)
                                    
                                    Text("Edit")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.primary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        HStack {
                            Text(authManager.userDisplayName)
                                .font(.body)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 2)
                    
                    // Skin Type Section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(AppColors.primary)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Skin Type")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Fitzpatrick Skin Type Scale")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if !userProfile.hasCompletedSkinTypeOnboarding {
                                Button(action: {
                                    showingSkinTypeOnboarding = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        
                                        Text("Setup")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(SkinType.allCases, id: \.self) { skinType in
                                SkinTypeRow(
                                    skinType: skinType,
                                    isSelected: userProfile.skinType == skinType,
                                    action: {
                                        userProfile.skinType = skinType
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 2)
                    
                    // Age Range Section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(AppColors.primary)
                                .font(.title3)
                            
                            Text("Age Range")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(AgeRange.allCases, id: \.self) { ageRange in
                                AgeRangeRow(
                                    ageRange: ageRange,
                                    isSelected: userProfile.ageRange == ageRange,
                                    action: {
                                        userProfile.ageRange = ageRange
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 2)
                    
                    // Medical Information Section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "pills")
                                .foregroundColor(AppColors.primary)
                                .font(.title3)
                            
                            Text("Medical Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            Toggle(isOn: $userProfile.photosensitiveMedications) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Photosensitive Medications")
                                        .font(.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Taking medications that increase sun sensitivity")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .tint(AppColors.primary)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 2)
                    
                    // Temperature Unit Section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(AppColors.primary)
                                .font(.title3)
                            
                            Text("Temperature Unit")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                                TemperatureUnitRow(
                                    unit: unit,
                                    isSelected: userProfile.temperatureUnit == unit,
                                    action: {
                                        userProfile.temperatureUnit = unit
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 2)
                }
            }
            .padding()
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Account Settings")
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.primary)
            )
            .onAppear {
                // Check if we need to prompt for name when settings open
                if authManager.shouldPromptForName {
                    editingName = ""
                    showingNameEdit = true
                }
            }
            .sheet(isPresented: $showingSkinTypeOnboarding) {
                SkinTypeOnboardingView()
            }
            .sheet(isPresented: $showingNameEdit) {
                NameInputView(
                    displayName: $editingName,
                    isPromptedBySystem: authManager.shouldPromptForName,
                    onSave: { name in
                        authManager.updateDisplayName(name)
                        showingNameEdit = false
                    },
                    onCancel: {
                        editingName = ""
                        showingNameEdit = false
                    }
                )
            }
        }
    }
}

struct TemperatureUnitRow: View {
    let unit: TemperatureUnit
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: unit == .celsius ? "c.circle" : "f.circle")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                Text(unit.displayName)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Safety Warning Banner

struct SafetyWarningBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Skin Type Row

struct SkinTypeRow: View {
    let skinType: SkinType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(skinTypeColor)
                        .frame(width: 20, height: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Type \(skinType.rawValue)")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(skinType.description)
                                .font(.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text(skinTypeDescription)
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppColors.primary)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
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
    
    private var skinTypeDescription: String {
        switch skinType {
        case .type1: return "Always burns, never tans. Red/blonde hair, blue eyes."
        case .type2: return "Usually burns, tans minimally. Fair skin, light eyes."
        case .type3: return "Sometimes burns, tans gradually. Medium skin tone."
        case .type4: return "Rarely burns, tans easily. Olive skin, dark hair."
        case .type5: return "Very rarely burns, tans darkly. Brown skin."
        case .type6: return "Never burns, tans very darkly. Black skin."
        }
    }
}

// MARK: - Age Range Row

struct AgeRangeRow: View {
    let ageRange: AgeRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: ageRangeIcon)
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ageRangeDisplayName)
                        .font(.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if ageRange.needsExtraProtection {
                        Text("Requires extra sun protection")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var ageRangeDisplayName: String {
        switch ageRange {
        case .child: return "Child (Under 18)"
        case .youngAdult: return "Young Adult (18-30)"
        case .adult: return "Adult (31-50)"
        case .middleAge: return "Middle Age (51-65)"
        case .senior: return "Senior (65+)"
        }
    }
    
    private var ageRangeIcon: String {
        switch ageRange {
        case .child: return "person.crop.circle"
        case .youngAdult: return "person.crop.circle.fill"
        case .adult: return "person.crop.square"
        case .middleAge: return "person.crop.square.fill"
        case .senior: return "person.crop.artframe"
        }
    }
}

#Preview {
    AccountSettingsView()
}