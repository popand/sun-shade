import Foundation

class UserProfile: ObservableObject {
    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "userName")
        }
    }
    
    @Published var skinType: String {
        didSet {
            UserDefaults.standard.set(skinType, forKey: "userSkinType")
        }
    }
    
    init() {
        self.name = UserDefaults.standard.string(forKey: "userName") ?? "John Doe"
        self.skinType = UserDefaults.standard.string(forKey: "userSkinType") ?? "Fair"
    }
    
    static let shared = UserProfile()
} 