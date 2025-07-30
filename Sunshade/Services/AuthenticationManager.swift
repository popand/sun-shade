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
        
        // Handle the error
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                self.authError = "Sign in was canceled"
            case .failed:
                self.authError = "Sign in failed"
            case .invalidResponse:
                self.authError = "Invalid response from Apple"
            case .notHandled:
                self.authError = "Sign in not handled"
            case .unknown:
                self.authError = "Unknown error occurred"
            @unknown default:
                self.authError = "Unexpected error occurred"
            }
        } else {
            self.authError = error.localizedDescription
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