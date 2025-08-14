import SwiftUI

struct NameInputView: View {
    @Binding var displayName: String
    let isPromptedBySystem: Bool
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var localName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primary)
                    
                    VStack(spacing: 8) {
                        Text("Set Your Name")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(isPromptedBySystem ? 
                             "We couldn't get your name from Apple. Please enter how you'd like to be addressed in the app." :
                             "Enter how you'd like to be addressed in the app.")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    TextField("Enter your name", text: $localName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            saveIfValid()
                        }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: saveIfValid) {
                        Text("Save")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                localName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                Color.gray : AppColors.primary
                            )
                            .cornerRadius(12)
                    }
                    .disabled(localName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            localName = displayName
            isTextFieldFocused = true
        }
    }
    
    private func saveIfValid() {
        let trimmedName = localName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            onSave(trimmedName)
        }
    }
}

struct MainContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var userProfile = UserProfile.shared
    @State private var showDebugOptions = false
    @State private var showingSkinTypeOnboarding = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView {
                    DashboardView(viewModel: dashboardViewModel)
                        .environmentObject(authManager)
                        .tabItem {
                            Image(systemName: "sun.max.fill")
                            Text("Dashboard")
                        }
                    
                    SafetyTimerView(dashboardViewModel: dashboardViewModel)
                        .tabItem {
                            Image(systemName: "timer")
                            Text("Timer")
                        }
                    
                    AuthenticatedProfileView()
                        .environmentObject(authManager)
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                }
                .accentColor(AppColors.primary)
            } else {
                AuthenticationView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            authManager.checkAuthenticationStatus()
            
            // Initialize greeting with authenticated user if already signed in
            if authManager.isAuthenticated {
                dashboardViewModel.updateGreetingForUser(authManager.userDisplayName)
                
                // Check if we need to show skin type onboarding
                checkForSkinTypeOnboarding()
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Update greeting when user becomes authenticated
                dashboardViewModel.updateGreetingForUser(authManager.userDisplayName)
                
                // Check for skin type onboarding when user signs in
                checkForSkinTypeOnboarding()
            } else {
                // Clear authenticated user data when user signs out
                dashboardViewModel.clearAuthenticatedUser()
            }
        }
        .onChange(of: authManager.currentUser?.displayName) { displayName in
            if let displayName = displayName, authManager.isAuthenticated {
                // Update greeting when user changes their display name
                dashboardViewModel.updateGreetingForUser(displayName)
            }
        }
        .sheet(isPresented: $showingSkinTypeOnboarding) {
            SkinTypeOnboardingView()
        }
    }
    
    private func checkForSkinTypeOnboarding() {
        // Show skin type onboarding if user hasn't completed it
        if !userProfile.hasCompletedSkinTypeOnboarding {
            // Add a small delay to let the main UI load first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingSkinTypeOnboarding = true
            }
        }
    }
}

struct AuthenticatedProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSignOutAlert = false
    @State private var showingAccountSettings = false
    @State private var showingPrivacySettings = false
    @State private var showingHelpSupport = false
    @State private var showingNamePrompt = false
    @State private var newDisplayName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // User Profile Header
                VStack(spacing: 16) {
                    // Profile Image/Initials
                    ZStack {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 80, height: 80)
                        
                        Text(authManager.userInitials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(authManager.userDisplayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if !authManager.userEmail.isEmpty {
                            Text(authManager.userEmail)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "applelogo")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Signed in with Apple")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                // Account Actions
                VStack(spacing: 12) {
                    ProfileActionRow(
                        icon: "pencil",
                        title: "Edit Display Name",
                        action: { 
                            newDisplayName = authManager.userDisplayName
                            showingNamePrompt = true 
                        }
                    )
                    
                    ProfileActionRow(
                        icon: "gear",
                        title: "Account Settings",
                        action: { showingAccountSettings = true }
                    )
                    
                    ProfileActionRow(
                        icon: "shield.checkerboard",
                        title: "Privacy Notice",
                        action: { showingPrivacySettings = true }
                    )
                    
                    ProfileActionRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        action: { showingHelpSupport = true }
                    )
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    ProfileActionRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Sign Out",
                        titleColor: AppColors.danger,
                        action: { showingSignOutAlert = true }
                    )
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                Spacer()
            }
            .padding()
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            // Check if we need to prompt for name
            if authManager.shouldPromptForName {
                showingNamePrompt = true
                newDisplayName = ""
            }
        }
        .sheet(isPresented: $showingNamePrompt) {
            NameInputView(
                displayName: $newDisplayName,
                isPromptedBySystem: authManager.shouldPromptForName,
                onSave: { name in
                    authManager.updateDisplayName(name)
                    showingNamePrompt = false
                },
                onCancel: {
                    newDisplayName = ""
                    showingNamePrompt = false
                }
            )
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView()
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacyNoticeView()
        }
        .sheet(isPresented: $showingHelpSupport) {
            HelpSupportView()
        }
    }
}

struct ProfileActionRow: View {
    let icon: String
    let title: String
    var titleColor: Color = AppColors.textPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(titleColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    MainContentView()
}