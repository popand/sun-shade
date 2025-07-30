import Foundation
import AuthenticationServices
import SwiftUI

enum AuthenticationProvider {
    case apple
    case none
}

@MainActor
class AuthenticationManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthenticatedUser?
    @Published var isLoading = false
    @Published var authError: String?
    @Published var authProvider: AuthenticationProvider = .none
    
    override init() {
        super.init()
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        // Check if user has existing Apple Sign-In credentials
        if let userID = UserDefaults.standard.string(forKey: "appleUserID") {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { [weak self] (credentialState, error) in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        // User is still authenticated
                        self?.restoreUserSession()
                    case .revoked, .notFound:
                        // User's credentials have been revoked or not found
                        self?.signOut()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func restoreUserSession() {
        guard let userData = UserDefaults.standard.data(forKey: "authenticatedUser"),
              let user = try? JSONDecoder().decode(AuthenticatedUser.self, from: userData) else {
            return
        }
        
        currentUser = user
        isAuthenticated = true
        authProvider = .apple
    }
    
    func signInWithApple() {
        isLoading = true
        authError = nil
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signOut() {
        // Clear stored user data
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "authenticatedUser")
        
        // Reset state
        isAuthenticated = false
        currentUser = nil
        authProvider = .none
        authError = nil
    }
    
    private func saveUserSession(_ user: AuthenticatedUser, userID: String) {
        // Save user ID for credential state checking
        UserDefaults.standard.set(userID, forKey: "appleUserID")
        
        // Save user data
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "authenticatedUser")
        }
    }
    
    var userDisplayName: String {
        return currentUser?.displayName ?? "User"
    }
    
    var userEmail: String {
        return currentUser?.email ?? ""
    }
    
    var userInitials: String {
        let name = userDisplayName
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let firstInitial = String(components[0].prefix(1))
            let lastInitial = String(components[1].prefix(1))
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else if !name.isEmpty {
            return String(name.prefix(1)).uppercased()
        }
        return "U"
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isLoading = false
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            
            // Get user information
            let firstName = appleIDCredential.fullName?.givenName ?? ""
            let lastName = appleIDCredential.fullName?.familyName ?? ""
            let email = appleIDCredential.email ?? ""
            
            // Create display name
            var displayName = ""
            if !firstName.isEmpty && !lastName.isEmpty {
                displayName = "\(firstName) \(lastName)"
            } else if !firstName.isEmpty {
                displayName = firstName
            } else if !lastName.isEmpty {
                displayName = lastName
            } else if !email.isEmpty {
                displayName = email.components(separatedBy: "@").first ?? "User"
            } else {
                displayName = "Apple User"
            }
            
            // Create authenticated user
            let user = AuthenticatedUser(
                id: userID,
                displayName: displayName,
                email: email,
                provider: .apple
            )
            
            // Save session and update state
            saveUserSession(user, userID: userID)
            currentUser = user
            isAuthenticated = true
            authProvider = .apple
            authError = nil
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false
        
        print("🔴 Apple Sign-In Error: \(error)")
        
        // Handle the error
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                self.authError = "Sign in was canceled by user"
                print("ℹ️ User canceled Apple Sign-In")
            case .failed:
                self.authError = "Sign in failed - check Apple Sign-In capability"
                print("❌ Apple Sign-In failed - capability may not be enabled")
            case .invalidResponse:
                self.authError = "Invalid response from Apple"
                print("❌ Invalid response from Apple servers")
            case .notHandled:
                self.authError = "Sign in not handled - configuration issue"
                print("❌ Sign-In not handled - check app configuration")
            case .unknown:
                self.authError = "Unknown error - check device settings"
                print("❌ Unknown Apple Sign-In error")
            @unknown default:
                self.authError = "Unexpected error occurred"
                print("❌ Unexpected Apple Sign-In error")
            }
        } else {
            self.authError = "Authentication error: \(error.localizedDescription)"
            print("❌ General authentication error: \(error)")
        }
        
        // Additional debugging for common issues
        if error.localizedDescription.contains("1000") {
            print("💡 Error 1000 usually means Apple Sign-In capability is not enabled")
            self.authError = "Apple Sign-In not configured. Enable 'Sign In with Apple' capability in Xcode."
        }
        
        if error.localizedDescription.contains("-7026") {
            print("💡 Error -7026 usually means Apple ID authentication issue")
            self.authError = "Apple ID authentication failed. Check device Apple ID settings."
        }
        
        if error.localizedDescription.contains("-7003") {
            print("💡 Error -7003 means Apple ID is not signed in or not verified")
            self.authError = "Apple ID not signed in. Please sign in to Apple ID in Settings."
        }
        
        if error.localizedDescription.contains("1001") {
            print("💡 Error 1001 means user canceled or Apple ID authentication failed")
            self.authError = "Authentication failed. Ensure you're signed in to Apple ID and try again."
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - AuthenticatedUser Model
struct AuthenticatedUser: Codable {
    let id: String
    let displayName: String
    let email: String
    let provider: AuthenticationProvider
}

extension AuthenticationProvider: Codable {}