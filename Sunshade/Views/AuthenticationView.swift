import SwiftUI
import GoogleSignIn

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Welcome to Sunshade")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Your personal UV safety companion")
                        .font(.title3)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Sign In Section
                VStack(spacing: 20) {
                    Text("Sign in to sync your data across devices and access personalized recommendations")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    // Google Sign In Button
                    Button(action: {
                        authManager.signIn()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.title3)
                            
                            Text("Continue with Google")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primary)
                        .cornerRadius(25)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 30)
                    
                    // Continue without signing in
                    Button("Continue without signing in") {
                        // Skip authentication for now
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 10)
                }
                
                Spacer()
                
                // Error message
                if let error = authManager.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(AppColors.danger)
                        .padding(.horizontal, 30)
                        .multilineTextAlignment(.center)
                }
                
                // Loading indicator
                if authManager.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                }
                
                Spacer()
                
                // Privacy notice
                VStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    HStack(spacing: 4) {
                        Button("Terms of Service") {
                            // Show terms
                        }
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                        
                        Text("and")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                        
                        Button("Privacy Policy") {
                            // Show privacy policy
                        }
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(AppColors.backgroundPrimary)
        }
    }
}

#Preview {
    AuthenticationView()
}