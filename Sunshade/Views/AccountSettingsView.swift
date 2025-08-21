import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var userProfile = UserProfile.shared
    @State private var showingSkinTypeSelection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "gear")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Customize your app experience and preferences")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // User Settings Section
                    VStack(spacing: 16) {
                        SettingsSectionHeader(title: "User Settings", icon: "person")
                        
                        VStack(spacing: 12) {
                            NameSettingsItem(userProfile: userProfile)
                        }
                    }
                    
                    // Profile Settings Section
                    VStack(spacing: 16) {
                        SettingsSectionHeader(title: "Profile Settings", icon: "person.circle")
                        
                        VStack(spacing: 12) {
                            SettingsItem(
                                icon: "person.text.rectangle",
                                title: "Skin Type",
                                subtitle: userProfile.skinType.description,
                                action: {
                                    showingSkinTypeSelection = true
                                }
                            )
                            
                            SettingsItem(
                                icon: "calendar",
                                title: "Age Range",
                                subtitle: ageRangeText,
                                showPicker: true,
                                picker: AnyView(
                                    Picker("Age Range", selection: $userProfile.ageRange) {
                                        Text("Under 18").tag(AgeRange.child)
                                        Text("18-30").tag(AgeRange.youngAdult)
                                        Text("31-50").tag(AgeRange.adult)
                                        Text("51-65").tag(AgeRange.middleAge)
                                        Text("65+").tag(AgeRange.senior)
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(AppColors.primary)
                                )
                            )
                        }
                    }
                    
                    // Preferences Section
                    VStack(spacing: 16) {
                        SettingsSectionHeader(title: "Preferences", icon: "slider.horizontal.3")
                        
                        VStack(spacing: 12) {
                            SettingsItem(
                                icon: "thermometer",
                                title: "Temperature Unit",
                                subtitle: userProfile.temperatureUnit.displayName,
                                showPicker: true,
                                picker: AnyView(
                                    Picker("Temperature", selection: $userProfile.temperatureUnit) {
                                        Text("°F").tag(TemperatureUnit.fahrenheit)
                                        Text("°C").tag(TemperatureUnit.celsius)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 100)
                                )
                            )
                        }
                    }
                    
                    // App Information Section
                    VStack(spacing: 16) {
                        SettingsSectionHeader(title: "App Information", icon: "info.circle")
                        
                        VStack(spacing: 12) {
                            SettingsInfoItem(
                                title: "Version", 
                                value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                            )
                            SettingsInfoItem(
                                title: "Build", 
                                value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                            )
                            SettingsInfoItem(
                                title: "Compatibility",
                                value: "iOS 16.0+"
                            )
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.primary)
            )
        }
        .sheet(isPresented: $showingSkinTypeSelection) {
            SkinTypeSelectionView(selectedSkinType: $userProfile.skinType)
        }
    }
    
    private var ageRangeText: String {
        switch userProfile.ageRange {
        case .child: return "Under 18"
        case .youngAdult: return "18-30"
        case .adult: return "31-50"
        case .middleAge: return "51-65"
        case .senior: return "65+"
        }
    }
    
}

// Settings Item Component (similar to ContactItem in HelpSupportView)
struct SettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let showPicker: Bool
    let picker: AnyView?
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, showPicker: Bool = false, picker: AnyView? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showPicker = showPicker
        self.picker = picker
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                if showPicker, let picker = picker {
                    picker
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.textMuted)
                        .font(.system(size: 14))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil && !showPicker)
    }
}

// Settings Info Item Component 
struct SettingsInfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// Settings Section Header Component
struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

// Skin Type Selection View (keeping existing implementation)
struct SkinTypeSelectionView: View {
    @Binding var selectedSkinType: SkinType
    @Environment(\.presentationMode) var presentationMode
    @State private var tempSelection: SkinType
    
    init(selectedSkinType: Binding<SkinType>) {
        self._selectedSkinType = selectedSkinType
        self._tempSelection = State(initialValue: selectedSkinType.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Skin Type")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.bottom, 10)
                    
                    headerSection
                    skinTypeOptions
                }
                .padding()
            }
            .background(AppColors.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    selectedSkinType = tempSelection
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.primary)
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.primary)
            
            Text("Select Your Skin Type")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            Text("This helps us provide personalized UV safety recommendations")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var skinTypeOptions: some View {
        VStack(spacing: 12) {
            SkinTypeCard(type: .type1, description: "Very Fair", details: "Always burns, never tans", isSelected: tempSelection == .type1) {
                tempSelection = .type1
            }
            SkinTypeCard(type: .type2, description: "Fair", details: "Usually burns, tans minimally", isSelected: tempSelection == .type2) {
                tempSelection = .type2
            }
            SkinTypeCard(type: .type3, description: "Medium", details: "Sometimes burns, tans gradually", isSelected: tempSelection == .type3) {
                tempSelection = .type3
            }
            SkinTypeCard(type: .type4, description: "Olive", details: "Rarely burns, tans easily", isSelected: tempSelection == .type4) {
                tempSelection = .type4
            }
            SkinTypeCard(type: .type5, description: "Brown", details: "Very rarely burns, tans darkly", isSelected: tempSelection == .type5) {
                tempSelection = .type5
            }
            SkinTypeCard(type: .type6, description: "Black", details: "Never burns, always tans", isSelected: tempSelection == .type6) {
                tempSelection = .type6
            }
        }
    }
}

struct SkinTypeCard: View {
    let type: SkinType
    let description: String
    let details: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary : AppColors.backgroundSecondary)
                        .frame(width: 40, height: 40)
                    
                    Text("\(type.rawValue)")
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(description)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(details)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Name Settings Item Component
struct NameSettingsItem: View {
    @ObservedObject var userProfile: UserProfile
    @State private var showingNameInput = false
    @State private var tempName = ""
    
    var body: some View {
        Button(action: {
            tempName = userProfile.name
            showingNameInput = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Display Name")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(userProfile.name.isEmpty ? "Not set" : userProfile.name)
                        .font(.caption)
                        .foregroundColor(userProfile.name.isEmpty ? AppColors.textMuted : AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textMuted)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingNameInput) {
            NameInputSheet(
                name: $tempName,
                onSave: { name in
                    userProfile.name = name
                },
                onCancel: {
                    tempName = userProfile.name
                }
            )
        }
    }
}

// Name Input Sheet
struct NameInputSheet: View {
    @Binding var name: String
    let onSave: (String) -> Void
    let onCancel: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool
    
    private let maxNameLength = 50
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Set Your Name")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("This will be used in personalized greetings throughout the app")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    TextField("Enter your name (optional)", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onChange(of: name) {
                            // Truncate name if it exceeds maximum length
                            if name.count > maxNameLength {
                                name = String(name.prefix(maxNameLength))
                            }
                        }
                        .onSubmit {
                            saveAndDismiss()
                        }
                    
                    // Character counter
                    HStack {
                        Spacer()
                        Text("\(name.count)/\(maxNameLength)")
                            .font(.caption)
                            .foregroundColor(name.count > maxNameLength * 4/5 ? AppColors.primary : AppColors.textMuted)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveAndDismiss) {
                        Text("Save")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        onCancel()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func saveAndDismiss() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(trimmedName)
        presentationMode.wrappedValue.dismiss()
    }
}


#Preview {
    AccountSettingsView()
}