import SwiftUI
import AuthenticationServices

struct AuthenticationDebugView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var debugInfo: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Apple Sign-In Debug")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Current status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status Information:")
                        .font(.headline)
                    
                    StatusRow(title: "Authentication State", value: authManager.isAuthenticated ? "✅ Authenticated" : "❌ Not Authenticated")
                    StatusRow(title: "Loading State", value: authManager.isLoading ? "🔄 Loading" : "⏸️ Idle")
                    StatusRow(title: "Current User", value: authManager.currentUser?.displayName ?? "None")
                    StatusRow(title: "User Email", value: authManager.currentUser?.email ?? "None")
                    
                    if let error = authManager.authError {
                        StatusRow(title: "Error", value: "❌ \(error)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Capability Check
                VStack(alignment: .leading, spacing: 8) {
                    Text("System Requirements:")
                        .font(.headline)
                    
                    StatusRow(title: "iOS Version", value: capabilityCheck.iosVersion)
                    StatusRow(title: "Sign In with Apple", value: capabilityCheck.appleSignInAvailable)
                    StatusRow(title: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "Unknown")
                    StatusRow(title: "Device Type", value: capabilityCheck.deviceType)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Test buttons
                VStack(spacing: 12) {
                    Button("Test Apple Sign-In") {
                        testAppleSignIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(authManager.isLoading)
                    
                    Button("Simulate User Authentication") {
                        simulateAuthentication()
                    }
                    .buttonStyle(.bordered)
                    
                    if authManager.isAuthenticated {
                        Button("Sign Out") {
                            authManager.signOut()
                            debugInfo.append("✅ Sign out completed")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                    
                    Button("Clear Debug Log") {
                        debugInfo.removeAll()
                    }
                    .buttonStyle(.bordered)
                }
                
                // Debug log
                if !debugInfo.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Log:")
                            .font(.headline)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(debugInfo.indices, id: \.self) { index in
                                    Text(debugInfo[index])
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button("Continue to Main App") {
                    // This would transition to the main app
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.white)
            }
            .padding()
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func testAppleSignIn() {
        debugInfo.append("🔄 Starting Apple Sign-In test...")
        authManager.signInWithApple()
    }
    
    private func simulateAuthentication() {
        debugInfo.append("🎭 Simulating user authentication...")
        
        // Create a simulated user for testing
        let simulatedUser = AuthenticatedUser(
            id: "test-user-123",
            displayName: "Test User",
            email: "test@example.com",
            provider: .apple
        )
        
        // Directly set the user (for testing purposes only)
        authManager.currentUser = simulatedUser
        authManager.isAuthenticated = true
        authManager.authProvider = .apple
        
        debugInfo.append("✅ Simulated authentication successful")
        debugInfo.append("👤 User: \(simulatedUser.displayName)")
        debugInfo.append("📧 Email: \(simulatedUser.email)")
    }
    
    private var capabilityCheck: (iosVersion: String, appleSignInAvailable: String, deviceType: String) {
        let version = UIDevice.current.systemVersion
        let available = "Available" // Apple Sign-In is available on iOS 13+
        
        #if targetEnvironment(simulator)
        let deviceType = "📱 Simulator"
        #else
        let deviceType = "📱 Physical Device"
        #endif
        
        return (
            iosVersion: "iOS \(version)",
            appleSignInAvailable: "✅ \(available)",
            deviceType: deviceType
        )
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    AuthenticationDebugView()
}