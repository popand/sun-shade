import Foundation
import GoogleSignIn
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: GIDGoogleUser?
    @Published var isLoading = false
    @Published var authError: String?
    
    init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            isAuthenticated = true
            currentUser = GIDSignIn.sharedInstance.currentUser
        }
    }
    
    func signIn() {
        guard let presentingViewController = getRootViewController() else {
            authError = "Unable to find root view controller"
            return
        }
        
        isLoading = true
        authError = nil
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.authError = error.localizedDescription
                    return
                }
                
                guard let user = result?.user else {
                    self?.authError = "Failed to get user information"
                    return
                }
                
                self?.currentUser = user
                self?.isAuthenticated = true
                self?.authError = nil
            }
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isAuthenticated = false
        currentUser = nil
        authError = nil
    }
    
    var userDisplayName: String {
        return currentUser?.profile?.name ?? "Unknown User"
    }
    
    var userEmail: String {
        return currentUser?.profile?.email ?? ""
    }
    
    var userProfileImageURL: String? {
        return currentUser?.profile?.imageURL(withDimension: 100)?.absoluteString
    }
}