import SwiftUI

/// Intelligent Safety Card with enhanced recommendations
/// Uses rule-based intelligence for immediate compatibility across all iOS versions
struct SmartSafetyCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var enhancedRecommendations: [SmartRecommendation] = []
    @State private var isIntelligentMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with intelligence toggle
            headerSection
            
            // Safe Exposure Time
            safeExposureTimeCard
            
            // Recommendations List
            recommendationsSection
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
        .onAppear {
            generateEnhancedRecommendations()
        }
        .onChange(of: viewModel.currentUVIndex) { _, _ in
            if isIntelligentMode {
                generateEnhancedRecommendations()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Image(systemName: isIntelligentMode ? "brain.head.profile" : "shield.checkered")
                .font(.title2)
                .foregroundColor(isIntelligentMode ? AppColors.accent : AppColors.success)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Safety Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                if isIntelligentMode {
                    Text("Smart Mode")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }
            }
            
            Spacer()
            
            // Intelligence toggle
            Button(action: {
                isIntelligentMode.toggle()
                generateEnhancedRecommendations()
            }) {
                Image(systemName: isIntelligentMode ? "brain.head.profile.fill" : "brain.head.profile")
                    .foregroundColor(AppColors.accent)
            }
        }
    }
    
    // MARK: - Safe Exposure Time Card
    
    private var safeExposureTimeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Safe Exposure Time")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 4) {
                    Text(viewModel.safeExposureTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.success)
                    
                    if isIntelligentMode && viewModel.currentUVIndex >= 8 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.warning)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "clock.fill")
                .font(.title2)
                .foregroundColor(AppColors.success)
        }
        .padding(16)
        .background(AppColors.success.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Recommendations Section
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isIntelligentMode && !enhancedRecommendations.isEmpty {
                ForEach(enhancedRecommendations.indices, id: \.self) { index in
                    SmartRecommendationRow(recommendation: enhancedRecommendations[index])
                }
            } else {
                ForEach(viewModel.safetyRecommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.primary)
                            .font(.subheadline)
                        
                        Text(recommendation)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Enhanced Recommendations Generation
    
    private func generateEnhancedRecommendations() {
        guard isIntelligentMode else {
            enhancedRecommendations = []
            return
        }
        
        let uvIndex = viewModel.currentUVIndex
        let temperature = viewModel.temperature
        let cloudCover = viewModel.cloudCover
        let condition = viewModel.weatherCondition
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        var recommendations: [SmartRecommendation] = []
        
        // Critical UV alert
        if uvIndex >= 10 {
            recommendations.append(SmartRecommendation(
                priority: .critical,
                message: "⚠️ EXTREME UV Alert! UV index of \(Int(uvIndex)) can cause severe burns in under 5 minutes.",
                category: "timing",
                icon: "exclamationmark.triangle.fill",
                color: .red
            ))
        }
        
        // Peak hours warning
        if currentHour >= 10 && currentHour <= 16 && uvIndex >= 6 {
            let safeTime = max(5, Int(120 / uvIndex))
            recommendations.append(SmartRecommendation(
                priority: .urgent,
                message: "☀️ Peak UV hours. Limit exposure to \(safeTime) minutes or seek shade.",
                category: "timing",
                icon: "sun.max.fill",
                color: .orange
            ))
        }
        
        // Weather-specific advice
        if condition.lowercased().contains("clear") && uvIndex >= 7 {
            recommendations.append(SmartRecommendation(
                priority: .important,
                message: "🌞 Clear skies amplify UV. Use SPF 50+ and UV-blocking sunglasses.",
                category: "protection",
                icon: "eye.fill",
                color: .orange
            ))
        } else if condition.lowercased().contains("cloud") {
            recommendations.append(SmartRecommendation(
                priority: .routine,
                message: "☁️ Clouds provide partial protection. UV still penetrates - use SPF 30+.",
                category: "protection",
                icon: "cloud.sun.fill",
                color: .blue
            ))
        }
        
        // Temperature-based hydration
        if temperature >= 25 && uvIndex >= 6 {
            recommendations.append(SmartRecommendation(
                priority: .important,
                message: "🌡️ High temp (\(temperature)°C) + UV \(Int(uvIndex)) increases dehydration risk.",
                category: "hydration",
                icon: "drop.fill",
                color: .blue
            ))
        }
        
        // Activity timing
        if currentHour >= 6 && currentHour <= 9 && uvIndex <= 5 {
            recommendations.append(SmartRecommendation(
                priority: .routine,
                message: "🏃 Great time for outdoor exercise! UV is moderate (\(Int(uvIndex))).",
                category: "activity",
                icon: "figure.run",
                color: .green
            ))
        }
        
        // Evening recommendation
        if currentHour >= 17 && currentHour <= 19 && uvIndex <= 3 {
            recommendations.append(SmartRecommendation(
                priority: .routine,
                message: "🌅 Golden hour! Low UV (\(Int(uvIndex))) - ideal for outdoor activities.",
                category: "activity",
                icon: "camera.fill",
                color: .green
            ))
        }
        
        // Basic protection
        if uvIndex >= 3 {
            recommendations.append(SmartRecommendation(
                priority: .routine,
                message: "🧴 Apply broad-spectrum SPF 30+ sunscreen 15 minutes before exposure.",
                category: "protection",
                icon: "shield.fill",
                color: .blue
            ))
        }
        
        // Reapplication reminder
        if uvIndex >= 6 {
            recommendations.append(SmartRecommendation(
                priority: .routine,
                message: "🔄 High UV requires reapplication every 90 minutes when outdoors.",
                category: "protection",
                icon: "arrow.clockwise",
                color: .blue
            ))
        }
        
        // Sort by priority
        enhancedRecommendations = recommendations.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }
}

// MARK: - Smart Recommendation Models

struct SmartRecommendation {
    let priority: SmartPriority
    let message: String
    let category: String
    let icon: String
    let color: Color
}

enum SmartPriority {
    case critical, urgent, important, routine
    
    var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .urgent: return 1
        case .important: return 2
        case .routine: return 3
        }
    }
    
    var displayName: String {
        switch self {
        case .critical: return "CRITICAL"
        case .urgent: return "URGENT"
        case .important: return "IMPORTANT"
        case .routine: return ""
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .critical: return .red
        case .urgent: return .orange
        case .important: return .blue
        case .routine: return .clear
        }
    }
}

// MARK: - Smart Recommendation Row

struct SmartRecommendationRow: View {
    let recommendation: SmartRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon with priority indicator
            VStack(spacing: 4) {
                Image(systemName: recommendation.icon)
                    .foregroundColor(recommendation.color)
                    .font(.title3)
                
                // Priority dot for high-priority items
                if recommendation.priority == .critical || recommendation.priority == .urgent {
                    Circle()
                        .fill(recommendation.priority.badgeColor)
                        .frame(width: 6, height: 6)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Priority badge for critical/urgent items
                if recommendation.priority == .critical || recommendation.priority == .urgent {
                    Text(recommendation.priority.displayName)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(recommendation.priority.badgeColor)
                        .cornerRadius(8)
                }
                
                // Message
                Text(recommendation.message)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .background(recommendation.color.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SmartSafetyCard(viewModel: DashboardViewModel())
            .environmentObject(LocationManager())
    }
    .background(AppColors.backgroundPrimary)
}