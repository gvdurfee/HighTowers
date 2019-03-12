//
//  HeightCalculator.swift
//  ToweringHeight
//
//  Created by Greg Durfee on 4/14/18.
//  Copyright © 2018 Durfee's Sandbox. All rights reserved.
//

//import Foundation
//import CoreLocation
//
////HeightCalculation is the class responsible for supplying all of the calculated results that are neccessary to finally calculate the height of the tower.
//class HeightCalculation {
//
//    //Camera data properties
//    var cameraToTargetDistance: Double = 0
//    var cameraAltitudeMSL: Double = 0
//    var cameraLat: Double = 0
//    var cameraLon: Double = 0
//    var focalLength: Double = 0
//    var sensorHeight: Double = 24
//
//    //Target and image measurement properties
//    var towerBaseAltitudeMSL: Double = 0
//    var towerLat: Double = 0
//    var towerLon: Double = 0
//    var totalVerticalDistance: Double = 0
//    var distanceToObjectBase: Double = 0
//    var distanceToObjectTop: Double = 0
//
//    var cameraProperties = CameraMetaData()
//
//    //Placeholders for tower location data
//    func towerData(towerBase: Double, towerLatitude: Double, towerLongitude: Double) {
//
//        towerBaseAltitudeMSL = towerBase
//        towerLat = towerLatitude
//        towerLon = towerLongitude
//    }
//
//    //The Haversine function calculates distance between two sets of GPS locations and returns values distanceToTarget and degreesBearing
//    func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> (Double) {
//
//        //Convert degrees to radians for lats/longs
//        let lat1rad = lat1 * Double.pi/180
//        let lon1rad = lon1 * Double.pi/180
//        let lat2rad = lat2 * Double.pi/180
//        let lon2rad = lon2 * Double.pi/180
//
//        let dLat = lat2rad - lat1rad
//        let dLon = lon2rad - lon1rad
//        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad)
//        let c = 2 * asin(sqrt(a))
//        let R = 6372.8
//        let distanceToTarget = R * c * 3280.84
//
//        //Bearing calculation
//        let y = sin(dLon) * cos(lat2rad)
//        let x = cos(lat1rad) * sin(lat2rad) - sin(lat1rad) * cos(lat2rad) * cos(dLon)
//        let radiansBearing = atan2(y, x)
//        var degreesBearing = radiansBearing * 180 / Double.pi
//
//        if degreesBearing < 0 {
//            degreesBearing = degreesBearing + 360
//        }
//        //print(degreesBearing)
//
//        //return distance to target location in feet
//        //print(distanceToTarget)
//        return distanceToTarget
//
//    }
//
//
//    //The opposite angle is needed to calculate adjacent angle, which is needed to calculate tilt angle of the camera.
//    func oppositeAngle() -> Double {
//        let cameraToTargetDistance = haversine(lat1: cameraLat, lon1: cameraLon, lat2: towerLat, lon2: towerLon)
//        let cameraAltitude = cameraAltitudeMSL - towerBaseAltitudeMSL
//        let oppositeAngleRAD = atan(cameraAltitude / cameraToTargetDistance)
//        return oppositeAngleRAD
//    }
//
//    //MARK: - Angle of View Calculation
//    /***************************************************************/
//
//    //Calculate Angle of View for given focal length lens and sensor height
//    func angleOfView(focalLength: Double) -> Double {
//
//        let verticalLength = sensorHeight * Double.pi / 180
//        let focalLengthRAD = focalLength * Double.pi / 180
//
//        let aov = 2 * atan(verticalLength / (2 * focalLengthRAD))
//
//        return aov * 180 / Double.pi
//
//    }
//
//    func receiveTowerImageMeasurement(totalHeightMeasure:Double, measureToObjectBase:Double, measureToObjectTop:Double) {
//
//        totalVerticalDistance = totalHeightMeasure
//        print(totalVerticalDistance)
//        distanceToObjectBase = measureToObjectBase
//        distanceToObjectTop = measureToObjectTop
//
//    }
//
//    //Calculate Beta1
//    func beta1(distanceToObjectBase:Double, totalVerticalDistance:Double) -> Double {
//
//        let beta1RAD = angleOfView(focalLength: focalLength) * distanceToObjectBase / totalVerticalDistance
//        return beta1RAD
//    }
//
//    //Calculate Beta2
//    func beta2(distanceToObjectTop:Double, totalVerticalDistance:Double) -> Double {
//
//        let beta2RAD = angleOfView(focalLength: focalLength) * distanceToObjectTop / totalVerticalDistance
//        return beta2RAD
//    }
//
//    func towerAGL() -> Double {
//        let cameraAltitude = cameraAltitudeMSL - towerBaseAltitudeMSL
//        print(cameraAltitudeMSL)
//        let ninetyRAD = 90.0 * Double.pi/180
//        let baseAngleRAD = oppositeAngle()
//        let beta1Angle = beta1(distanceToObjectBase: distanceToObjectBase, totalVerticalDistance: totalVerticalDistance)
//        let beta2Angle = beta2(distanceToObjectTop: distanceToObjectTop, totalVerticalDistance: totalVerticalDistance)
//        let tiltAngle = ninetyRAD - baseAngleRAD - beta1Angle
//
//        let towerHeight =  cameraAltitude * abs((1 - ((tan(tiltAngle + beta1Angle))/(tan(tiltAngle + beta2Angle)))))
//        print(towerHeight)
//        return towerHeight
//    }
//}







