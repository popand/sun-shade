import Foundation

struct TimeUtils {
    static func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning!"
        case 12..<17:
            return "Good Afternoon!"
        case 17..<21:
            return "Good Evening!"
        default:
            return "Good Night!"
        }
    }
    
    static func getPersonalizedGreeting(name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // If no name is set, return generic greeting
        if name.isEmpty {
            switch hour {
            case 5..<12:
                return "Good Morning!"
            case 12..<17:
                return "Good Afternoon!"
            case 17..<21:
                return "Good Evening!"
            default:
                return "Good Night!"
            }
        }
        
        let firstName = name.components(separatedBy: " ").first ?? name
        
        switch hour {
        case 5..<12:
            return "Good Morning, \(firstName)!"
        case 12..<17:
            return "Good Afternoon, \(firstName)!"
        case 17..<21:
            return "Good Evening, \(firstName)!"
        default:
            return "Good Night, \(firstName)!"
        }
    }
    
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}