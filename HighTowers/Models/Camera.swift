//
//  Camera.swift
//  HighTowers
//
//  Created by Greg Durfee on 2/10/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

/* The purpose of Camera is to hold structs that have anything
 to do with calculations using Camera image properties and methods.*/

import Foundation
import ImageIO
import CoreLocation

struct Camera {
    
    //Camera metadata variables needed for calculation
    var cameraAltitude: Double?
    var cameraLatitude: Double?
    var cameraLatitudeREF: String?
    var cameraLongitude: Double?
    var cameraLongitudeREF: String?
    var aircraftCoordinates: CLLocation?
    var cameraFocalLength: Double?
    var cameraModel: String?
    var cameraSensorHeight: Double = 0.0
    
    //The tower values will be passed from the SelectedImageViewController via the delegate function
    var towerLatitude: Double?
    var towerLongitude: Double?
    var towerElevation: Double?
    
    
    var distanceToTowerBase: Double?
    var cameraAltAboveTargetBase: Double?
    
    
    var totalVerticalMeasure: Float?
    var measureToObjectBase: Float?
    var measureToObjectTop: Float?
    
    
    //MARK: - Extract necessary camera metadata
    /***************************************************************/
    
    mutating func extractMetaData(_ cameraData: Dictionary<NSObject, AnyObject>) {
        
        //Intialize image metadata dictionary from picked image and split tagged dictionaries from it.
        let metaData = cameraData
        let tiffMetaData = metaData[kCGImagePropertyTIFFDictionary]
        let exifMetaData = metaData[kCGImagePropertyExifDictionary]
        let gpsMetaData = metaData[kCGImagePropertyGPSDictionary]
        
        
        //The multiplier converts altitude from meters to feet.
        cameraAltitude = gpsMetaData![kCGImagePropertyGPSAltitude] as! Double * 3.28084
        
        //The coordinate references need to be extracted before the coordinates themselves, in order have proper signs assigned
        cameraLatitudeREF = (gpsMetaData![kCGImagePropertyGPSLatitudeRef] as? String)!
        cameraLongitudeREF = (gpsMetaData![kCGImagePropertyGPSLongitudeRef] as? String)!
        
        // GPS coordinate references must be assigned the appropriate sign for the hemispheric locations because the camera metadata
        // only contains positive numbers.
        cameraLatitude = (gpsMetaData![kCGImagePropertyGPSLatitude] as? Double)! * resolveLatLongreferences(coordinate: cameraLatitudeREF!)
        
        cameraLongitude = (gpsMetaData![kCGImagePropertyGPSLongitude] as? Double)! * resolveLatLongreferences(coordinate: cameraLongitudeREF!)
        
        aircraftCoordinates = CLLocation(latitude: cameraLatitude!, longitude: cameraLongitude!)
        
        cameraFocalLength = (exifMetaData![kCGImagePropertyExifFocalLength] as? Double)!
        
        cameraModel = (tiffMetaData![kCGImagePropertyTIFFModel] as? String)
        
        cameraSensorHeight = sensorHeightAdjust(cameraName: cameraModel!)
        print(cameraModel as Any, cameraSensorHeight)
        
    }
    
    //MARK: - Set proper signs for the camera's Latitude and Longitude based on hemispheres
    /***************************************************************/
    mutating func resolveLatLongreferences(coordinate: String ) -> Double {
        
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
    
    //MARK: - Use CLLocation methods to determine camera to tower true bearing.
    /***************************************************************/
    
    mutating func bearingToTower() -> Double {
        
        let targetLatitude = towerLatitude
        let targetLongitude = towerLongitude
        let fromLat = degreesToRadians(coordinate: aircraftCoordinates!.coordinate.latitude)
        let fromLon = degreesToRadians(coordinate: aircraftCoordinates!.coordinate.longitude)
        let toLat = degreesToRadians(coordinate: (targetLatitude!))
        let toLon = degreesToRadians(coordinate: (targetLongitude!))
        
        let y = sin(toLon - fromLon) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(toLon - fromLon)
        
        var trueBearing = radiansToDegrees(coordinate: atan2(y, x)) as CLLocationDirection
        
        if trueBearing <= 0 {
            trueBearing = trueBearing + 360.0
        }
        
        print("The true bearing from the aircraft to the tower is \(String(format: "%.0f", trueBearing))°.")
        return trueBearing
    }
    
    // The following two functions take care of degree and radian conversions.
    mutating func degreesToRadians(coordinate: Double) -> Double {
        let coordinateRAD = coordinate * Double.pi / 180
        return coordinateRAD
    }
    
    mutating func radiansToDegrees(coordinate: Double) -> Double {
        let coordinateDegrees = coordinate * 180 / Double.pi
        return coordinateDegrees
    }

    //MARK: - Opposite Angle Calculation from Camera Altitude and Tower Elevaton distances
    /***************************************************************/
    
    //The opposite angle is needed to calculate adjacent angle, which is needed to calculate tilt angle of the camera.
    mutating func oppositeAngle() -> Double {
        let targetLatitude = towerLatitude
        let targetLongitude = towerLongitude
        
        let targetCoordinates = CLLocation(latitude: targetLatitude!, longitude: targetLongitude!)
        print(targetCoordinates)
        distanceToTowerBase = ((aircraftCoordinates!.distance(from: targetCoordinates))) * 3.28084
        let targetBaseAltitude = towerElevation
        cameraAltAboveTargetBase = cameraAltitude! - targetBaseAltitude!
        let oppositeAngleRAD = atan(cameraAltAboveTargetBase! / distanceToTowerBase!)
        print(oppositeAngleRAD)
        return oppositeAngleRAD
    }
    
    //MARK: - Set correct cameraSensorHieght
    /***************************************************************/
    
    mutating func sensorHeightAdjust(cameraName: String) -> Double {

        //Use cameraModel metadata to select appropriate case.
        switch cameraName {
        case "Canon EOS 5D Mark IV":
            return 24.0
        case "Canon EOS 5D Mark III":
            return 24.0
        case "D90":
            return 15.8
        case "D100":
            return 15.5
        case "D7100":
            return 15.6
        case "D7200":
            return 15.6
        default:
            return 15.6
        }
    }
    
    //MARK: - Angle of View Calculation
    /***************************************************************/
    
    //Calculate Angle of View for given focal length lens and sensor height
    func angleOfView(focalLength: Double) -> Double {
        
        let verticalLength = cameraSensorHeight * Double.pi / 180
        let focalLengthRAD = cameraFocalLength! * Double.pi / 180
        
        let aov = 2 * atan(verticalLength / (2 * focalLengthRAD))
        print(aov)
        return aov
        
    }
    
    mutating func gatherUserMeasurement(top: Float, bottom: Float, imageHeight: CGFloat) {
        measureToObjectTop = top
        measureToObjectBase = bottom
        totalVerticalMeasure = Float(imageHeight)
    }
    
    //MARK: - Tower Height Calculation
    /***************************************************************/
    mutating func towerAGL() -> String {
        
        let ninetyRAD = 90.0 * Double.pi/180
        let opposite: Double = oppositeAngle()
        let beta1Ratio = Double(measureToObjectBase! / totalVerticalMeasure!)
        let beta2Ratio = Double(measureToObjectTop! / totalVerticalMeasure!)
        let beta1 = angleOfView(focalLength: cameraFocalLength!) * beta1Ratio
        let beta2 = angleOfView(focalLength: cameraFocalLength!) * beta2Ratio
        
        let tiltAngle = ninetyRAD - opposite - beta1 - beta2
        
        let towerHeight =  Int(cameraAltAboveTargetBase! * abs((1 - ((tan(tiltAngle + beta1))/(tan(tiltAngle + beta2))))))
        print(towerHeight)
        return String(towerHeight)
        
    }
}


