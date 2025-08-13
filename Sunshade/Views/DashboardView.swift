import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderSection(viewModel: viewModel, authManager: authManager)
                    UVIndexCard(viewModel: viewModel)
                    WeatherCard(viewModel: viewModel)
                    SafeAISafetyCard(viewModel: viewModel)
                    DailyProgressCard(viewModel: viewModel)
                }
                .padding(.vertical)
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Sunshade")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}