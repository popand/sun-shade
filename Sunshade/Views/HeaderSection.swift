import SwiftUI

struct HeaderSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    /// Whether the current error state indicates a location permission issue.
    private var isPermissionError: Bool {
        viewModel.isLocationPermissionDenied ||
        (viewModel.weatherError?.localizedCaseInsensitiveContains("denied") == true)
    }

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

                if viewModel.weatherError != nil && isPermissionError {
                    Button(action: openAppSettings) {
                        HStack(spacing: 4) {
                            Text("Open Settings")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                        }
                        .foregroundColor(AppColors.accent)
                    }
                    .accessibilityLabel("Open Settings to enable location access")
                    .accessibilityHint("Double tap to open the app settings page where you can grant location permission")
                }
            }

            Spacer()

            Button(action: {
                viewModel.refreshDataSync()
            }) {
                Image(systemName: "arrow.clockwise")
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
            .accessibilityLabel(viewModel.isLoading ? "Refreshing weather data" : "Refresh weather data")
            .accessibilityHint(viewModel.isLoading ? "" : "Double tap to refresh")
        }
        .padding(.horizontal, 20)
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}