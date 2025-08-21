import SwiftUI

struct PrivacyNoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "shield.checkerboard")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Privacy Notice")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Your privacy and data security are our top priority")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Privacy Sections
                    VStack(spacing: 16) {
                        PrivacySectionHeader(title: "Data Collection", icon: "doc.text")
                        
                        VStack(spacing: 12) {
                            PrivacyCard(
                                title: "Information We Collect",
                                content: "• Location data (with permission) for UV index\n• App usage patterns and interactions\n• Device info for optimal performance\n• Sun exposure data (stored locally only)"
                            )
                            
                            PrivacyCard(
                                title: "How We Use Your Information",
                                content: "• Provide accurate UV index for your location\n• Improve app functionality and experience\n• Send relevant safety recommendations\n• Analyze usage for app improvements"
                            )
                        }
                    }
                    
                    VStack(spacing: 16) {
                        PrivacySectionHeader(title: "Data Security", icon: "lock.shield")
                        
                        VStack(spacing: 12) {
                            PrivacyCard(
                                title: "Data Storage and Security",
                                content: "Your personal data is stored securely on your device. We implement appropriate security measures to protect against unauthorized access, alteration, or destruction."
                            )
                            
                            PrivacyCard(
                                title: "Location Data",
                                content: "Location access is optional for local UV data. Disable anytime in device settings. No location data stored permanently or shared with third parties."
                            )
                        }
                    }
                    
                    VStack(spacing: 16) {
                        PrivacySectionHeader(title: "Third-Party Services", icon: "cloud")
                        
                        VStack(spacing: 12) {
                            PrivacyCard(
                                title: "WeatherKit Integration",
                                content: "SunshAid uses Apple's WeatherKit for UV index information. Weather data accessed through Apple with no additional third-party services."
                            )
                            
                            PrivacyCard(
                                title: "Data Retention",
                                content: "Sun exposure data stored locally on your device until app deletion. No personal data stored on our servers."
                            )
                        }
                    }
                    
                    VStack(spacing: 16) {
                        PrivacySectionHeader(title: "Your Rights", icon: "person.badge.key")
                        
                        VStack(spacing: 12) {
                            PrivacyCard(
                                title: "User Rights",
                                content: "• Access your personal data\n• Correct inaccurate information\n• Delete data by uninstalling app\n• Disable location services anytime\n• Contact us with privacy concerns"
                            )
                            
                            PrivacyCard(
                                title: "Children's Privacy",
                                content: "Not intended for children under 13. We don't knowingly collect information from children under 13. Contact us if you believe we have."
                            )
                        }
                    }
                    
                    VStack(spacing: 16) {
                        PrivacySectionHeader(title: "Updates & Contact", icon: "envelope")
                        
                        VStack(spacing: 12) {
                            PrivacyCard(
                                title: "Policy Changes",
                                content: "We may update this Privacy Notice periodically. Material changes will be communicated through the app. Continued use constitutes acceptance."
                            )
                            
                            PrivacyCard(
                                title: "Contact Information",
                                content: "Questions about this Privacy Notice or our practices? Contact us through the app feedback feature or support page."
                            )
                        }
                    }
                    
                    // Last Updated
                    Text("Last updated: \(getCurrentDate())")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
                .padding()
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppColors.primary)
            )
        }
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

// Privacy Section Header Component
struct PrivacySectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

// Privacy Card Component
struct PrivacyCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(content)
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PrivacyNoticeView()
} 