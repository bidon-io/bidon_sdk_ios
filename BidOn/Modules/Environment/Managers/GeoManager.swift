//
//  GeoManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation
import CoreLocation


final class GeoManager: NSObject, Geo {
    var lat: Double = 0
    var lon: Double = 0
    
    var completion: EnvironmentManagerCompletion?
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    var isAvailable: Bool {
        let status: CLAuthorizationStatus
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}


extension GeoManager: EnvironmentManager {
    func prepare(completion: @escaping EnvironmentManagerCompletion) {
        self.completion = completion
        locationManager.startUpdatingLocation()
    }
}


extension GeoManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {        
        guard let location = locations.first else { return }
        
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        
        
        let ceo = CLGeocoder()
        ceo.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            defer {
                self?.completion?()
                self?.completion = nil
            }
            
            guard let placemark = placemarks?.first else { return }
            
        }
    }
}
