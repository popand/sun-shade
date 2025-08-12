import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image("SunshadeLogoNew")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
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
                    
                    // Apple Sign In Button
                    Button(action: {
                        authManager.signInWithApple()
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("Sign in with Apple")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 30)
                    
                    // Continue without signing in
                    Button("Continue without signing in") {
                        // Skip authentication for now - can be implemented later
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
                        .padding()
                        .background(AppColors.danger.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Loading indicator
                if authManager.isLoading {
                    ProgressView("Signing in...")
                        .scaleEffect(1.2)
                        .padding()
                }
                
                Spacer()
                
                // Privacy notice
                VStack(spacing: 8) {
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
        .environmentObject(AuthenticationManager())
}