//
//  LocationManager.swift
//  Assassination
//
//  Created by Dylan on 5/13/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let manager = LocationManager()

class LocationManager: CLLocationManager {
    
    var isLocating : Bool = false
    
    class var sharedManager : LocationManager {
        return manager
    }
    
    func startLocating(delegate : CLLocationManagerDelegate) {
        
            self.delegate = delegate
        
            if(!isLocating) {
                    self.requestAlwaysAuthorization()
                    self.desiredAccuracy = kCLLocationAccuracyBest
                    self.startUpdatingLocation()
                    isLocating = true
                    print("Locating")
            }
    }
}