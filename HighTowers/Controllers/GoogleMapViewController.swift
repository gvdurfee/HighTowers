//
//  GoogleMapViewController.swift
//  HighTowers
//
//  Created by Greg Durfee on 2/28/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import UIKit


class GoogleMapViewController: UIViewController, UITextFieldDelegate {
    
    //Create outlets for scroll view and text fields.
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var latitudeDegrees: UITextField!
    
    @IBOutlet var latitudeMinutes: UITextField!
    
    @IBOutlet var towerBaseElevation: UITextField!
    
    @IBOutlet var longitudeDegrees: UITextField!
    
    @IBOutlet var longitudeMinutes: UITextField!
    
    @IBOutlet var mapDirectionsText: UITextView!
    
    //These two variables will hold the camera coordinates for the Google Map
    var passedLatitude: Double?
    var passedLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(passedLatitude as Any, passedLongitude as Any)
        
        // Establish GoogleMapViewController as the controller of its text fields.
        latitudeDegrees.delegate = self
        latitudeMinutes.delegate = self
        towerBaseElevation.delegate = self
        longitudeDegrees.delegate = self
        longitudeMinutes.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
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
        return true
        
        // Do any additional setup after loading the view.
    }
    
    
        // MARK: - Navigation & Prepare for Segue Back to the SelectedImageView
        
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
