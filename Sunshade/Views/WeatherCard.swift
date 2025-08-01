import SwiftUI

struct WeatherCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Current Weather (Always Visible)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accent.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: weatherIcon)
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.formattedTemperature)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(viewModel.weatherCondition)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("\(viewModel.cloudCover)% Cloud Cover")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Tanning Quality")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                        
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.currentTanningQuality.icon)
                                .font(.caption)
                                .foregroundColor(viewModel.currentTanningQuality.color)
                            
                            Text(viewModel.currentTanningQuality.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.currentTanningQuality.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(viewModel.currentTanningQuality.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(20)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 5-Day Forecast (Expandable)
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        Text("5-Day Forecast")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 16)
                        
                        ForEach(Array(viewModel.forecast.enumerated()), id: \.offset) { index, day in
                            ForecastRowView(day: day, isToday: index == 0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    private var weatherIcon: String {
        switch viewModel.weatherCondition.lowercased() {
        case let condition where condition.contains("clear"):
            return "sun.max.fill"
        case let condition where condition.contains("cloud"):
            return "cloud.sun.fill"
        case let condition where condition.contains("rain"):
            return "cloud.rain.fill"
        default:
            return "cloud.sun.fill"
        }
    }
}

struct ForecastRowView: View {
    let day: ForecastDay
    let isToday: Bool
    @ObservedObject private var userProfile = UserProfile.shared
    
    var body: some View {
        HStack(spacing: 8) {
            // Day
            Text(isToday ? "Today" : dayFormatter.string(from: day.date))
                .font(.subheadline)
                .fontWeight(isToday ? .semibold : .regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 50, alignment: .leading)
            
            // Weather Icon
            Image(systemName: weatherIcon(for: day.condition))
                .font(.title3)
                .foregroundColor(AppColors.accent)
                .frame(width: 25)
            
            // Temperature Range
            HStack(spacing: 2) {
                Text("\(Int(userProfile.temperatureUnit.convert(from: Double(day.highTemp)).rounded()))°")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .fixedSize()
                
                Text("/")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textMuted)
                    .lineLimit(1)
                
                Text("\(Int(userProfile.temperatureUnit.convert(from: Double(day.lowTemp)).rounded()))°")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textMuted)
                    .lineLimit(1)
                    .fixedSize()
            }
            .frame(minWidth: 65, alignment: .leading)
            
            Spacer()
            
            // UV Index
            Text("UV \(Int(day.uvIndex))")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 30, alignment: .center)
            
            // Tanning Quality
            HStack(spacing: 3) {
                Image(systemName: day.tanningQuality.icon)
                    .font(.caption)
                    .foregroundColor(day.tanningQuality.color)
                
                Text(day.tanningQuality.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(day.tanningQuality.color)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(day.tanningQuality.color.opacity(0.1))
            .cornerRadius(6)
            .frame(minWidth: 55)
        }
        .padding(.vertical, 4)
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case let cond where cond.contains("clear"):
            return "sun.max.fill"
        case let cond where cond.contains("cloud"):
            return "cloud.fill"
        case let cond where cond.contains("rain"):
            return "cloud.rain.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
}