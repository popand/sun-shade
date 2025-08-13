import SwiftUI

/// Memory-safe AI Safety Card with proper lifecycle management and dependency injection
struct SafeAISafetyCard: View {
    
    // MARK: - Dependencies
    
    @ObservedObject var viewModel: DashboardViewModel
    @StateObject private var recommendationManager: RecommendationManager
    
    // MARK: - Initialization
    
    init(viewModel: DashboardViewModel, recommendationManager: RecommendationManager? = nil) {
        self.viewModel = viewModel
        self._recommendationManager = StateObject(wrappedValue: recommendationManager ?? RecommendationManager())
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
            Image(systemName: recommendationManager.isIntelligentMode ? "brain.head.profile" : "shield.checkered")
                .font(.title2)
                .foregroundColor(recommendationManager.isIntelligentMode ? AppColors.accent : AppColors.success)
                .symbolEffect(.pulse, isActive: recommendationManager.isGenerating)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Safety Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                if recommendationManager.isIntelligentMode {
                    Text("Smart Mode")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }
            }
            
            Spacer()
            
            intelligenceToggleButton
        }
    }
    
    private var intelligenceToggleButton: some View {
        Button(action: {
            recommendationManager.toggleIntelligentMode()
        }) {
            Image(systemName: recommendationManager.isIntelligentMode ? "brain.head.profile.fill" : "brain.head.profile")
                .foregroundColor(AppColors.accent)
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
                        .foregroundColor(AppColors.success)
                    
                    if recommendationManager.isIntelligentMode && viewModel.currentUVIndex >= 8 {
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
            if recommendationManager.isIntelligentMode {
                ForEach(recommendationManager.recommendations) { recommendation in
                    IntelligentRecommendationRow(recommendation: recommendation)
                }
            } else {
                ForEach(viewModel.safetyRecommendations, id: \.self) { recommendation in
                    BasicRecommendationRow(text: recommendation)
                }
            }
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
        // No artificial delays - immediate initialization
        if recommendationManager.recommendations.isEmpty {
            recommendationManager.generateRecommendations()
        }
    }
    
    private func updateRecommendations() {
        recommendationManager.updateConditions(
            uvIndex: viewModel.currentUVIndex,
            temperature: viewModel.temperature,
            cloudCover: viewModel.cloudCover,
            condition: viewModel.weatherCondition
        )
    }
}

// MARK: - Recommendation Row Components

struct IntelligentRecommendationRow: View {
    let recommendation: SafetyRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon with priority indicator
            VStack(spacing: 4) {
                Image(systemName: recommendation.iconName)
                    .foregroundColor(recommendation.color)
                    .font(.title3)
                
                // Priority dot for high-priority items
                if recommendation.priority == SafetyPriority.critical || recommendation.priority == SafetyPriority.urgent {
                    Circle()
                        .fill(recommendation.priority.badgeColor)
                        .frame(width: 6, height: 6)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Priority badge for critical/urgent items
                if recommendation.priority != SafetyPriority.routine {
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
                
                // Timeframe
                if !recommendation.timeframe.isEmpty {
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
}

struct BasicRecommendationRow: View {
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

// MARK: - Error Handling View

struct RecommendationErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
                .font(.title2)
            
            Text("Failed to load recommendations")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            
            Button("Retry", action: retryAction)
                .font(.caption)
                .foregroundColor(AppColors.accent)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SafeAISafetyCard(viewModel: DashboardViewModel())
            .environmentObject(LocationManager())
    }
    .background(AppColors.backgroundPrimary)
}