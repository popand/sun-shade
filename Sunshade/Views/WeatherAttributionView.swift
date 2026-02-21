import SwiftUI

struct WeatherAttributionView: View {
    private static let attributionURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")

    var body: some View {
        if let url = Self.attributionURL {
            Link(destination: url) {
                HStack(spacing: 4) {
                    Image(systemName: "apple.logo")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("Weather")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
}

struct CompactWeatherAttributionView: View {
    private static let attributionURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")

    var body: some View {
        if let url = Self.attributionURL {
            Link(destination: url) {
                HStack(spacing: 2) {
                    Image(systemName: "apple.logo")
                        .font(.caption2)

                    Text("Weather")
                        .font(.caption2)
                }
                .foregroundColor(.secondary.opacity(0.8))
            }
        }
    }
}