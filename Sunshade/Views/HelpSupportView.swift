import SwiftUI
import MessageUI

struct HelpSupportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingMailComposer = false
    @State private var showingMailAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image("SunshadeLogoNew")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Text("Help & Support")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("We're here to help you stay safe in the sun")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Contact Information
                    VStack(spacing: 16) {
                        SectionHeader(title: "Contact Us", icon: "envelope")
                        
                        VStack(spacing: 12) {
                            ContactItem(
                                icon: "envelope.fill",
                                title: "Email Support",
                                subtitle: "sunshadeapp@gmail.com",
                                action: {
                                    if MFMailComposeViewController.canSendMail() {
                                        showingMailComposer = true
                                    } else {
                                        showingMailAlert = true
                                    }
                                }
                            )
                            
                            ContactItem(
                                icon: "clock.fill",
                                title: "Response Time",
                                subtitle: "Usually within 24 hours",
                                action: nil
                            )
                        }
                    }
                    
                    // FAQ Section
                    VStack(spacing: 16) {
                        SectionHeader(title: "Frequently Asked Questions", icon: "questionmark.circle")
                        
                        VStack(spacing: 12) {
                            FAQItem(
                                question: "How accurate is the UV index data?",
                                answer: "We use real-time weather data from reliable meteorological services. The UV index is updated regularly to provide the most accurate information for your location."
                            )
                            
                            FAQItem(
                                question: "How does the safety timer work?",
                                answer: "The safety timer calculates your safe sun exposure time based on your skin type, current UV index, and SPF protection. It sends notifications when you should reapply sunscreen or seek shade."
                            )
                            
                            FAQItem(
                                question: "Can I use the app without location services?",
                                answer: "While the app works best with location services for accurate local UV data, you can manually set your location or use general UV recommendations."
                            )
                            
                            FAQItem(
                                question: "Is my data private and secure?",
                                answer: "Yes, your privacy is our priority. We only collect necessary data to provide our services and never share your personal information with third parties."
                            )
                        }
                    }
                    
                    // App Information
                    VStack(spacing: 16) {
                        SectionHeader(title: "App Information", icon: "info.circle")
                        
                        VStack(spacing: 12) {
                            InfoItem(title: "Version", value: "1.0.0")
                            InfoItem(title: "Build", value: "2024.1")
                            InfoItem(title: "Compatibility", value: "iOS 15.0+")
                        }
                    }
                    
                    // Feedback Section
                    VStack(spacing: 16) {
                        SectionHeader(title: "Feedback", icon: "heart")
                        
                        Text("Love the app? Have suggestions? We'd love to hear from you!")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            if MFMailComposeViewController.canSendMail() {
                                showingMailComposer = true
                            } else {
                                showingMailAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Feedback")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.primary)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
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
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: ["sunshadeapp@gmail.com"],
                subject: "Sunshade App Support",
                messageBody: """
                Hi Sunshade Support Team,
                
                App Version: 1.0.0
                Device: \(UIDevice.current.model)
                iOS Version: \(UIDevice.current.systemVersion)
                
                Please describe your issue or feedback below:
                
                
                """
            )
        }
        .alert("Mail Not Available", isPresented: $showingMailAlert) {
            Button("OK") { }
        } message: {
            Text("Please configure a mail account in your device settings or contact us directly at sunshadeapp@gmail.com")
        }
    }
}

struct SectionHeader: View {
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

struct ContactItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.textMuted)
                        .font(.system(size: 14))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 14))
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    HelpSupportView()
}