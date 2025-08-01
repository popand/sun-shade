import SwiftUI
import AudioToolbox

struct SafetyTimerView: View {
    @State private var remainingTime: TimeInterval = 0
    @State private var isTimerRunning = false
    @State private var selectedMinutes = 15
    @State private var sessionStartTime: Date?
    @State private var timer: Timer?
    
    @ObservedObject private var exposureLog = ExposureLogManager.shared
    @ObservedObject private var dashboardViewModel: DashboardViewModel
    
    init(dashboardViewModel: DashboardViewModel) {
        self.dashboardViewModel = dashboardViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                
                ZStack {
                    Circle()
                        .stroke(AppColors.backgroundTertiary, lineWidth: 15)
                        .frame(width: 200, height: 200)
                    
                    if remainingTime > 0 {
                        Circle()
                            .trim(from: 0, to: remainingTime / (Double(selectedMinutes) * 60))
                            .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    VStack {
                        Text(timeString(from: remainingTime))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(isTimerRunning ? "Remaining" : "Set Timer")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                if !isTimerRunning {
                    Picker("Minutes", selection: $selectedMinutes) {
                        ForEach([10, 15, 20, 25, 30], id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                
                Button(action: toggleTimer) {
                    Text(isTimerRunning ? "Stop Timer" : "Start Timer")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isTimerRunning ? AppColors.danger : AppColors.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Activity Log Card
                ActivityLogCard(exposureLog: exposureLog)
                
                Spacer(minLength: 10)
            }
            .navigationTitle("Safety Timer")
        }
    }
    
    func toggleTimer() {
        if isTimerRunning {
            stopTimer(timerCompleted: false)
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        isTimerRunning = true
        sessionStartTime = Date()
        remainingTime = Double(selectedMinutes * 60)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopTimer(timerCompleted: true)
            }
        }
    }
    
    func stopTimer(timerCompleted: Bool = false) {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        // Play alarm sound if timer completed naturally
        if timerCompleted {
            playAlarmSound()
            print("🔔 Timer completed - alarm played")
        }
        
        // Log the session if it ran for at least 10 seconds
        if let startTime = sessionStartTime {
            let actualDuration = Date().timeIntervalSince(startTime)
            print("⏱️ Timer stopped. Duration: \(actualDuration) seconds")
            if actualDuration >= 10 {
                print("✅ Duration >= 10s, logging session")
                logExposureSession(startTime: startTime, actualDuration: actualDuration)
            } else {
                print("⚠️ Duration < 10s, not logging session")
            }
        } else {
            print("❌ No start time found")
        }
        
        remainingTime = 0
        sessionStartTime = nil
    }
    
    private func logExposureSession(startTime: Date, actualDuration: TimeInterval) {
        print("🔄 Creating session with location: '\(dashboardViewModel.currentLocation)', UV: \(dashboardViewModel.currentUVIndex), temp: \(dashboardViewModel.temperature)")
        
        let session = ExposureSession(
            startTime: startTime,
            endTime: Date(),
            duration: actualDuration,
            location: dashboardViewModel.currentLocation,
            latitude: nil, // Could be added if needed
            longitude: nil, // Could be added if needed
            uvIndex: dashboardViewModel.currentUVIndex,
            temperature: dashboardViewModel.temperature
        )
        
        exposureLog.addSession(session)
        print("🎯 Session added to log")
    }
    
    private func playAlarmSound() {
        // Play system sound - try multiple options for best compatibility
        
        // Option 1: Try default alarm sound
        AudioServicesPlaySystemSound(1005) // Sound ID for default alarm
        
        // Option 2: Add vibration for additional feedback
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // Option 3: Alternative sound if available
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioServicesPlaySystemSound(1013) // Sound ID for alarm tone
        }
        
        print("🔊 Playing alarm sound and vibration")
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ActivityLogCard: View {
    @ObservedObject var exposureLog: ExposureLogManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Exposure Sessions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if !exposureLog.sessions.isEmpty {
                    Button("Clear Log") {
                        exposureLog.clearLog()
                    }
                    .font(.caption)
                    .foregroundColor(AppColors.danger)
                }
            }
            
            if exposureLog.sessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sun.max")
                        .font(.title2)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text("No exposure sessions yet")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text("Start a timer to track your sun exposure")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(exposureLog.sessions.prefix(5)) { session in
                            ExposureSessionRow(session: session)
                        }
                        
                        if exposureLog.sessions.count > 5 {
                            Text("+ \(exposureLog.sessions.count - 5) more sessions")
                                .font(.caption)
                                .foregroundColor(AppColors.textMuted)
                                .padding(.top, 8)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

struct ExposureSessionRow: View {
    let session: ExposureSession
    @ObservedObject private var userProfile = UserProfile.shared
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 8, height: 8)
                
                Rectangle()
                    .fill(AppColors.backgroundTertiary)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.dateString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(session.durationString)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text(session.timeOfDay)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text(session.location)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "sun.max")
                        .font(.caption)
                        .foregroundColor(AppColors.warning)
                    
                    Text("UV \(Int(session.uvIndex))")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "thermometer")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                    
                    Text("\(Int(userProfile.temperatureUnit.convert(from: Double(session.temperature)).rounded()))°\(userProfile.temperatureUnit.symbol)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppColors.backgroundSecondary.opacity(0.5))
        .cornerRadius(12)
    }
}