import SwiftUI

struct AccountSettingsView: View {
    @ObservedObject private var userProfile = UserProfile.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Temperature Unit Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(AppColors.primary)
                            .font(.title3)
                        
                        Text("Temperature Unit")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            TemperatureUnitRow(
                                unit: unit,
                                isSelected: userProfile.temperatureUnit == unit,
                                action: {
                                    userProfile.temperatureUnit = unit
                                }
                            )
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                Spacer()
            }
            .padding()
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Account Settings")
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.primary)
            )
        }
    }
}

struct TemperatureUnitRow: View {
    let unit: TemperatureUnit
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: unit == .celsius ? "c.circle" : "f.circle")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                Text(unit.displayName)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AccountSettingsView()
}