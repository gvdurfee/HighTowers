//
//  GoogleMapViewController.swift
//  HighTowers
//
//  Created by Greg Durfee on 2/28/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class GoogleMapViewController: UIViewController, UITextFieldDelegate {
    
    //Create outlets for scroll view and text fields.
    
    @IBOutlet var google_Map: GMSMapView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var latitudeDegrees: UITextField!
    
    @IBOutlet var latitudeMinutes: UITextField!
    
    @IBOutlet var towerBaseElevation: UITextField!
    
    @IBOutlet var longitudeDegrees: UITextField!
    
    @IBOutlet var longitudeMinutes: UITextField!
    
    @IBOutlet var mapDirectionsText: UITextView!
    
    //Prepare Buttons for round corners and borders
    
    @IBOutlet var recordMapData: UIButton!
    
    @IBOutlet var sendCoordinatesManually: UIButton!
    
    @IBOutlet var sendCoordinatesFromMap: UIButton!
    
    
    //These variables will hold the camera coordinates for the Google Map
    var passedLatitude: Double = 0.0
    var passedLongitude: Double = 0.0
    var passedBearing: Double = 0.0
    var tower = Tower()
    var marker = GMSMarker()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Establish GoogleMapViewController as the controller of its text fields.
        latitudeDegrees.delegate = self
        latitudeMinutes.delegate = self
        towerBaseElevation.delegate = self
        longitudeDegrees.delegate = self
        longitudeMinutes.delegate = self
        
        //Keyboard observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        formatControlsAndViews()
        //Set up camera position with coordinates of interest
        let camera = GMSCameraPosition.camera(withLatitude: passedLatitude, longitude: passedLongitude, zoom: 13)
        google_Map.camera = camera
        google_Map.mapType = .hybrid

    }
    
    //MARK: - Centered Google Map and Marker.
    /***************************************************************/
    
    //This function adds a marker and centers the map on the marker.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add Marker
        marker.isDraggable = true
        marker.title = "Airborne Camera Location"
        marker.position = CLLocationCoordinate2DMake(passedLatitude, passedLongitude)
        marker.map = google_Map
        
        // Center camera to marker position
        google_Map.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 15)
        
    }
    //Move the marker from the aircraft camera location to the estimated tower location.
    @objc func moveMarker(){
        let gpsFormat = GPSFormat()
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
        marker.title = "Tower Location"
    }
    
    

    
    //MARK: - Take care of object formatting.
    /***************************************************************/
    fileprivate func formatControlsAndViews() {
        //Adjust buttons for rounded corners and borders
        recordMapData.layer.cornerRadius = 10
        recordMapData.clipsToBounds = true
        recordMapData.layer.borderWidth = 1
        recordMapData.layer.borderColor = UIColor.black.cgColor
        
        sendCoordinatesManually.layer.cornerRadius = 10
        sendCoordinatesManually.clipsToBounds = true
        sendCoordinatesManually.layer.borderWidth = 1
        sendCoordinatesManually.layer.borderColor = UIColor.black.cgColor
        
        sendCoordinatesFromMap.layer.cornerRadius = 10
        sendCoordinatesFromMap.clipsToBounds = true
        sendCoordinatesFromMap.layer.borderWidth = 1
        sendCoordinatesFromMap.layer.borderColor = UIColor.black.cgColor
        
        mapDirectionsText.layer.cornerRadius = 5
    }
    
    //Change to white text due to dark background.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Keyboard management functions
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
    
    //MARK: - Left to right order of manual filling of text fields.
    /***************************************************************/
    
    //Establish the order of filling text fields when only manually entered information is avaliable. User's information is loaded left to right and the keyboard is dismissed after longitudeMinutes is loaded.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case latitudeDegrees:
            latitudeMinutes.becomeFirstResponder()
        case latitudeMinutes:
            towerBaseElevation.becomeFirstResponder()
        case towerBaseElevation:
            longitudeDegrees.becomeFirstResponder()
        case longitudeDegrees:
            longitudeMinutes.becomeFirstResponder()
        case longitudeDegrees:
            longitudeMinutes.becomeFirstResponder()
        default:
            longitudeMinutes.resignFirstResponder()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(moveMarker), userInfo: nil, repeats: true)
        return true
        
    }
    
    // MARK: - Navigation, Sending Coordinates & Prepare for Segue Back to the SelectedImageView
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //If Google Map data is used, the marker position will be used to populate the text fields with corridinates and tower elevation.
    @IBAction func recordMapData(_ sender: UIButton) {
        
    }
    //If Google Map data can't be used, then the coordinates and elevation will be passed with this control.
    @IBAction func sendCoordinatesManually(_ sender: UIButton) {
    }
    
    //If Google Map data is used, then the coordinates and elevation will be passed with this control.
    @IBAction func sendCoordinatesFromMap(_ sender: UIButton) {
        
    }
    
}
extension GoogleMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Clicked on Marker")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        marker.position = coordinate
    }
}
