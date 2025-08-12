import Foundation
import AuthenticationServices
import SwiftUI
import Contacts

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
    @Published var shouldPromptForName = false
    
    private let keychainService = KeychainService.shared
    
    override init() {
        super.init()
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        // Check if user has existing Apple Sign-In credentials
        do {
            let userID = try keychainService.loadAppleUserID()
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
        } catch {
            // No stored credentials or keychain error
            print("ℹ️ No stored Apple Sign-In credentials: \(error.localizedDescription)")
        }
    }
    
    private func restoreUserSession() {
        do {
            let user = try keychainService.loadAuthenticatedUser()
            currentUser = user
            isAuthenticated = true
            authProvider = .apple
            print("✅ Restored user session from Keychain: \(user.displayName)")
        } catch {
            print("⚠️ Failed to restore user session from Keychain: \(error.localizedDescription)")
            // Clear any partial/corrupted data
            keychainService.clearAllAuthenticationData()
        }
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
        // Clear stored user data from Keychain
        keychainService.clearAllAuthenticationData()
        
        // Reset state
        isAuthenticated = false
        currentUser = nil
        authProvider = .none
        authError = nil
        
        print("🔐 User signed out - cleared all authentication data from Keychain")
    }
    
    private func saveUserSession(_ user: AuthenticatedUser, userID: String) throws {
        do {
            // Save user ID for credential state checking
            try keychainService.saveAppleUserID(userID)
            
            // Save user data
            try keychainService.saveAuthenticatedUser(user)
            
            print("🔐 Saved user session to Keychain: \(user.displayName)")
        } catch {
            print("❌ Failed to save user session to Keychain: \(error.localizedDescription)")
            
            // Clean up any partial keychain data to prevent inconsistent state
            keychainService.clearAllAuthenticationData()
            
            // Re-throw the error so the caller can handle authentication state properly
            throw error
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
    
    // Allow user to update their display name
    func updateDisplayName(_ newName: String) {
        guard var user = currentUser else { return }
        
        user = AuthenticatedUser(
            id: user.id,
            displayName: newName,
            email: user.email,
            provider: user.provider
        )
        
        do {
            try keychainService.saveAuthenticatedUser(user)
            currentUser = user
            shouldPromptForName = false // Clear the prompt flag
            print("✅ Updated display name to: \(newName)")
        } catch {
            print("❌ Failed to update display name: \(error.localizedDescription)")
            authError = "Failed to update display name. Please try again."
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isLoading = false
        shouldPromptForName = false // Reset prompt flag at start of authentication
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            
            // Get user information from Apple
            let fullNameComponents = appleIDCredential.fullName
            let firstName = fullNameComponents?.givenName ?? ""
            let lastName = fullNameComponents?.familyName ?? ""
            let email = appleIDCredential.email ?? ""
            
            print("🔍 Apple Sign-In Debug Info:")
            print("   User ID: \(userID)")
            print("   FullName Object: \(String(describing: fullNameComponents))")
            
            // Additional debugging for name components
            if let nameComponents = fullNameComponents {
                print("   Name Components Details:")
                print("     - givenName: '\(nameComponents.givenName ?? "nil")'")
                print("     - familyName: '\(nameComponents.familyName ?? "nil")'")
                print("     - middleName: '\(nameComponents.middleName ?? "nil")'")
                print("     - namePrefix: '\(nameComponents.namePrefix ?? "nil")'")
                print("     - nameSuffix: '\(nameComponents.nameSuffix ?? "nil")'")
                print("     - nickname: '\(nameComponents.nickname ?? "nil")'")
                
                // Try to get formatted name
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .default
                let formattedName = formatter.string(from: nameComponents)
                print("     - Formatted Name: '\(formattedName)'")
            } else {
                print("   ⚠️ FullName is nil - Apple didn't provide name components")
            }
            
            print("   Extracted Values:")
            print("     - First Name: '\(firstName)' (isEmpty: \(firstName.isEmpty))")
            print("     - Last Name: '\(lastName)' (isEmpty: \(lastName.isEmpty))")
            print("     - Email: '\(email)' (isEmpty: \(email.isEmpty))")
            print("   State: \(appleIDCredential.state ?? "nil")")
            print("   AuthorizationCode: \(appleIDCredential.authorizationCode != nil ? "present" : "nil")")
            
            // Try to load existing user data for this user ID (only for email fallback, not for name)
            var existingUser: AuthenticatedUser?
            do {
                let loadedUser = try keychainService.loadAuthenticatedUser()
                print("   Found existing user: '\(loadedUser.displayName)' (\(loadedUser.email))")
                // Important: Only use existing data for email, always prefer fresh name from Apple
                if loadedUser.id == userID {
                    print("   ✅ Same user re-authenticating")
                    existingUser = loadedUser
                } else {
                    print("   ⚠️ Different user - not using existing data")
                    existingUser = nil // Don't use data from different user
                }
            } catch {
                print("ℹ️ No existing user data found: \(error.localizedDescription)")
            }
            
            // Create display name with improved fallback logic
            var displayName = ""
            
            print("🔍 Display Name Resolution:")
            print("   Available data check:")
            print("     - firstName.isEmpty: \(firstName.isEmpty)")
            print("     - lastName.isEmpty: \(lastName.isEmpty)")
            print("     - email.isEmpty: \(email.isEmpty)")
            print("     - existingUser: \(existingUser != nil ? "exists" : "nil")")
            
            // First priority: Use new name information from Apple (first-time sign in)
            if !firstName.isEmpty && !lastName.isEmpty {
                displayName = "\(firstName) \(lastName)"
                print("   ✅ Using full name from Apple: '\(displayName)'")
            } else if !firstName.isEmpty {
                displayName = firstName
                print("   ✅ Using first name from Apple: '\(displayName)'")
            } else if !lastName.isEmpty {
                displayName = lastName
                print("   ✅ Using last name from Apple: '\(displayName)'")
            } else if let nameComponents = fullNameComponents {
                // Try using PersonNameComponentsFormatter as fallback
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .default
                let formattedName = formatter.string(from: nameComponents)
                if !formattedName.isEmpty {
                    displayName = formattedName
                    print("   ✅ Using formatted name from PersonNameComponentsFormatter: '\(displayName)'")
                } else {
                    displayName = "Apple User"
                    print("   ⚠️ PersonNameComponentsFormatter returned empty string")
                    shouldPromptForName = true
                }
            } else if !email.isEmpty {
                displayName = email.components(separatedBy: "@").first ?? "User"
                print("   ✅ Using email username: '\(displayName)'")
            } else if let existingUser = existingUser, !existingUser.displayName.isEmpty && existingUser.displayName != "Apple User" {
                // Second priority: Use previously stored display name if available
                displayName = existingUser.displayName
                print("   ✅ Using stored display name: '\(displayName)'")
            } else {
                // Last resort: Generic fallback
                displayName = "Apple User"
                print("   ⚠️ Falling back to: '\(displayName)' - will prompt user to set name")
                print("   🔍 Apple Sign-In Privacy Behavior:")
                print("      - This is normal for development builds or repeat sign-ins")
                print("      - Apple only provides name/email on first authorization per privacy policy")
                print("      - Production apps typically receive more complete data")
                print("      - User will be prompted to enter their preferred name")
                // Set flag to prompt user for their preferred name
                shouldPromptForName = true
            }
            
            // Use existing email if new one is not provided (Apple privacy feature)
            let finalEmail = !email.isEmpty ? email : (existingUser?.email ?? "")
            
            // Create authenticated user
            let user = AuthenticatedUser(
                id: userID,
                displayName: displayName,
                email: finalEmail,
                provider: .apple
            )
            
            print("🔐 Created user: \(displayName) (\(finalEmail.isEmpty ? "no email" : finalEmail))")
            print("🔐 About to save user to Keychain with name: '\(user.displayName)'")
            
            // Save session and update state - only set authenticated state if keychain save succeeds
            do {
                try saveUserSession(user, userID: userID)
                
                // Only set authentication state if keychain save was successful
                currentUser = user
                isAuthenticated = true
                authProvider = .apple
                authError = nil
                
                print("🔐 Authentication completed successfully. Current user display name: '\(userDisplayName)'")
            } catch {
                // Keychain save failed - revert to unauthenticated state to prevent inconsistency
                currentUser = nil
                isAuthenticated = false
                authProvider = .none
                authError = "Failed to securely save authentication data. Please try signing in again."
                
                print("❌ Authentication failed due to keychain error - user state reverted to unauthenticated")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false
        
        print("🔴 Apple Sign-In Error: \(error)")
        print("🔍 Error Domain: \((error as NSError).domain)")
        print("🔍 Error Code: \((error as NSError).code)")
        
        // Handle the error
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                self.authError = nil // Don't show error for user cancellation
                print("ℹ️ User canceled Apple Sign-In")
            case .failed:
                self.authError = "Sign in failed. Please try again."
                print("❌ Apple Sign-In failed")
            case .invalidResponse:
                self.authError = "Invalid response from Apple"
                print("❌ Invalid response from Apple servers")
            case .notHandled:
                self.authError = "Sign in not handled - configuration issue"
                print("❌ Sign-In not handled - check app configuration")
            case .unknown:
                // Error 1000 falls here - capability not configured
                if (error as NSError).code == 1000 {
                    print("⚠️ Error 1000: Sign in with Apple capability not properly configured")
                    self.authError = "Sign in with Apple is not properly configured. Please contact support."
                    print("📱 Instructions for fixing:")
                    print("   1. Open project in Xcode")
                    print("   2. Select Sunshade target → Signing & Capabilities")
                    print("   3. Click '+' and add 'Sign In with Apple' capability")
                    print("   4. Ensure entitlements file is linked: CODE_SIGN_ENTITLEMENTS = Sunshade/Sunshade.entitlements")
                } else {
                    self.authError = "Unknown error - check device settings"
                    print("❌ Unknown Apple Sign-In error")
                }
            @unknown default:
                self.authError = "Unexpected error occurred"
                print("❌ Unexpected Apple Sign-In error")
            }
        } else {
            // Handle specific error codes
            let nsError = error as NSError
            
            switch nsError.code {
            case 1000:
                print("⚠️ Error 1000: Sign in with Apple capability not enabled in Xcode")
                self.authError = "Sign in with Apple is not configured. Please enable the capability in Xcode."
            case -7026:
                print("⚠️ Error -7026: Apple ID authentication issue")
                self.authError = "Unable to verify Apple ID. Please check your device settings."
            case -7003:
                print("⚠️ Error -7003: Apple ID not signed in")
                self.authError = "Please sign in to your Apple ID in Settings and try again."
            case 1001:
                print("⚠️ Error 1001: Authentication failed or canceled")
                self.authError = nil // User likely canceled
            default:
                self.authError = "Authentication failed. Please try again."
                print("❌ General authentication error: \(error)")
            }
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