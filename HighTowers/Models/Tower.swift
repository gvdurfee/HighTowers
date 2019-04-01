//
//  Tower.swift
//  HighTowers
//
//  Created by Greg Durfee on 2/10/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import Foundation
import ImageIO
import CoreLocation


struct Tower {
    
    //Map properties
    //As a placeholder for now, provide target location data to the TargetLocation object to test the calculations
    
    init() {
        targetLatitude = 0.0
        targetLongitude = 0.0
        targetElevation = 0.0
    }
    
    // These computed properties will receive the tower data from getTowerProperties
    var targetLatitude: Double {
        didSet {
            print("This property is now \(targetLatitude)")
        }
    }
    var targetLongitude: Double {
        didSet {
            print("This property is now \(targetLongitude)")
        }
    }
    var targetElevation: Double {
        didSet{
            print("This property is now \(targetElevation)")
        }
    }
    
    //These properties will transfer tower data to the Camera Model
    var towerLatitude: Double {
        get {
            return targetLatitude
        }
    }
    
    var towerLongitude: Double {
        get {
            return targetLongitude
        }
    }
    
    var towerElevation: Double {
        get {
            return targetElevation
        }
    }
    
    //This function will pick up the tower data from JSON in the Alamofire function
    mutating func getTowerProperties(_ latitude: Double, _ longitude: Double, _ elevation: Double) {
        
        targetLatitude = latitude
        targetLongitude = longitude
        targetElevation = elevation
        print(targetLatitude as Any, targetLongitude as Any, targetElevation as Any)
        
    }
    
}
