//
//  Lines.swift
//  LinesSandbox
//
//  Created by Greg Durfee on 2/2/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import UIKit

/* The purpose of this class is to programmatically define a view consisting of two moveable lines to be placed
 over the selected image at runtime. The lines will allow the user to identify the top and base of the tower.
 These selected positions will then be used as part of the calculations needed for tower height. */

class Lines: UIView {
    
    var topValue: Float = 0 {
        didSet {
            //Redraw view each time the topSlider position changes.
            self.setNeedsDisplay()
        }
    }
    var baseValue: Float = 0 {
        didSet {
            //Redraw view each time the baseSlider position changes.
            self.setNeedsDisplay()
        }
    }
    
    
    override func draw(_ rect: CGRect) {

        // Drawing code for tower top measure. The red line moves down from the top.
        let topContext = UIGraphicsGetCurrentContext()
        topContext?.clear(rect)
        topContext?.setLineWidth(2.0)
        topContext?.setStrokeColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        topContext?.move(to: CGPoint(x: 0, y: CGFloat(topValue)))
        topContext?.addLine(to: CGPoint(x: bounds.width, y: CGFloat(topValue)))
        topContext?.strokePath()
        
        //Drawing code for tower base measure. The blue line moves up from the bottom.
        let baseContext = UIGraphicsGetCurrentContext()
        baseContext?.setLineWidth(2.0)
        baseContext?.setStrokeColor(red: 0, green: 0, blue: 255, alpha: 0.5)
        baseContext?.move(to: CGPoint(x: 0, y: CGFloat(baseValue)))
        baseContext?.addLine(to: CGPoint(x: bounds.width, y: CGFloat(baseValue)))
        baseContext?.strokePath()
        
    }
    
    func redrawLines() {
        contentMode = .redraw
    }
    
}
