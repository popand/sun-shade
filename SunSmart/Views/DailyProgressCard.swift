import SwiftUI

struct DailyProgressCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.info)
                
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            
            HStack {
                VStack {
                    Text("\(viewModel.sessionsToday)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                    
                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text(viewModel.totalExposureToday)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)
                    
                    Text("Total Time")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("75%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.success)
                    
                    Text("Daily Goal")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}