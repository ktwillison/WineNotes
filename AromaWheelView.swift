//
//  AromaWheelView.swift
//  WineNotes
//
//  Created by Katie Willison on 11/19/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

@IBDesignable
class AromaWheelView: UIView {

    let aromas = ["Fruity", "Chemical", "Earthy", "Floral"]
    var numberOfAromas : Int {
        get {return aromas.count}
    }
    
    let aromaLabelHeight : CGFloat = 20
    var aromaLabelWidth : CGFloat {
        return 0.9 * wheelRadius
    }
    
    @IBInspectable
    var wheelRadius : CGFloat {
        return 0.9 * min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    @IBInspectable
    private var wheelCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var scale : CGFloat = 1.0
    private var lineWidth : CGFloat = 2.0
    
    
    // Create a wedge of the wheel
    private func wedgeInCircleCenteredAtPoint(midPoint: CGPoint, withRadius radius: CGFloat, numberOfSections: Int, thisSectionNumber: Int) -> UIBezierPath {
        
        // Define endpoints and length for this arc
        let arcLength = CGFloat(2 * M_PI) / CGFloat(numberOfSections)
        let startAngle = arcLength * CGFloat(thisSectionNumber - 1)
        let endAngle = startAngle + arcLength
        
        // Create and return wedge path
        let path = UIBezierPath(arcCenter: midPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addLineToPoint(midPoint)
        path.closePath()
        path.lineWidth = lineWidth
        return path
    }
    
    // Add a label to the circle for a given wedge number
    private func addLabelToWedge(midPoint: CGPoint, withRadius radius: CGFloat, numberOfSections: Int, thisSectionNumber: Int, labelText : String) {
        
        // Define midpoint for this wedge
        let arcLength = CGFloat(2 * M_PI) / CGFloat(numberOfSections)
        let midAngle = arcLength * CGFloat(thisSectionNumber - 1) + arcLength/2
        
        // Define a new UILabel and rotate to add it to this view
        let labelFrame = CGRect(
            origin: CGPoint(x: wheelCenter.x-wheelRadius/2, y: wheelCenter.y-aromaLabelHeight/2),
            size: CGSize(width: aromaLabelWidth, height: aromaLabelHeight)
        )
        let label = UILabel(frame: labelFrame)
        label.text = labelText
        label.textAlignment = .Right
        label.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        label.transform = CGAffineTransformRotate(label.transform, midAngle)
//        label.transform = CGAffineTransformMakeRotation(midAngle)
        addSubview(label)
        
    }
    
    override func drawRect(rect: CGRect){
        UIColor.blueColor().set()
        for aroma in aromas {
            wedgeInCircleCenteredAtPoint(wheelCenter, withRadius: wheelRadius, numberOfSections: numberOfAromas, thisSectionNumber: aromas.indexOf(aroma)!+1).stroke()
            addLabelToWedge(wheelCenter, withRadius: wheelRadius, numberOfSections: numberOfAromas, thisSectionNumber: aromas.indexOf(aroma)!+1, labelText : aroma)
        }
    }

}
