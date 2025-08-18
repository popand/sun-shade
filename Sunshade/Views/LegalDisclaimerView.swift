import SwiftUI

struct LegalDisclaimerView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Legal Disclaimer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.bottom, 10)
                    
                    Group {
                        SectionView(title: "Medical Disclaimer") {
                            Text("IMPORTANT: SunshAid is not a medical device and should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always consult with a qualified healthcare provider regarding sun exposure recommendations, especially if you have skin conditions or medical concerns.")
                        }
                        
                        SectionView(title: "Accuracy of Information") {
                            Text("While we strive to provide accurate UV index and weather information, SunshAid relies on third-party data sources. We cannot guarantee the accuracy, completeness, or timeliness of this information. Weather conditions can change rapidly and may not be reflected immediately in the app.")
                        }
                        
                        SectionView(title: "No Warranty") {
                            Text("SunshAid is provided 'as is' without any warranty of any kind, either express or implied. We do not warrant that the app will be error-free, uninterrupted, or meet your specific requirements.")
                        }
                        
                        SectionView(title: "Limitation of Liability") {
                            Text("In no event shall the developers of SunshAid be liable for any direct, indirect, incidental, special, or consequential damages resulting from the use or inability to use this application, including but not limited to sunburn, skin damage, or other health issues.")
                        }
                        
                        SectionView(title: "Personal Responsibility") {
                            Text("You acknowledge that:\n• Sun exposure recommendations are general guidelines\n• Individual skin sensitivity varies significantly\n• You are responsible for your own sun safety decisions\n• Environmental factors may affect UV exposure beyond app predictions")
                        }
                        
                        SectionView(title: "Third-Party Content") {
                            Text("SunshAid may include information or links to third-party content. We are not responsible for the accuracy, completeness, or reliability of such content. Any reliance on third-party information is at your own risk.")
                        }
                        
                        SectionView(title: "Emergency Situations") {
                            Text("SunshAid is not designed for emergency situations. In case of severe sunburn, heat-related illness, or other medical emergencies, seek immediate medical attention. Do not rely on this app for emergency medical guidance.")
                        }
                        
                        SectionView(title: "Geographic Limitations") {
                            Text("UV index and weather data may not be available or accurate for all geographic locations. The app's effectiveness may vary based on your location and local environmental conditions.")
                        }
                        
                        SectionView(title: "Age Restrictions") {
                            Text("This app is intended for users who can make informed decisions about sun exposure. Parents and guardians are responsible for supervising children's use of the app and making appropriate sun safety decisions for minors.")
                        }
                        
                        SectionView(title: "Indemnification") {
                            Text("By using SunshAid, you agree to indemnify and hold harmless the developers from any claims, damages, or expenses arising from your use of the app or your violation of these terms.")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remember:")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.danger)
                        
                        Text("• Always use appropriate sun protection\n• Seek shade during peak UV hours\n• Wear protective clothing and sunglasses\n• Apply and reapply broad-spectrum sunscreen\n• Consult healthcare providers for medical advice")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppColors.danger.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.danger.opacity(0.3), lineWidth: 1)
                    )
                    
                    Text("Last updated: \(getCurrentDate())")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.top, 20)
                }
                .padding()
            }
            .background(AppColors.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

#Preview {
    LegalDisclaimerView()
} 