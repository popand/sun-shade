import SwiftUI

struct SafetyCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.title2)
                    .foregroundColor(AppColors.success)
                
                Text("Safety Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safe Exposure Time")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(viewModel.safeExposureTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.success)
                }
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.success)
            }
            .padding(16)
            .background(AppColors.success.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
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
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}