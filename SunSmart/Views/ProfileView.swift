import SwiftUI

struct ProfileView: View {
    @ObservedObject private var userProfile = UserProfile.shared
    @State private var isEditingName = false
    @State private var tempName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primary)
                    
                    if isEditingName {
                        HStack {
                            TextField("Enter your name", text: $tempName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onAppear {
                                    tempName = userProfile.name
                                }
                            
                            Button("Save") {
                                userProfile.name = tempName
                                isEditingName = false
                            }
                            .foregroundColor(AppColors.primary)
                        }
                    } else {
                        HStack {
                            Text(userProfile.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Button(action: {
                                isEditingName = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(AppColors.primary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Text("Skin Type: \(userProfile.skinType)")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                VStack(spacing: 16) {
                    Text("This Week's Stats")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack {
                        StatItem(title: "Sessions", value: "12", color: AppColors.primary)
                        StatItem(title: "Total Time", value: "4h 30m", color: AppColors.success)
                        StatItem(title: "Avg UV", value: "6.2", color: AppColors.warning)
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
            .navigationTitle("Profile")
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}