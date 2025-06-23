import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var city: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    @Published var isLocationLoading: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        authorizationStatus = locationManager.authorizationStatus
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        isLocationLoading = true
        
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = "Location access not authorized. Please enable location permissions in Settings."
            isLocationLoading = false
            return
        }
        
        locationManager.requestLocation()
    }
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLocationLoading = false
                
                if let error = error {
                    self?.locationError = "Unable to determine location: \(error.localizedDescription)"
                    // Fallback to coordinates if reverse geocoding fails
                    let lat = String(format: "%.2f", location.coordinate.latitude)
                    let lon = String(format: "%.2f", location.coordinate.longitude)
                    self?.city = "Location: \(lat), \(lon)"
                    return
                }
                
                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    let country = placemark.country ?? ""
                    
                    if !city.isEmpty && !state.isEmpty {
                        self?.city = "\(city), \(state)"
                    } else if !city.isEmpty {
                        self?.city = city
                    } else if !state.isEmpty {
                        self?.city = state
                    } else if !country.isEmpty {
                        self?.city = country
                    } else {
                        // Ultimate fallback - show coordinates
                        let lat = String(format: "%.2f", location.coordinate.latitude)
                        let lon = String(format: "%.2f", location.coordinate.longitude)
                        self?.city = "Location: \(lat), \(lon)"
                    }
                } else {
                    // No placemark found - use coordinates
                    let lat = String(format: "%.2f", location.coordinate.latitude)
                    let lon = String(format: "%.2f", location.coordinate.longitude)
                    self?.city = "Location: \(lat), \(lon)"
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { 
            DispatchQueue.main.async {
                self.isLocationLoading = false
                self.locationError = "No location data received"
            }
            return 
        }
        
        DispatchQueue.main.async {
            self.location = location
            self.locationError = nil
        }
        
        reverseGeocode(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLocationLoading = false
            self.locationError = "Location error: \(error.localizedDescription)"
            
            // If we have a cached location, at least show coordinates
            if let location = self.location {
                let lat = String(format: "%.2f", location.coordinate.latitude)
                let lon = String(format: "%.2f", location.coordinate.longitude)
                self.city = "Location: \(lat), \(lon)"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationError = nil
                self.requestLocation()
            case .denied, .restricted:
                self.locationError = "Location access denied"
                self.city = "Location access denied"
            case .notDetermined:
                self.city = "Location permission required"
            @unknown default:
                break
            }
        }
    }

}