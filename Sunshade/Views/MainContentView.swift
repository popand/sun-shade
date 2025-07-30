import SwiftUI

struct MainContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var showDebugOptions = false
    
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
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Update greeting when user becomes authenticated
                dashboardViewModel.updateGreetingForUser(authManager.userDisplayName)
            }
        }
    }
}

struct AuthenticatedProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSignOutAlert = false
    
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
                        icon: "gear",
                        title: "Account Settings",
                        action: { /* Settings */ }
                    )
                    
                    ProfileActionRow(
                        icon: "shield.checkerboard",
                        title: "Privacy Settings",
                        action: { /* Privacy */ }
                    )
                    
                    ProfileActionRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        action: { /* Help */ }
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
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
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