import Foundation
import CoreLocation

struct ExposureSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let location: String
    let latitude: Double?
    let longitude: Double?
    let uvIndex: Double
    let temperature: Int
    
    init(startTime: Date, endTime: Date, duration: TimeInterval, location: String, latitude: Double?, longitude: Double?, uvIndex: Double, temperature: Int) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.uvIndex = uvIndex
        self.temperature = temperature
    }
    
    var timeOfDay: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startTime)
    }
    
    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

class ExposureLogManager: ObservableObject {
    @Published var sessions: [ExposureSession] = []
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "exposureSessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(_ session: ExposureSession) {
        print("📝 Adding session: \(session.durationString) at \(session.timeOfDay)")
        sessions.insert(session, at: 0) // Add to beginning for most recent first
        print("📊 Total sessions now: \(sessions.count)")
        saveSessions()
    }
    
    func clearLog() {
        sessions.removeAll()
        saveSessions()
    }
    
    private func saveSessions() {
        do {
            let encoded = try JSONEncoder().encode(sessions)
            userDefaults.set(encoded, forKey: sessionsKey)
            print("💾 Successfully saved \(sessions.count) sessions")
        } catch {
            print("❌ Failed to save sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        guard let data = userDefaults.data(forKey: sessionsKey) else {
            print("📂 No saved sessions found")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([ExposureSession].self, from: data)
            sessions = decoded
            print("📂 Loaded \(sessions.count) sessions")
        } catch {
            print("❌ Failed to load sessions: \(error)")
        }
    }
    
    static let shared = ExposureLogManager()
} 