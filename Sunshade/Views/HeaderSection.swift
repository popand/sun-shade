import SwiftUI

struct HeaderSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    let authManager: AuthenticationManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Image(systemName: viewModel.weatherError != nil ? "location.slash" : "location.fill")
                        .foregroundColor(viewModel.weatherError != nil ? AppColors.danger : AppColors.primary)
                        .font(.caption)
                    
                    Text(viewModel.currentLocation)
                        .font(.subheadline)
                        .foregroundColor(viewModel.weatherError != nil ? AppColors.danger : AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.refreshData()
            }) {
                Image(systemName: viewModel.isLoading ? "arrow.clockwise" : "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(viewModel.isLoading ? AppColors.textMuted : AppColors.primary)
                    .padding(12)
                    .background((viewModel.isLoading ? AppColors.textMuted : AppColors.primary).opacity(0.1))
                    .clipShape(Circle())
                    .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                    .animation(
                        viewModel.isLoading ? 
                        Animation.linear(duration: 1.0).repeatForever(autoreverses: false) : 
                        .default, 
                        value: viewModel.isLoading
                    )
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 20)
    }
}