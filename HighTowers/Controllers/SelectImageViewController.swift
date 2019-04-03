//
//  SelectImageViewController.swift
//  HighTowers
//
//  Created by Greg Durfee on 12/5/18.
//  Copyright © 2018 Durfee's Sandbox. All rights reserved.
//

import UIKit

//The Photo Library needs to come up in Landscape only to match the App standard orinetation.
//This extension overrides the supportedInterfaceOrientations to impose a Landscape limitation.

extension UIImagePickerController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

//3. Add the GoogleMVCDelegate to the class. Note that the text color indicates a developer designed delegate instead of Swift source code.
class SelectImageViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GoogleMVCDelegate {
    
    
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var directionsText: UITextView!
    @IBOutlet var topSlider: UISlider!
    @IBOutlet var baseSlider: UISlider!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var towerHeight: UITextField!
    @IBOutlet var towerHeightLabel: UILabel!
    @IBOutlet var resetApp: UIButton!
    @IBOutlet var goToMap: UIButton!
    @IBOutlet var submitForCalculation: UIButton!
    
    
    //Instantiate a Camera and Tower objects to receive properties necessary to calculate the tower height
    lazy var camera = Camera.init()
    lazy var tower = Tower()
    var gpsFormat = GPSFormat()
    
    //Lines is a Cocoa Touch file for configuring the measurement lines that allow the user to identify the top and base of the tower.
    var lines: Lines!
    
    //Allows access to AppDelegate function to reset the app to allow selection of another image
    let appDelegate = AppDelegate()
    
    
    
    //MARK: - Add UIImageView and enable TapGestureRecognizer
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatControlsAndViews()
        
        directionsText.text = "This is the beginning screen for the application. When you tap on the image, the iPad Photo Library will come up and you can select the image that you want to analyze. However, the image you select MUST HAVE GPS CONTENT. Otherwise, the application will not work. Once you've picked that image, the application takes you to the next screen."
        
        //Set image with tap instruction for user and adjust it to scrollView size
        imageView.image = UIImage(named: "TapTower2")
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        imageView.isUserInteractionEnabled = true
        containerView.addSubview(imageView)
        
        //Enable UITapGestureRecognizer in order to select image from the Photo Library
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.loadImage))
        tapGesture.numberOfTapsRequired = 1;
        imageView.addGestureRecognizer(tapGesture)
        
        
    }
    
    //MARK: - Take care of object formatting.
    /***************************************************************/
    fileprivate func formatControlsAndViews() {
        //Round the corners on the buttons
        submitForCalculation.layer.cornerRadius = 10
        submitForCalculation.clipsToBounds = true
        submitForCalculation.layer.borderWidth = 1
        submitForCalculation.layer.borderColor = UIColor.black.cgColor
        
        resetApp.layer.cornerRadius = 10
        resetApp.clipsToBounds = true
        resetApp.layer.borderWidth = 1
        resetApp.layer.borderColor = UIColor.black.cgColor
        
        goToMap.layer.cornerRadius = 10
        goToMap.clipsToBounds = true
        goToMap.layer.borderWidth = 1
        goToMap.layer.borderColor = UIColor.black.cgColor
        
        //Hide the sliders until the image is picked.
        topSlider.isHidden = true
        baseSlider.isHidden = true
        
        //Hide the other controls and fields until the image is picked.
        towerHeight.isHidden = true
        towerHeightLabel.isHidden = true
        resetApp.isHidden = true
        goToMap.isHidden = true
        submitForCalculation.isHidden = true
        
        //Setup first set of directions and give the text view rounded corners
        directionsText.layer.cornerRadius = 5
    }
    
    //Change to white text due to dark background.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: - Open the PhotoLibrary to select image
    /***************************************************************/
    
    //This function opens the PhotoLibrary in response to the tap.
    @objc  func loadImage(recognizer: UITapGestureRecognizer) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        directionsText.text = "If you're satisfied that this is the image you want to analyze, press the Go to Google Map button, which may allow you to locate the tower position accurately on the map. If this is not the image you want to analyze, press the Reset Application button to start over."
        
    }
    
    
    //The image selected is put into the imageView and centered; the zooming functionality is added and then the imagePicker is dismissed.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
        imageView.bounds = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        
        //Add the custon Lines view to create a measurement overlay for the selected image.
        viewWithSliders()
        
        //Present the other controls and fields
        //towerHeight.isHidden = false
        //towerHeightLabel.isHidden = false
        resetApp.isHidden = false
        goToMap.isHidden = false
        //submitForCalculation.isHidden = false
        
        
        //Determine the URL for the image picked in order for the Camera Model to extract and use the relevant image metadata.
        let path = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.imageURL)] as? URL
        let imageSource = CGImageSourceCreateWithURL(path! as CFURL , nil)
        let selectedImageMetaData = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as Dictionary<NSObject, AnyObject>
        camera.extractMetaData(selectedImageMetaData)
        
        // Dismiss the viewController
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //4. Here's the delegate protocol function stub.
    func transferTowerData(_ latitude: Double, _ longitude: Double, _ elevation: Double) {
        camera.towerLatitude = latitude
        camera.towerLongitude = longitude
        camera.towerElevation = elevation
        
        //Provide the next set of directions.
        directionsText.text = "The slider controls on either side will allow you to set a couple of measurement points. When you touch the red circle on the left and pull it down, a red line begins to descend from the top. Position the red line on the top of the tower in the image. Repeat this process on the right slider control by moving the blue line up to the base of the tower. Once you're satisfied the lines are positioned, press the Submit for Calculation button. The tower height will appear at the bottom."
        
        print("Here's the delegate protocol function.")
    }
    
    //MARK: - Set the UISliders and add the measure subView
    /***************************************************************/
    func viewWithSliders() {
        
        //Show the sliders, adjust to vertical and set their colors
        //topSlider.isHidden = false
        //baseSlider.isHidden = false
        
        
        //Rotate both sliders to vertical
        topSlider.transform = CGAffineTransform(scaleX: 2, y: 2)
        topSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        baseSlider.transform = CGAffineTransform(scaleX: 2, y: 2)
        baseSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        //Set color properties for sliders
        topSlider.thumbTintColor = UIColor.red
        topSlider.minimumTrackTintColor = UIColor.cyan
        topSlider.maximumTrackTintColor = UIColor.red
        
        baseSlider.thumbTintColor = UIColor.blue
        baseSlider.minimumTrackTintColor = UIColor.blue
        baseSlider.maximumTrackTintColor = UIColor.yellow
        
        //Adjust slider values and dimensions for different device sizes.
        topSlider.value = Float(containerView.bounds.height - containerView.bounds.height)
        topSlider.maximumValue = Float(containerView.bounds.height / 2)
        topSlider.minimumValue = Float(containerView.bounds.height - containerView.bounds.height)
        
        baseSlider.value = Float(containerView.frame.height)
        baseSlider.maximumValue = Float(containerView.bounds.height)
        baseSlider.minimumValue = Float(containerView.bounds.height / 2.5)
        
        
        let rect = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        lines = Lines(frame: rect)
        lines.center = containerView.center
        lines.backgroundColor = UIColor.clear
        view.center = containerView.center
        view.addSubview(lines)
        
        
    }
    //MARK: - User button controls
    /***************************************************************/
    
    @IBAction func topAdjust(_ sender: UISlider) {
        lines.topValue = sender.value
        
    }
    
    @IBAction func baseAdjust(_ sender: UISlider) {
        lines.baseValue = sender.value
    }
    
    
    @IBAction func resetApp(_ sender: UIButton) {
        appDelegate.resetApp()
    }
    
    //This action finishes the tower height calculation and presents the results needed for the Survey Log.
    @IBAction func submitForCalculation(_ sender: UIButton) {
        
        camera.gatherUserMeasurement(top: topSlider.value, bottom: baseSlider.value, imageHeight: containerView.bounds.height)
        print(topSlider.value, baseSlider.value, containerView.bounds.height)
        towerHeight.text = camera.towerAGL()
        
        //Prepare the information needed for the Survey Log entries.
        let towerAGL = String(camera.towerAGL())
        let towerBaseMSL = Int(camera.towerElevation!)
        let towerLatitudeDecimal = camera.towerLatitude
        let towerLatitude = gpsFormat.getDegreesLatitude(coordinate: towerLatitudeDecimal!)
        let towerLongitudeDecimal = camera.towerLongitude
        let towerLongitude = gpsFormat.getDegreesLongitude(coordinate: towerLongitudeDecimal!)
        let bearingTrue = Int(camera.bearingToTower())
        
        //Change the final directions text to red and use the text field to display the results needed for the survey log.
        directionsText.textColor = UIColor.red
        directionsText.text = " This tower is estimated to be \(towerAGL)' AGL. The tower base is located at \(towerBaseMSL)' MSL, Latitude: \(towerLatitude), Longitude: \(towerLongitude) and the true bearing from the camera to the tower was \(bearingTrue)°; you can use this information to fill out the entries needed for the Survey Log. Afterward, you can press the Reset Application to choose another image to analyze, or quit the application if you're done."
    }
    
    
    @IBAction func goToMap(_ sender: UIButton) {
        
        //Prepare to show controls and text once Google Map screen is dismissed.
        topSlider.isHidden = false
        baseSlider.isHidden = false
        towerHeightLabel.isHidden = false
        towerHeight.isHidden = false
        submitForCalculation.isHidden = false
        
        performSegue(withIdentifier: "goToMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMap" {
            let destinationVC = segue.destination as! GoogleMapViewController
            destinationVC.passedLatitude = camera.cameraLatitude!
            destinationVC.passedLongitude = camera.cameraLongitude!
            
            destinationVC.delegate = self
        } 
    }
    
}

//MARK: - Swift 4.2 helper functions
/***************************************************************/

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
