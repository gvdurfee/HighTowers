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
    var towerBaseAltitudeMSL = 6227.0
    var towerLat = 36.264
    var towerLon = -104.0348
    //var towerCoordinates = CLLocation?.self


    //Image measurement properties
    var verticalDistance = 0.0
    var distanceToBase = 0.0
    var distanceToTop = 0.0
    
    
    //Placeholders for tower location
    mutating func towerLocationData() -> CLLocation {
        let towerLocation = CLLocation(latitude: towerLat, longitude: towerLon)
        return towerLocation
    }

    
//    mutating func receiveTowerImageMeasurement(totalHeightMeasure:Double, measureToObjectBase:Double, measureToObjectTop:Double) {
//
//        verticalDistance = totalHeightMeasure
//        distanceToBase = measureToObjectBase
//        distanceToTop = measureToObjectTop
//        print(verticalDistance, distanceToBase, distanceToTop)
//
//    }
}
