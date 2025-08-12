import SwiftUI

struct PrivacyNoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Notice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.bottom, 10)
                    
                    Group {
                        SectionView(title: "Information We Collect") {
                            Text("Sunshade may collect the following information:\n• Location data (with your permission) for UV index information\n• Usage patterns and app interactions\n• Device information for optimal app performance\n• Sun exposure session data (stored locally on your device)")
                        }
                        
                        SectionView(title: "How We Use Your Information") {
                            Text("We use collected information to:\n• Provide accurate UV index data for your location\n• Improve app functionality and user experience\n• Send relevant safety recommendations\n• Analyze usage patterns for app improvements")
                        }
                        
                        SectionView(title: "Data Storage and Security") {
                            Text("Your personal data is stored securely on your device. We implement appropriate security measures to protect your information against unauthorized access, alteration, disclosure, or destruction.")
                        }
                        
                        SectionView(title: "Location Data") {
                            Text("Location access is optional and only used to provide local UV index information. You can disable location access at any time through your device settings. No location data is stored permanently or shared with third parties.")
                        }
                        
                        SectionView(title: "Third-Party Services") {
                            Text("Sunshade uses weather APIs to provide UV index information. These services have their own privacy policies. We do not share your personal information with these services beyond what's necessary for functionality.")
                        }
                        
                        SectionView(title: "Data Retention") {
                            Text("Your sun exposure session data is stored locally on your device and is retained until you delete the app or manually clear the data. No personal data is stored on our servers.")
                        }
                        
                        SectionView(title: "Your Rights") {
                            Text("You have the right to:\n• Access your personal data\n• Correct inaccurate data\n• Delete your data by uninstalling the app\n• Disable location services at any time\n• Contact us with privacy concerns")
                        }
                        
                        SectionView(title: "Children's Privacy") {
                            Text("Sunshade is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us immediately.")
                        }
                        
                        SectionView(title: "Changes to This Privacy Notice") {
                            Text("We may update this Privacy Notice from time to time. We will notify users of any material changes through the app. Your continued use of the app after changes constitutes acceptance of the updated privacy notice.")
                        }
                        
                        SectionView(title: "Contact Information") {
                            Text("If you have questions about this Privacy Notice or our privacy practices, please contact us through the app feedback feature or visit our support page.")
                        }
                    }
                    
                    Text("Last updated: \(getCurrentDate())")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.top, 20)
                }
                .padding()
            }
            .background(AppColors.backgroundPrimary)
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

#Preview {
    PrivacyNoticeView()
} 