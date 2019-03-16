//
//  FormatText.swift
//  ToweringHeight
//
//  Created by Greg Durfee on 12/24/18.
//  Copyright © 2018 Durfee's Sandbox. All rights reserved.
//

import Foundation


//This class will handle the formatting of any GPS data (e.g. Latitude, Longitude and Altude) for building survey PDF report.
class GPSFormat {
    
    //This method takes raw latitude coordinate and formats to DD° MM.mm string
    func getDegreesLatitude(coordinate: Double) -> String {
        
        var cardinal: String
        let latitude = coordinate
        let latDegrees = Int(latitude)
        let minutes = latitude.truncatingRemainder(dividingBy: 1) * 60
        if latitude <= 0.0 {
            cardinal = "S"
        } else {
            cardinal = "N"
        }
        let formattedLat = String(format: "%@ %d° %.2f'", cardinal, abs(latDegrees), abs(minutes))
        return formattedLat
        
    }
    
    //This method takes raw longitude coordinate and formats to DDD° MM.mm string
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
        let formattedLong = String(format: "%@ %d° %.2f'", cardinal, abs(longDegrees), abs(minutes))
        return formattedLong
        
    }
    
    //This method takes DD° MM.mm' latitude and formats to DD.ddd° string
    func getDecimalDegreesLatitude(degrees: String, minutes: String) -> Double {
        let latDegrees = Double(degrees)
        let latMinutes = Double(minutes)
        let decimalLatitude = latDegrees! + latMinutes! / 60
        return decimalLatitude
    }
    
    //This method takes DDD° MM.mm' latitude and formats to DDD.ddd° string
    func getDecimalDegreesLongitude(degrees: String, minutes: String) -> Double {
        let latDegrees = Double(degrees)
        let latMinutes = Double(minutes)
        let decimalLongitude = (latDegrees! + latMinutes! / 60) * -1
        return decimalLongitude
    }
    
    
}
