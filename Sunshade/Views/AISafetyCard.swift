import SwiftUI

/// Enhanced Safety Card with AI-powered recommendations
/// Currently uses intelligent fallback system, will upgrade to Apple Intelligence when iOS 26+ is available
struct AISafetyCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var intelligentRecommendations: [LegacyRecommendation] = []
    @State private var isGenerating = false
    @State private var useIntelligentMode = false // Start with false to avoid immediate crash
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with intelligent indicator
            HStack {
                Image(systemName: useIntelligentMode ? "brain.head.profile" : "shield.checkered")
                    .font(.title2)
                    .foregroundColor(useIntelligentMode ? AppColors.accent : AppColors.success)
                    .symbolEffect(.pulse, isActive: isGenerating)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Safety Recommendations")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if useIntelligentMode {
                        Text("Intelligent")
                            .font(.caption)
                            .foregroundColor(AppColors.accent)
                    }
                }
                
                Spacer()
                
                // Intelligence toggle
                Button(action: {
                    useIntelligentMode.toggle()
                    if useIntelligentMode {
                        generateIntelligentRecommendations()
                    }
                }) {
                    Image(systemName: useIntelligentMode ? "brain.head.profile.fill" : "brain.head.profile")
                        .foregroundColor(AppColors.accent)
                }
            }
            
            // Safe Exposure Time (enhanced with AI context)
            safeExposureTimeCard
            
            // Recommendations List
            VStack(alignment: .leading, spacing: 12) {
                if useIntelligentMode && !intelligentRecommendations.isEmpty {
                    intelligentRecommendationsList
                } else {
                    traditionalRecommendationsList
                }
            }
            
            // Loading indicator
            if isGenerating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating personalized recommendations...")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
        .onAppear {
            hasAppeared = true
            // Delay intelligent mode activation to avoid initialization crashes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if hasAppeared {
                    useIntelligentMode = true
                    generateIntelligentRecommendations()
                }
            }
        }
        .onDisappear {
            hasAppeared = false
        }
        .onChange(of: viewModel.currentUVIndex) { oldValue, newValue in
            if useIntelligentMode && hasAppeared {
                generateIntelligentRecommendations()
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
                    
                    if useIntelligentMode && viewModel.currentUVIndex >= 6 {
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
    
    // MARK: - Intelligent Recommendations List
    
    @ViewBuilder
    private var intelligentRecommendationsList: some View {
        ForEach(intelligentRecommendations.indices, id: \.self) { index in
            LegacyRecommendationRow(recommendation: intelligentRecommendations[index])
        }
    }
    
    // MARK: - Traditional Recommendations List
    
    private var traditionalRecommendationsList: some View {
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
    
    // MARK: - Private Methods
    
    private func generateIntelligentRecommendations() {
        guard useIntelligentMode, hasAppeared else { return }
        
        // Prevent multiple concurrent generations
        guard !isGenerating else { return }
        
        isGenerating = true
        
        Task {
            do {
                let recommendations = await generateEnhancedRecommendations()
                
                await MainActor.run {
                    // Only update if we're still in the same state
                    if hasAppeared && useIntelligentMode {
                        intelligentRecommendations = recommendations
                    }
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    print("❌ Failed to generate recommendations: \(error)")
                    isGenerating = false
                }
            }
        }
    }
    
    private func generateEnhancedRecommendations() async -> [LegacyRecommendation] {
        // Simulate intelligent analysis with enhanced logic
        // This will be replaced with actual AI calls when iOS 26+ is available
        
        var recommendations: [LegacyRecommendation] = []
        
        // Safely access viewModel properties on main thread
        var uvIndex: Double = 0
        var temperature: Int = 0
        var cloudCover: Int = 0
        var weatherCondition: String = ""
        var forecast: [ForecastDay] = []
        
        await MainActor.run {
            uvIndex = viewModel.currentUVIndex
            temperature = viewModel.temperature
            cloudCover = viewModel.cloudCover
            weatherCondition = viewModel.weatherCondition
            forecast = viewModel.forecast
        }
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Critical UV warning
        if uvIndex >= 10 {
            recommendations.append(LegacyRecommendation(
                priority: "critical",
                message: "⚠️ EXTREME UV Alert! Avoid outdoor activities. UV index of \(Int(uvIndex)) can cause severe burns in under 5 minutes.",
                timeframe: "Next 6 hours",
                reasoning: "Extreme UV requires immediate protection",
                category: "timing",
                iconName: "exclamationmark.triangle.fill",
                colorName: "red"
            ))
        }
        
        // Time-based recommendations
        if currentHour >= 10 && currentHour <= 16 && uvIndex >= 6 {
            let safeTime = max(5, Int(120 / uvIndex))
            recommendations.append(LegacyRecommendation(
                priority: "urgent",
                message: "☀️ Peak UV hours detected. Limit outdoor exposure to \(safeTime) minutes or seek shade between 10 AM - 4 PM.",
                timeframe: "Peak hours",
                reasoning: "UV is strongest during midday hours",
                category: "timing",
                iconName: "sun.max.fill",
                colorName: "orange"
            ))
        }
        
        // Weather-specific advice
        if weatherCondition.lowercased().contains("clear") && uvIndex >= 8 {
            recommendations.append(LegacyRecommendation(
                priority: "important",
                message: "🌞 Clear skies amplify UV exposure. Use SPF 50+, wear UV-blocking sunglasses, and reapply sunscreen every hour.",
                timeframe: "All day",
                reasoning: "Clear weather provides no UV protection",
                category: "protection",
                iconName: "eye.fill",
                colorName: "orange"
            ))
        } else if weatherCondition.lowercased().contains("cloud") {
            recommendations.append(LegacyRecommendation(
                priority: "routine",
                message: "☁️ Clouds provide partial protection but UV still penetrates. Apply SPF 30+ as clouds only block 20-40% of UV rays.",
                timeframe: "Throughout day",
                reasoning: "Clouds offer limited UV protection",
                category: "protection",
                iconName: "cloud.sun.fill",
                colorName: "blue"
            ))
        }
        
        // Temperature-based hydration advice
        if Double(temperature) >= 25 && uvIndex >= 6 { // 77°F+
            recommendations.append(LegacyRecommendation(
                priority: "important",
                message: "🌡️ High temperature (\(temperature)°C) + UV \(Int(uvIndex)) increases dehydration risk. Drink water every 15 minutes when outdoors.",
                timeframe: "When active outdoors",
                reasoning: "Heat and UV accelerate fluid loss",
                category: "hydration",
                iconName: "drop.fill",
                colorName: "blue"
            ))
        }
        
        // Activity-specific recommendations
        if currentHour >= 6 && currentHour <= 9 && uvIndex <= 5 {
            recommendations.append(LegacyRecommendation(
                priority: "routine",
                message: "🏃 Great time for outdoor exercise! UV is moderate (\(Int(uvIndex))). Perfect for running, cycling, or outdoor workouts.",
                timeframe: "Morning hours",
                reasoning: "Morning has lower UV levels",
                category: "activity",
                iconName: "figure.run",
                colorName: "green"
            ))
        }
        
        // Evening recommendations
        if currentHour >= 17 && currentHour <= 19 && uvIndex <= 3 {
            recommendations.append(LegacyRecommendation(
                priority: "routine",
                message: "🌅 Golden hour approaching! Low UV (\(Int(uvIndex))) makes this ideal for outdoor activities and photography.",
                timeframe: "Evening",
                reasoning: "Evening UV levels are minimal",
                category: "activity",
                iconName: "camera.fill",
                colorName: "green"
            ))
        }
        
        // Always include basic protection if UV is significant
        if uvIndex >= 3 {
            recommendations.append(LegacyRecommendation(
                priority: "routine",
                message: "🧴 Essential protection: Apply broad-spectrum SPF 30+ sunscreen 15 minutes before sun exposure.",
                timeframe: "Before going outside",
                reasoning: "UV \(Int(uvIndex)) requires sun protection",
                category: "protection",
                iconName: "shield.fill",
                colorName: "blue"
            ))
        }
        
        // Reapplication reminder
        if uvIndex >= 6 {
            recommendations.append(LegacyRecommendation(
                priority: "routine",
                message: "🔄 High UV requires frequent reapplication. Reapply sunscreen every 90 minutes, or every hour if sweating.",
                timeframe: "Throughout exposure",
                reasoning: "High UV degrades sunscreen faster",
                category: "protection",
                iconName: "arrow.clockwise",
                colorName: "blue"
            ))
        }
        
        return recommendations
    }
}

// MARK: - Enhanced Recommendation Row

struct LegacyRecommendationRow: View {
    let recommendation: LegacyRecommendation
    
    private var color: Color {
        switch recommendation.colorName {
        case "red": return .red
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "teal": return .teal
        default: return .blue
        }
    }
    
    private var priorityBadgeColor: Color {
        switch recommendation.priority {
        case "critical": return .red
        case "urgent": return .orange
        case "important": return .blue
        default: return .clear
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Enhanced icon with priority indicator
            VStack(spacing: 4) {
                Image(systemName: recommendation.iconName)
                    .foregroundColor(color)
                    .font(.title3)
                
                // Priority dot for high-priority items
                if recommendation.priority == "critical" || recommendation.priority == "urgent" {
                    Circle()
                        .fill(priorityBadgeColor)
                        .frame(width: 6, height: 6)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Priority badge for critical/urgent items
                if recommendation.priority == "critical" || recommendation.priority == "urgent" {
                    Text(recommendation.priority.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(priorityBadgeColor)
                        .cornerRadius(8)
                }
                
                // Enhanced message with better typography
                Text(recommendation.message)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
                
                // Timeframe with better styling
                if !recommendation.timeframe.isEmpty && recommendation.timeframe != "General" {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(AppColors.textMuted)
                        
                        Text(recommendation.timeframe)
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(12)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        AISafetyCard(viewModel: DashboardViewModel())
            .environmentObject(LocationManager())
    }
    .background(AppColors.backgroundPrimary)
}