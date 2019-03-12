import UIKit
import CoreLocation

//This method takes raw longitude coordinate and formats to D° MM.mm string
func getDegrees(coordinate: Double) -> String {
    
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

getDegrees(coordinate: -105.98387)







//Modify this so that the format is DD MM.MM

func getLocationDegreesFrom(longitude: Double) -> String {

    var longSeconds = Int(longitude * 3600)

    let longDegrees = longSeconds / 3600

    longSeconds = abs(longSeconds % 3600)

    let longMinutes = longSeconds / 60
        
    longSeconds %= 60

    
    

    return String(

        format: "%d° %d' \"%@",
        abs(longDegrees),
        longMinutes,
        longDegrees >= 0 ? "E" : "W"

    )

}

getLocationDegreesFrom(longitude: -105.98387)

//func resolveLatLongferences(coordinate: String ) -> Double {
//
//    switch coordinate {
//    case "N":
//        return 1.0
//
//    case "S":
//        return -1.0
//
//    case "E":
//        return 1.0
//
//    case "W":
//        return -1.0
//
//    default:
//        return 1.0
//    }
//}
//
//    let ref: String = "W"
//resolveLatLongferences(coordinate: ref)


//See if CoreLocation works to replace Haversine Function

let aircraftCoordinates = CLLocation(latitude:36.08531383333333, longitude:-105.98387)
let towerCoordinates = CLLocation(latitude: 36.088954, longitude:-106.02855)
let distanceInMeters = towerCoordinates.distance(from: aircraftCoordinates)
let distanceInFeet = distanceInMeters * 3.28084


func degreesToRadians(coordinate: Double) -> Double {
    let coordinateRAD = coordinate * Double.pi / 180
    return coordinateRAD
}

func radiansToDegrees(coordinate: Double) -> Double {
    let coordinateDegrees = coordinate * 180 / Double.pi
    return coordinateDegrees
}

func bearingFromLocation(fromLocation: CLLocation, toLocation: CLLocation) -> CLLocationDirection {
    
    var bearing: CLLocationDirection
    
    let fromLat = degreesToRadians(coordinate: aircraftCoordinates.coordinate.latitude)
    let fromLon = degreesToRadians(coordinate: aircraftCoordinates.coordinate.longitude)
    let toLat = degreesToRadians(coordinate: towerCoordinates.coordinate.latitude)
    let toLon = degreesToRadians(coordinate: towerCoordinates.coordinate.longitude)
    
    let y = sin(toLon - fromLon) * cos(toLat)
    let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(toLon - fromLon)
    bearing = radiansToDegrees( coordinate: atan2(y, x) ) as CLLocationDirection
    
    if bearing <= 0 {
        bearing = bearing + 360.0
    }
    
    print("The true bearing from the aircraft to the tower is \(String(format: "%.0f", bearing))°.")
    
    return bearing
}

let bearing = bearingFromLocation(fromLocation: aircraftCoordinates, toLocation: towerCoordinates)
