import SwiftUI
import GoogleSignIn

struct AuthenticationTestView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showingMainApp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Google Authentication Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                if authManager.isAuthenticated {
                    VStack(spacing: 16) {
                        Text("✅ Authentication Successful!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User Details:")
                                .font(.headline)
                            
                            Text("Name: \(authManager.userDisplayName)")
                            Text("Email: \(authManager.userEmail)")
                            
                            if let imageURL = authManager.userProfileImageURL {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button("Sign Out") {
                            authManager.signOut()
                        }
                        .foregroundColor(.red)
                        
                        Button("Go to Main App") {
                            showingMainApp = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primary)
                        .cornerRadius(25)
                    }
                } else {
                    VStack(spacing: 16) {
                        if authManager.isLoading {
                            ProgressView("Signing in...")
                                .scaleEffect(1.2)
                        } else {
                            Button("Test Google Sign In") {
                                authManager.signIn()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.primary)
                            .cornerRadius(25)
                        }
                        
                        if let error = authManager.authError {
                            Text("❌ Error: \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Configuration Status:")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: configurationStatus.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(configurationStatus.isValid ? .green : .red)
                        Text(configurationStatus.message)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showingMainApp) {
            MainContentView()
        }
    }
    
    private var configurationStatus: (isValid: Bool, message: String) {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String,
              !clientId.isEmpty else {
            return (false, "GoogleService-Info.plist not found or invalid")
        }
        
        return (true, "Google Services configured correctly")
    }
}

#Preview {
    AuthenticationTestView()
}