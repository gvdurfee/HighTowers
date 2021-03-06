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

class SelectImageViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    var camera = Camera.init()
    var tower = Tower()
    
    //Lines is a Cocoa Touch file for configuring the measurement lines that allow the user to identify the top and base of the tower.
    var lines: Lines!
    
    //Allows access to AppDelegate function to reset the app to allow selection of another image
    let appDelegate = AppDelegate()
    
    
    
    //MARK: - Add UIImageView and enable TapGestureRecognizer
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Round the corners on the buttons
        submitForCalculation.layer.cornerRadius = 10
        submitForCalculation.clipsToBounds = true
        submitForCalculation.layer.borderWidth = 2
        submitForCalculation.layer.borderColor = UIColor.black.cgColor
        
        resetApp.layer.cornerRadius = 10
        resetApp.clipsToBounds = true
        resetApp.layer.borderWidth = 2
        resetApp.layer.borderColor = UIColor.black.cgColor
        
        goToMap.layer.cornerRadius = 10
        goToMap.clipsToBounds = true
        goToMap.layer.borderWidth = 2
        goToMap.layer.borderColor = UIColor.red.cgColor
        
        //Hide the sliders until the image is picked.
        topSlider.isHidden = true
        baseSlider.isHidden = true
        
        //Hide the other controls and fields until the image is picked.
        towerHeight.isHidden = true
        towerHeightLabel.isHidden = true
        resetApp.isHidden = true
        goToMap.isHidden = true
        submitForCalculation.isHidden = true
        
        //Setup first set of directions
        directionsText.text = "This is the beginning screen for the application. When you tap on the image, the iPad Photo Library will come up and you can select the image that you want to analyze. Once you've picked that image, the application returns you to the next screen."
        
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
    
    
    //MARK: - Open the PhotoLibrary to select image
    /***************************************************************/
    
    //This function opens the PhotoLibrary in response to the tap.
    @objc  func loadImage(recognizer: UITapGestureRecognizer) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
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
        towerHeight.isHidden = false
        towerHeightLabel.isHidden = false
        resetApp.isHidden = false
        goToMap.isHidden = false
        submitForCalculation.isHidden = false
        
        
        //Determine the URL for the image picked in order for the Camera Model to extract and use the relevant image metadata.
        let path = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.imageURL)] as? URL
        let imageSource = CGImageSourceCreateWithURL(path! as CFURL , nil)
        let selectedImageMetaData = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as Dictionary<NSObject, AnyObject>
        camera.extractMetaData(selectedImageMetaData)
        
        // Dismiss the viewController
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Set the UISliders and add the measure subView
    /***************************************************************/
    func viewWithSliders() {
        
        //Provide the next set of directions.
        directionsText.text = "Now that you see the image you want to analyze, the slider controls on either side will allow you to set a couple of measurement points. When you touch the red circle on the left and pull it down, a red line begins to descend from the top. Position the red line on the top of the tower in the image. Repeat this process on the right slider control by moving the blue line up to the base of the tower."
        
        //Show the sliders, adjust to vertical and set their colors
        topSlider.isHidden = false
        baseSlider.isHidden = false
        
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
        baseSlider.minimumValue = Float(containerView.bounds.height / 2)
        
        
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
        directionsText.text = "Once you're satisfied that the red and blue lines are properly positioned, press the Go to Map button"
    }
    
    @IBAction func baseAdjust(_ sender: UISlider) {
        lines.baseValue = sender.value
    }
    
    
    @IBAction func resetApp(_ sender: UIButton) {
        appDelegate.resetApp()
    }
    
    @IBAction func submitForCalculation(_ sender: UIButton) {
        
        camera.gatherUserMeasurement(top: topSlider.value, bottom: baseSlider.value, imageHeight: containerView.bounds.height)
        towerHeight.text = camera.towerAGL()
    }
    
    
    @IBAction func goToMap(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMap" {
            let destinationVC = segue.destination as! GoogleMapViewController
            destinationVC.passedLatitude = camera.cameraLatitude
            destinationVC.passedLongitude = camera.cameraLongitude
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
