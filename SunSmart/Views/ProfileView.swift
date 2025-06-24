import SwiftUI

struct ProfileView: View {
    @ObservedObject private var userProfile = UserProfile.shared
    @ObservedObject private var exposureLog = ExposureLogManager.shared
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var showingLicenseTerms = false
    @State private var showingPrivacyNotice = false
    @State private var showingLegalDisclaimer = false
    
    // Computed properties for weekly statistics
    private var weeklyStats: (sessions: Int, totalTime: String, avgUV: String) {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of current week (Sunday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return (0, "0m", "0.0")
        }
        
        // Filter sessions from this week
        let weekSessions = exposureLog.sessions.filter { session in
            session.startTime >= weekStart && session.startTime <= now
        }
        
        let sessionCount = weekSessions.count
        let totalDuration = weekSessions.reduce(0) { $0 + $1.duration }
        let avgUV = weekSessions.isEmpty ? 0.0 : weekSessions.reduce(0) { $0 + $1.uvIndex } / Double(weekSessions.count)
        
        // Format total time
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        let timeString = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        
        return (sessionCount, timeString, String(format: "%.1f", avgUV))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
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
                                
                                Spacer()
                            }
                        }
                        
                        Text("SunSmart User")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
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
                    
                    if weeklyStats.sessions > 0 {
                        HStack {
                            StatItem(title: "Sessions", value: "\(weeklyStats.sessions)", color: AppColors.primary)
                            StatItem(title: "Total Time", value: weeklyStats.totalTime, color: AppColors.success)
                            StatItem(title: "Avg UV", value: weeklyStats.avgUV, color: AppColors.warning)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "sun.max")
                                .font(.title2)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text("No sun exposure this week")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textMuted)
                            
                            Text("Start using the safety timer to track your sessions")
                                .font(.caption)
                                .foregroundColor(AppColors.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 20)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                // Privacy & Legal Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(AppColors.primary)
                            .font(.title3)
                        
                        Text("Privacy & Legal")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        LegalMenuItem(
                            icon: "doc.text",
                            title: "License & Terms of Use",
                            action: {
                                showingLicenseTerms = true
                            }
                        )
                        
                        Divider()
                            .background(AppColors.backgroundSecondary)
                        
                        LegalMenuItem(
                            icon: "hand.raised",
                            title: "Privacy Notice",
                            action: {
                                showingPrivacyNotice = true
                            }
                        )
                        
                        Divider()
                            .background(AppColors.backgroundSecondary)
                        
                        LegalMenuItem(
                            icon: "exclamationmark.triangle",
                            title: "Legal Disclaimer",
                            action: {
                                showingLegalDisclaimer = true
                            }
                        )
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
            .sheet(isPresented: $showingLicenseTerms) {
                LicenseTermsView()
            }
            .sheet(isPresented: $showingPrivacyNotice) {
                PrivacyNoticeView()
            }
            .sheet(isPresented: $showingLegalDisclaimer) {
                LegalDisclaimerView()
            }
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

struct LegalMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textMuted)
                    .font(.system(size: 14))
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}