//
//  CameraMetaData.swift
//  HighTowers
//
//  Created by Greg Durfee on 12/5/18.
//  Copyright © 2018 Durfee's Sandbox. All rights reserved.
//

import Foundation
import ImageIO


struct TowerCoordinates {
    
    
    //Map properties
    var towerBaseAltitudeMSL: Double = 0.0
    var towerLat: Double = 0.0
    var towerLon: Double = 0.0
    
    //Image measurement properties
    var verticalDistance = 0.0
    var distanceToBase = 0.0
    var distanceToTop = 0.0
    
    //Placeholders for tower location data
    mutating func towerData(towerBase: Double, towerLatitude: Double, towerLongitude: Double) {
        
        towerBaseAltitudeMSL = towerBase
        towerLat = towerLatitude
        towerLon = towerLongitude
    }
    
    mutating func receiveTowerImageMeasurement(totalHeightMeasure:Double, measureToObjectBase:Double, measureToObjectTop:Double) {
        
        verticalDistance = totalHeightMeasure
        distanceToBase = measureToObjectBase
        distanceToTop = measureToObjectTop
        
    }
    
//    mutating func towerMeasurementData() -> (Double, Double, Double, Double, Double, Double) {
//
//        let towerBaseMSL = towerBaseAltitudeMSL
//        let towerLatitude = towerLat
//        let towerLongitude = towerLon
//        let towerImageHeight = totalVerticalDistance
//        let imageBottomToTowerBase = distanceToObjectBase
//        let imageBottomToTowerTop = distanceToObjectTop
//
//        return (towerBaseMSL, towerLatitude, towerLongitude, towerImageHeight, imageBottomToTowerBase, imageBottomToTowerTop)
//    }
    
}

struct CameraMetaData {
    
    //Camera properties
    var metaData: Dictionary<NSObject, AnyObject>?
    var tiffMetaData: AnyObject?
    var exifMetaData: AnyObject?
    var gpsMetaData: AnyObject?
    var cameraModel: String = ""
    var cameraAltitudeMSL: Double = 0.0
    var cameraLatitude: Double = 0.0
    var cameraLatitudeREF: String = ""
    var cameraLongitude: Double = 0.0
    var cameraLongitudeREF: String = ""
    var focalLength: Double = 0.0
    var sensorHeight: Double = 24
    var towerCoordinates = TowerCoordinates()
    
    
    
        //MARK: - Extract necessary camera metadata
        /***************************************************************/
    mutating func extractMetaData(_ cameraData: Dictionary<NSObject, AnyObject>) {
        
        //Intialize image metadata dictionary from picked image and split tagged dictionaries from it.
        metaData = cameraData
        tiffMetaData = metaData![kCGImagePropertyTIFFDictionary] as! CFString
        exifMetaData = metaData![kCGImagePropertyExifDictionary] as! CFString
        gpsMetaData = metaData![kCGImagePropertyGPSDictionary] as! CFString
        //print(metaData as Any)
        
        //The multiplier converts altitude from meters to feet.
        cameraAltitudeMSL = gpsMetaData![kCGImagePropertyGPSAltitude] as! Double * 3.28084
        
        //The coordinate references need to be extracted before the coordinates themselves, in order have proper signs assigned
        cameraLatitudeREF = gpsMetaData![kCGImagePropertyGPSLatitudeRef] as! String
        cameraLongitudeREF = gpsMetaData![kCGImagePropertyGPSLongitudeRef] as! String
        
        cameraLatitude = gpsMetaData![kCGImagePropertyGPSLatitude] as! Double * resolveLatLongreferences(coordinate: cameraLatitudeREF)
        
        cameraLongitude = gpsMetaData![kCGImagePropertyGPSLongitude] as! Double * resolveLatLongreferences(coordinate: cameraLongitudeREF)
        
        focalLength = exifMetaData![kCGImagePropertyExifFocalLength] as! Double
        //print(metaData)
        
        //Check that the initialization is complete.
        
    }
    
    
//    //MARK: - Digital Zoom Factor for mobile device cameras
//    /***************************************************************/
//    mutating func digitalZoomFactor() -> Double {
//
//        /* This function resolves the question of whether Digital Zoom was applied to the image by the user. If Digital Zoom was applied, the property key will return a magnifaction factor that can be used to adjust the focal length of the lens. Otherwise, 1.0 will be returned to adjust focalLength. */
//        var zoomResult = exifMetaData
//            if zoomResult = nil {
//            print("There was a Digital Zoom")
//            return zoomResult
//
//        } else {
//            print("There was no Digital Zoom, the value was nil.")
//            zoomResult = 1.0
//            return zoomResult
//
//        }
//
//    }
    
    //Placeholders for tower location data
   
    
    //The Haversine function calculates distance between two sets of GPS locations and returns values distanceToTarget and degreesBearing
    func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> (Double) {
        
        //Convert degrees to radians for lats/longs
        let lat1rad = lat1 * Double.pi/180
        let lon1rad = lon1 * Double.pi/180
        let lat2rad = lat2 * Double.pi/180
        let lon2rad = lon2 * Double.pi/180
        
        let dLat = lat2rad - lat1rad
        let dLon = lon2rad - lon1rad
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad)
        let c = 2 * asin(sqrt(a))
        let R = 6372.8
        let distanceToTarget = R * c * 3280.84
        
        
        //Bearing calculation
        let y = sin(dLon) * cos(lat2rad)
        let x = cos(lat1rad) * sin(lat2rad) - sin(lat1rad) * cos(lat2rad) * cos(dLon)
        let radiansBearing = atan2(y, x)
        var degreesBearing = radiansBearing * 180 / Double.pi
        
        if degreesBearing < 0 {
            degreesBearing = degreesBearing + 360
        }
        //print(degreesBearing)
        
        //return distance to target location in feet
        //print(distanceToTarget)
        return distanceToTarget
        
    }
    
    //The opposite angle is needed to calculate adjacent angle, which is needed to calculate tilt angle of the camera.
    mutating func oppositeAngle() -> Double {
        let cameraToTargetDistance = haversine(lat1: cameraLatitude, lon1: cameraLongitude, lat2: towerCoordinates.towerLat, lon2: towerCoordinates.towerLon)
        print(cameraLatitude)
        let cameraAltAboveTargetBase = cameraAltitudeMSL - towerCoordinates.towerBaseAltitudeMSL
        let oppositeAngleRAD = atan(cameraAltAboveTargetBase / cameraToTargetDistance)
        return oppositeAngleRAD
    }
    
    //MARK: - Angle of View Calculation
    /***************************************************************/
    
    //Calculate Angle of View for given focal length lens and sensor height
    func angleOfView(focalLength: Double) -> Double {
        
        let verticalLength = sensorHeight * Double.pi / 180
        let focalLengthRAD = focalLength * Double.pi / 180
        
        let aov = 2 * atan(verticalLength / (2 * focalLengthRAD))
        
        return aov * 180 / Double.pi
        
    }
    
    
    
    //Calculate Beta1
    func beta1(distanceToObjectBase:Double, totalVerticalDistance:Double) -> Double {
        
        let beta1RAD = angleOfView(focalLength: focalLength) * distanceToObjectBase / totalVerticalDistance
        return beta1RAD
    }
    
    //Calculate Beta2
    func beta2(distanceToObjectTop:Double, totalVerticalDistance:Double) -> Double {
        
        let beta2RAD = angleOfView(focalLength: focalLength) * distanceToObjectTop / totalVerticalDistance
        return beta2RAD
    }
    
    mutating func towerAGL() -> Double {
        
        let cameraAltAboveTargetBase = cameraAltitudeMSL - towerCoordinates.towerBaseAltitudeMSL
        let ninetyRAD = 90.0 * Double.pi/180
        let baseAngleRAD = oppositeAngle()
        let beta1Angle = beta1(distanceToObjectBase: towerCoordinates.distanceToBase, totalVerticalDistance: towerCoordinates.verticalDistance)
        let beta2Angle = beta2(distanceToObjectTop: towerCoordinates.distanceToTop, totalVerticalDistance: towerCoordinates.verticalDistance)
        let tiltAngle = ninetyRAD - baseAngleRAD - beta1Angle
        
        let towerHeight =  cameraAltAboveTargetBase * abs((1 - ((tan(tiltAngle + beta1Angle))/(tan(tiltAngle + beta2Angle)))))
        //print(towerHeight)
        return towerHeight
    }
    
    //MARK: - DDD MM.mm format required for reported Lat/Long
    /***************************************************************/
    
    //This method takes raw latitude coordinate and formats to D° MM.mm string
    func getDegreesLatitude(coordinate: Double) -> String {
        
        var cardinal: String
        let latitude = coordinate
        let latDegrees = Int(latitude)
        let minutes = latitude.truncatingRemainder(dividingBy: 1) * 60
        if latitude < 0.0 {
            cardinal = "S"
        }else {
            cardinal = "N"
        }
        let formattedLat = String(format: "%d° %.2f' %@", abs(latDegrees), abs(minutes), cardinal)
        return formattedLat
        
    }
    
    //This method takes raw longitude coordinate and formats to D° MM.mm string
    func getDegreesLongitude(coordinate: Double) -> String {
        
        var cardinal: String
        let longitude = coordinate
        let longDegrees = Int(longitude)
        let minutes = longitude.truncatingRemainder(dividingBy: 1) * 60
        if longitude < 0.0 {
            cardinal = "W"
        }else {
            cardinal = "E"
        }
        let formattedLong = String(format: "%d° %.2f' %@", abs(longDegrees), abs(minutes), cardinal)
        return formattedLong
        
    }
    
    
    //MARK: - Set proper signs for Latitude and Longitude based on hemispheres
    /***************************************************************/
    func resolveLatLongreferences(coordinate: String ) -> Double {
        
        switch coordinate {
        case "N":
            return 1.0
            
        case "S":
            return -1.0
            
        case "E":
            return 1.0
            
        case "W":
            return -1.0
            
        default:
            return 1.0
        }
        
    }
}

