import SwiftUI

struct DailyProgressCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.info)
                
                Text("Weekly Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            
            HStack {
                VStack {
                    Text("\(viewModel.sessionsThisWeek)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)

                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(viewModel.sessionsThisWeek) sessions this week")

                Spacer()

                VStack {
                    Text(viewModel.totalExposureThisWeek)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)

                    Text("Total Time")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Total time \(viewModel.totalExposureThisWeek)")

                Spacer()

                VStack(spacing: 4) {
                    Text(viewModel.overExposurePercentage)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.hasOverExposure ? AppColors.warning : AppColors.success)

                    Text("Over-exposure")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text(viewModel.hasOverExposure ? "Over-exposed" : "Safe")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.hasOverExposure ? AppColors.warning : AppColors.success)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Over-exposure \(viewModel.overExposurePercentage), \(viewModel.hasOverExposure ? "Over-exposed" : "Safe")")
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .cardShadow()
        .padding(.horizontal, 20)
    }
}