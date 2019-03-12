//
//  ViewController.swift
//  LinesSandbox
//
//  Created by Greg Durfee on 1/31/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var topSlider: UISlider!
    
    @IBOutlet weak var baseSlider: UISlider!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var bottomLabel: UILabel!
    
    //See if you can create one programmatically....
    var pSlider: UISlider!
    
    var lines: Lines!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Rotate both sliders to vertical
        topSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        baseSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        
        
        
        //Set color properties for sliders
        topSlider.thumbTintColor = UIColor.red
        topSlider.minimumTrackTintColor = UIColor.cyan
        topSlider.maximumTrackTintColor = UIColor.red
        
        baseSlider.thumbTintColor = UIColor.blue
        baseSlider.minimumTrackTintColor = UIColor.blue
        baseSlider.maximumTrackTintColor = UIColor.yellow
        
        let rect = CGRect(x: 137, y: 134, width: 750, height: 500)
        lines = Lines(frame: rect)
        view.backgroundColor = UIColor.green
        view.addSubview(lines)
        
        pSlider = UISlider(frame: CGRect(x: -175, y: 369, width: lines.frame.height, height: 31))
        pSlider.minimumValue = 0
        pSlider.value = 0
        pSlider.maximumValue = Float(CGFloat(lines.frame.height))
        pSlider.thumbTintColor = UIColor.red
        pSlider.minimumTrackTintColor = UIColor.cyan
        pSlider.maximumTrackTintColor = UIColor.red
        pSlider.isContinuous = true
        
        self.view.addSubview(pSlider)
        pSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
         
    }

    @IBAction func topAdjust(_ sender: UISlider) {
        topLabel.text = String(sender.value)
        lines.topValue = sender.value
    }
    
    @IBAction func baseAdjust(_ sender: UISlider) {
        bottomLabel.text = String(sender.value)
        lines.baseValue = sender.value
    }
}


