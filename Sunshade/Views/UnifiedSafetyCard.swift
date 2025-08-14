import SwiftUI

/// Unified Safety Card - Configurable component for safety recommendations
/// Combines all features from previous implementations with a clean, maintainable architecture
struct UnifiedSafetyCard: View {
    
    // MARK: - Dependencies
    
    @ObservedObject var viewModel: DashboardViewModel
    @StateObject private var recommendationManager: RecommendationManager
    
    // MARK: - Configuration
    
    enum DisplayMode {
        case basic       // Traditional static recommendations
        case smart       // Rule-based intelligent recommendations
        case ai          // Future AI-powered recommendations (iOS 26+)
    }
    
    private let displayMode: DisplayMode
    private let showModeToggle: Bool
    
    // MARK: - Initialization
    
    init(
        viewModel: DashboardViewModel,
        displayMode: DisplayMode = .smart,
        showModeToggle: Bool = true,
        recommendationManager: RecommendationManager? = nil
    ) {
        self.viewModel = viewModel
        self.displayMode = displayMode
        self.showModeToggle = showModeToggle
        self._recommendationManager = StateObject(
            wrappedValue: recommendationManager ?? RecommendationManager()
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            safeExposureTimeCard
            recommendationsSection
            
            if recommendationManager.isGenerating {
                loadingIndicator
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
        .onAppear {
            initializeRecommendations()
        }
        .onChange(of: viewModel.currentUVIndex) { _, _ in
            updateRecommendations()
        }
        .onChange(of: viewModel.temperature) { _, _ in
            updateRecommendations()
        }
        .onChange(of: viewModel.weatherCondition) { _, _ in
            updateRecommendations()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Image(systemName: headerIcon)
                .font(.title2)
                .foregroundColor(headerColor)
                .symbolEffect(.pulse, isActive: recommendationManager.isGenerating)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Safety Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                if displayMode != .basic && recommendationManager.isIntelligentMode {
                    Text(modeLabel)
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }
            }
            
            Spacer()
            
            if showModeToggle && displayMode != .basic {
                modeToggleButton
            }
        }
    }
    
    private var headerIcon: String {
        switch displayMode {
        case .basic:
            return "shield.checkered"
        case .smart, .ai:
            return recommendationManager.isIntelligentMode ? "brain.head.profile" : "shield.checkered"
        }
    }
    
    private var headerColor: Color {
        switch displayMode {
        case .basic:
            return AppColors.success
        case .smart, .ai:
            return recommendationManager.isIntelligentMode ? AppColors.accent : AppColors.success
        }
    }
    
    private var modeLabel: String {
        switch displayMode {
        case .basic:
            return ""
        case .smart:
            return "Smart Mode"
        case .ai:
            return "AI Mode"
        }
    }
    
    private var modeToggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                recommendationManager.toggleIntelligentMode()
            }
        }) {
            Image(systemName: recommendationManager.isIntelligentMode ? "brain.head.profile.fill" : "brain.head.profile")
                .foregroundColor(AppColors.accent)
                .scaleEffect(recommendationManager.isIntelligentMode ? 1.1 : 1.0)
        }
        .disabled(recommendationManager.isGenerating)
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
                        .foregroundColor(exposureTimeColor)
                    
                    if shouldShowWarning {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.warning)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "clock.fill")
                .font(.title2)
                .foregroundColor(exposureTimeColor)
        }
        .padding(16)
        .background(exposureTimeColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var exposureTimeColor: Color {
        if viewModel.currentUVIndex >= 8 {
            return AppColors.danger
        } else if viewModel.currentUVIndex >= 6 {
            return AppColors.warning
        } else {
            return AppColors.success
        }
    }
    
    private var shouldShowWarning: Bool {
        return displayMode != .basic && 
               recommendationManager.isIntelligentMode && 
               viewModel.currentUVIndex >= 8
    }
    
    // MARK: - Recommendations Section
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if shouldUseIntelligentRecommendations {
                intelligentRecommendationsList
            } else {
                basicRecommendationsList
            }
        }
    }
    
    private var shouldUseIntelligentRecommendations: Bool {
        return displayMode != .basic && 
               recommendationManager.isIntelligentMode && 
               !recommendationManager.recommendations.isEmpty
    }
    
    private var intelligentRecommendationsList: some View {
        ForEach(recommendationManager.recommendations) { recommendation in
            UnifiedRecommendationRow(
                recommendation: recommendation,
                showPriorityBadge: displayMode == .ai
            )
        }
    }
    
    private var basicRecommendationsList: some View {
        ForEach(viewModel.safetyRecommendations, id: \.self) { recommendation in
            SimpleRecommendationRow(text: recommendation)
        }
    }
    
    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Generating personalized recommendations...")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Private Methods
    
    private func initializeRecommendations() {
        guard displayMode != .basic else { return }
        
        if recommendationManager.recommendations.isEmpty {
            recommendationManager.generateRecommendations(
                uvIndex: viewModel.currentUVIndex,
                temperature: viewModel.temperature,
                cloudCover: viewModel.cloudCover,
                condition: viewModel.weatherCondition
            )
        }
    }
    
    private func updateRecommendations() {
        guard displayMode != .basic else { return }
        
        recommendationManager.updateConditions(
            uvIndex: viewModel.currentUVIndex,
            temperature: viewModel.temperature,
            cloudCover: viewModel.cloudCover,
            condition: viewModel.weatherCondition
        )
    }
}

// MARK: - Unified Recommendation Row

struct UnifiedRecommendationRow: View {
    let recommendation: SafetyRecommendation
    let showPriorityBadge: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon with optional priority indicator
            VStack(spacing: 4) {
                Image(systemName: recommendation.iconName)
                    .foregroundColor(recommendation.color)
                    .font(.title3)
                
                if shouldShowPriorityDot {
                    Circle()
                        .fill(recommendation.priority.badgeColor)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                // Optional priority badge
                if showPriorityBadge && recommendation.priority != SafetyPriority.routine {
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
                
                // Optional timeframe
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
        .background(recommendation.color.opacity(0.08))
        .cornerRadius(10)
    }
    
    private var shouldShowPriorityDot: Bool {
        return recommendation.priority == SafetyPriority.critical || 
               recommendation.priority == SafetyPriority.urgent
    }
}

// MARK: - Basic Recommendation Row

private struct SimpleRecommendationRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.primary)
                .font(.subheadline)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview Provider

struct UnifiedSafetyCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Basic mode
            UnifiedSafetyCard(
                viewModel: DashboardViewModel(),
                displayMode: .basic,
                showModeToggle: false
            )
            
            // Smart mode
            UnifiedSafetyCard(
                viewModel: DashboardViewModel(),
                displayMode: .smart
            )
            
            // AI mode
            UnifiedSafetyCard(
                viewModel: DashboardViewModel(),
                displayMode: .ai
            )
        }
        .background(AppColors.backgroundPrimary)
        .previewLayout(.sizeThatFits)
    }
}