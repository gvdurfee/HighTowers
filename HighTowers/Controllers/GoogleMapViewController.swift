//
//  GoogleMapViewController.swift
//  HighTowers
//
//  Created by Greg Durfee on 2/28/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

//1. The protocol declaration
protocol GoogleMVCDelegate {
    func transferTowerData(_ latitude: Double, _ longitude: Double, _ elevation: Double)
}


import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire




class GoogleMapViewController: UIViewController, UITextFieldDelegate {
    
    //2. Declare the delegate variable
    var delegate: GoogleMVCDelegate?
    
    //Create outlets for scroll view and text fields.
    
    @IBOutlet var google_Map: GMSMapView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var latitudeDegrees: UITextField!
    
    @IBOutlet var latitudeMinutes: UITextField!
    
    @IBOutlet var towerBaseElevation: UITextField!
    
    @IBOutlet var longitudeDegrees: UITextField!
    
    @IBOutlet var longitudeMinutes: UITextField!
    
    @IBOutlet var mapDirectionsText: UITextView!
    
    @IBOutlet var coordinateContainer: UIView!
    
    //Prepare Buttons for round corners and borders
    
    @IBOutlet var recordMapData: UIButton!
    @IBOutlet var validateFlyBy: UIButton!
    
    
    //These variables will hold the camera coordinates for the Google Map
    var passedLatitude: Double = 0.0
    var passedLongitude: Double = 0.0
    var passedBearing: Double = 0.0
    var marker = GMSMarker()
    var timer = Timer()
    var gpsFormat = GPSFormat()
    
    
    //Change to Status Bar to white text due to dark background.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Take care of storyboard object formatting.
    /***************************************************************/
    fileprivate func formatControlsAndViews() {
        //Adjust buttons for rounded corners and borders
        recordMapData.layer.cornerRadius = 10
        recordMapData.clipsToBounds = true
        recordMapData.layer.borderWidth = 1
        recordMapData.layer.borderColor = UIColor.black.cgColor
        
        validateFlyBy.layer.cornerRadius = 10
        validateFlyBy.clipsToBounds = true
        validateFlyBy.layer.borderWidth = 1
        validateFlyBy.backgroundColor = UIColor.white
        validateFlyBy.layer.borderColor = UIColor.blue.cgColor

        //Adjust Direction Text and Coordinate Container views to have rounded corners
        mapDirectionsText.layer.cornerRadius = 5
        coordinateContainer.layer.cornerRadius = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Populate the initial Map Directions text
        mapDirectionsText.text = #"The Google Map has been loaded with a marker located in the center. The marker indicates the location of your aircraft when the picture was taken. Populate the latitude and longitude text with the position estimate of the "fly by" location. Once you've done this, press the "Validate Fly-By Coordinates" button. If one or more text boxes have the wrong formats, you'll see a popup that indicates the needed correction(s). Press the "OK" buttons, and make the corrections needed to proceed, pressing the vaildate button after each correction. The last popup will indicate success. After pressing the "OK" button, then press the "Return" key on the keyboard, and the marker will move to the fly by coordinates. You can then zoom and pan, if necessary, to find the tower on the map, then tap on the tower base location you see on the map. The marker and map view will move to that location; then press "Record Map Data"."#
        
        // Establish GoogleMapViewController as the controller of its text fields.
        latitudeDegrees.delegate = self
        latitudeMinutes.delegate = self
        longitudeDegrees.delegate = self
        longitudeMinutes.delegate = self
        
        //Selecting this keyboard type for the four text fields frees the user from having to tap the "123" button each time a text field is selected.
        latitudeDegrees.keyboardType = .decimalPad
        latitudeMinutes.keyboardType = .decimalPad
        longitudeDegrees.keyboardType = .decimalPad
        longitudeMinutes.keyboardType = .decimalPad
        
        //Keyboard observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        formatControlsAndViews()
    
        
        //Set up camera position with coordinates of interest
        let camera = GMSCameraPosition.camera(withLatitude: passedLatitude, longitude: passedLongitude, zoom: 13)
        google_Map.camera = camera
        google_Map.mapType = .hybrid
        google_Map.delegate = self
        
        // Initial state is disabled to make sure the user puts in "fly-by" coordinates
        recordMapData.isEnabled = false
        
    }
    
    
    //MARK: - Centered Google Map and Marker.
    /***************************************************************/
    
    //This function adds a marker and centers the map on the marker.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add Marker
        marker.isDraggable = true
        marker.title = "Aircraft Camera Location"
        marker.position = CLLocationCoordinate2DMake(passedLatitude, passedLongitude)
        marker.map = google_Map
        
        // Center camera to marker position
        google_Map.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 15)
        
    }
    //Move the marker from the aircraft camera location to the estimated tower location.
    @objc func moveMarker() {

        let lat = gpsFormat.getDecimalDegreesLatitude(degrees: latitudeDegrees.text!, minutes: latitudeMinutes.text!)
        let lon = gpsFormat.getDecimalDegreesLongitude(degrees: longitudeDegrees.text!, minutes: longitudeMinutes.text!)

        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            self.marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        google_Map.animate(to: GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 17))
        marker.position = CLLocationCoordinate2DMake(lat, lon)
        CATransaction.commit()

        marker.position = CLLocationCoordinate2DMake(lat, lon)
        marker.isDraggable = true
        marker.title = "Estimated Tower Location"
        
        mapDirectionsText.text = #"The map and marker positions have now moved to the "fly by" estimate position. The map view has zoomed in a bit more. If you see the actual tower location, tap once at the base of the tower. The marker will move to that position; then press the "Record Map Data" button. If you don't see the tower, you can move around using the pan and zoom iPad functions. If you can't find the actual tower, it may not yet be recorded by Google; if this is the case, just tap inside one the text boxes you filled in below and press the "Return" key again, to use the "fly by" position instead. Then press the "Record Map Data" button."#
        
    }
    
    //MARK: - Keyboard management functions and left to right order of manual filling of text fields.
    /***************************************************************/
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    
    //Make sure that only keyboard numbers and decimal point are the only characters availble to the user
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = "01234567890."
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
    
    //Establish the order of filling text fields when only manually entered information is avaliable. User's information is loaded left to right and the keyboard is dismissed after longitudeMinutes is loaded.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case latitudeDegrees:
            latitudeMinutes.becomeFirstResponder()
        case latitudeMinutes:
            longitudeDegrees.becomeFirstResponder()
        case longitudeDegrees:
            longitudeMinutes.becomeFirstResponder()
        default:
            longitudeMinutes.resignFirstResponder()
        }
        //Call moveMarker() in order to go to the approximate position of the tower
        moveMarker()
        return true
        
    }
    
    //MARK: - Validation and Alert Messaging
    /***************************************************************/
    
    //The magic happens here for validating user input text
    func validate() {
        do {
            let latDegrees = try latitudeDegrees.validatedText(validationType: ValidatorType.latitudeDegrees)
            let latMinutes = try latitudeMinutes.validatedText(validationType: ValidatorType.latitudeMinutes)
            let longDegrees = try longitudeDegrees.validatedText(validationType: ValidatorType.longitudeDegrees)
            let longMinutes = try longitudeMinutes.validatedText(validationType: ValidatorType.longitudeMinutes)
            let data = RegisterData(latDegrees: latDegrees, latMinutes: latMinutes, longDegrees: longDegrees, longMinutes: longMinutes)
            save(data)
            
        } catch(let error) {
            showAlert(for: (error as! ValidationError).message)
        }
    }
    
    //Success message to user after all text boxes were properly filled
    func save(_ data: RegisterData) {
        showAlert(for: "Validation of Tower Fly-By Corrdinates Successful")
        
        //Now that the Fly-By coordinates are properly formed, the map marker can move to the location.
        recordMapData.isEnabled = true
    }
    
    //This brings up an Alert with a message appropriate for the user to make the necessary correction.
    func showAlert(for alert: String) {
        let alertController = UIAlertController(title: nil, message: alert, preferredStyle: UIAlertController.Style.alert)
        alertController.setBackgroundColor(color: UIColor.white)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - JSON, Receiving Map Coordinates & Transfer Back to the SelectedImageViewController
    /***************************************************************/
    
    func getTowerLocationData(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        
        //Properly format the URL to be used for the Alamofire request.
        let googleURL = gpsFormat.formatURLString(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        //The Alamofire request will return the the JSON response including the elevation data for the tower base elevation.
        Alamofire.request(googleURL, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the Elevation data.")
                
                let elevationJSON: JSON = JSON(response.result.value!)
                print(elevationJSON)
                
                //Parse and pass the tower data to the Tower Model
                let tLat = elevationJSON["results"][0]["location"]["lat"].doubleValue
                let tLon = elevationJSON["results"][0]["location"]["lng"].doubleValue
                let tElev = elevationJSON["results"][0]["elevation"].doubleValue * 3.28084
                
                //5. self.tower.getTowerProperties(tLat, tLon, tElev)
                self.delegate?.transferTowerData(tLat, tLon, tElev)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.mapDirectionsText.text = "Internet Connection Issues"
            }
        }
    }
    
    
    //If Google Map data is used, the marker position will be used to populate the text fields with coordinates.
    @IBAction func recordMapData(_ sender: UIButton) {
        self.getTowerLocationData(marker.position.latitude, marker.position.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func validateFlyBy(_ sender: UIButton) {
        validate()
    }
    
}


// MARK: - GoogleMapViewController extension
/***************************************************************/
extension GoogleMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Clicked on Marker")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        
        //Move the marker to the tap position, then re-center the map.
        marker.position = coordinate
        google_Map.camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 18)
        
        marker.title = "Actual Tower Location"
        
    }
}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
}
