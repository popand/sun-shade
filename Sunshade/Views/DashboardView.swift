import SwiftUI

struct PeakUVBanner: View {
    let uvIndex: Double

    private var isPeakHours: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 10 && hour <= 16
    }

    private var shouldShow: Bool {
        isPeakHours && uvIndex >= 3
    }

    var body: some View {
        if shouldShow {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.trianglebadge.exclamationmark")
                    .font(.title3)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Peak UV Hours")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Seek shade until 4 PM")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()
            }
            .padding()
            .background(AppColors.warning.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderSection(viewModel: viewModel)
                    PeakUVBanner(uvIndex: viewModel.currentUVIndex)
                    UVIndexCard(viewModel: viewModel)
                    WeatherCard(viewModel: viewModel)
                    UnifiedSafetyCard(viewModel: viewModel)
                    DailyProgressCard(viewModel: viewModel)
                }
                .padding(.vertical)
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("SunshAid")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}