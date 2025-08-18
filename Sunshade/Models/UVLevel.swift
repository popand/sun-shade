import SwiftUI

enum UVLevel: Int, CaseIterable {
    case low = 1
    case moderate = 3
    case high = 6
    case veryHigh = 8
    case extreme = 11
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        case .extreme: return "Extreme"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return AppColors.success
        case .moderate: return AppColors.warning
        case .high: return AppColors.primary
        case .veryHigh: return AppColors.danger
        case .extreme: return Color.purple
        }
    }
    
    static func level(for uvIndex: Double) -> UVLevel {
        switch uvIndex {
        case ..<0: return .low  // Handle negative values safely
        case 0..<3: return .low
        case 3..<6: return .moderate
        case 6..<8: return .high
        case 8..<11: return .veryHigh
        default: return .extreme
        }
    }
}