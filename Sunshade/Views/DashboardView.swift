import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderSection(viewModel: viewModel, authManager: authManager)
                    UVIndexCard(viewModel: viewModel)
                    WeatherCard(viewModel: viewModel)
                    SafetyCard(viewModel: viewModel)
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
        .onAppear {
            // Update greeting when user authentication state changes
            viewModel.updateGreetingForUser(authManager.userDisplayName)
        }
    }
}