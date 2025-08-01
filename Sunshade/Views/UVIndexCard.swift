import SwiftUI

struct UVIndexCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundTertiary, lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: viewModel.currentUVIndex / 11.0)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(Int(viewModel.currentUVIndex))")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("UV Index")
                        .font(.headline)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.uvLevel.color)
                    .frame(width: 12, height: 12)
                
                Text(viewModel.uvLevel.description)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(viewModel.uvLevel.color.opacity(0.1))
            .cornerRadius(25)
            
            // Safe Exposure Time Recommendation
            HStack(spacing: 12) {
                Image(systemName: "timer")
                    .foregroundColor(AppColors.info)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Safe exposure time")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(viewModel.safeExposureTime)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(AppColors.info.opacity(0.1))
            .cornerRadius(12)
            
            if viewModel.currentUVIndex >= 6 {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.warning)
                        .font(.title3)
                    
                    Text("High UV levels detected. Use sun protection.")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(16)
                .background(AppColors.warning.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}