import SwiftUI

struct LicenseTermsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("License & Terms of Use")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.bottom, 10)
                    
                    Group {
                        SectionView(title: "1. Acceptance of Terms") {
                            Text("By downloading, installing, or using the Sunshade application, you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the application.")
                        }
                        
                        SectionView(title: "2. License Grant") {
                            Text("Sunshade grants you a limited, non-exclusive, non-transferable license to use this application for personal, non-commercial purposes in accordance with these terms.")
                        }
                        
                        SectionView(title: "3. Permitted Use") {
                            Text("You may use Sunshade for:\n• Personal UV exposure monitoring\n• Educational purposes related to sun safety\n• Tracking your sun exposure habits\n• Accessing weather and UV index information")
                        }
                        
                        SectionView(title: "4. Prohibited Use") {
                            Text("You may not:\n• Use the app for commercial purposes without permission\n• Reverse engineer or modify the application\n• Share your account credentials with others\n• Use the app in ways that could harm or interfere with its operation")
                        }
                        
                        SectionView(title: "5. Intellectual Property") {
                            Text("All content, features, and functionality of Sunshade are owned by the developers and are protected by international copyright, trademark, and other intellectual property laws.")
                        }
                        
                        SectionView(title: "6. Updates and Modifications") {
                            Text("We reserve the right to modify these terms at any time. Updated terms will be made available through the application, and continued use constitutes acceptance of the modified terms.")
                        }
                        
                        SectionView(title: "7. Termination") {
                            Text("This license is effective until terminated. We may terminate this license at any time if you fail to comply with these terms. Upon termination, you must cease all use of the application.")
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

struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            content()
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    LicenseTermsView()
} 