import SwiftUI

struct EducationView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    EducationCard(
                        icon: "sun.max.fill",
                        title: "UV Index Basics",
                        description: "Learn how UV radiation affects your skin and health.",
                        color: AppColors.primary
                    )
                    
                    EducationCard(
                        icon: "shield.fill",
                        title: "Sun Protection",
                        description: "Essential tips for protecting yourself from harmful UV rays.",
                        color: AppColors.success
                    )
                    
                    EducationCard(
                        icon: "clock.fill",
                        title: "Safe Exposure Times",
                        description: "Understanding how long you can safely stay in the sun.",
                        color: AppColors.warning
                    )
                    
                    EducationCard(
                        icon: "drop.fill",
                        title: "Sunscreen Guide",
                        description: "How to choose and apply sunscreen effectively.",
                        color: AppColors.info
                    )
                }
                .padding()
            }
            .navigationTitle("Learn")
        }
    }
}

struct EducationCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textMuted)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}