import SwiftUI

struct MainContentView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var userProfile = UserProfile.shared
    @State private var showDebugOptions = false
    @State private var showingSkinTypeOnboarding = false
    
    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Dashboard")
                }
            
            SafetyTimerView(dashboardViewModel: dashboardViewModel)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
            
            SimpleProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(AppColors.tabBarTint)
        .onAppear {
            // Check if we need to show skin type onboarding
            checkForSkinTypeOnboarding()
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

struct SimpleProfileView: View {
    @State private var showingPrivacySettings = false
    @State private var showingHelpSupport = false
    @State private var showingAccountSettings = false
    @StateObject private var userProfile = UserProfile.shared
    
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
                        
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .shadow(color: AppColors.shadowColor, radius: 4, x: 0, y: 2)
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text("User Profile")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Local Storage Only")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 4)
                
                // Profile Actions
                VStack(spacing: 12) {
                    ProfileActionRow(
                        icon: "gear",
                        title: "Settings",
                        subtitle: "Profile, Preferences & More",
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
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 4)
                
                Spacer()
            }
            .padding()
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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
    var subtitle: String? = nil
    var titleColor: Color = AppColors.textPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(titleColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
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