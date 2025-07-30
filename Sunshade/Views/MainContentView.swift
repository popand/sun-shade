import SwiftUI

struct MainContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showingSignOut = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "sun.max.fill")
                            Text("Dashboard")
                        }
                    
                    SafetyTimerView()
                        .tabItem {
                            Image(systemName: "timer")
                            Text("Timer")
                        }
                    
                    AuthenticatedProfileView(authManager: authManager)
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                }
                .accentColor(AppColors.primary)
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authManager.checkAuthenticationStatus()
        }
    }
}

struct AuthenticatedProfileView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // User Profile Header
                VStack(spacing: 16) {
                    // Profile Image
                    AsyncImage(url: URL(string: authManager.userProfileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(authManager.userDisplayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(authManager.userEmail)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding()
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
                .padding()
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