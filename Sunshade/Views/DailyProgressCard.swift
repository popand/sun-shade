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

                VStack {
                    Text(viewModel.overExposurePercentage)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.hasOverExposure ? AppColors.warning : AppColors.success)

                    Text("Over-exposure")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Over-exposure \(viewModel.overExposurePercentage)")
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.shadowColor, radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}