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
    
    private let colorLevels = [
        UIColor(red:0.639, green:0.106, blue:0.263, alpha:1.00),
        UIColor(red:0.522, green:0.075, blue:0.208, alpha:1.00),
        UIColor(red:0.376, green:0.039, blue:0.145, alpha:1.00)]
    
    private lazy var aromas : [Aroma] = [
        Aroma("Fruity", wedgeColor: self.colorLevels[0]),	Aroma("Citrus", wedgeColor: self.colorLevels[1]),
        Aroma("Berry", wedgeColor: self.colorLevels[1]),
        Aroma("Tree fruit", wedgeColor: self.colorLevels[1]),
        Aroma("Tropical fruit", wedgeColor: self.colorLevels[1]),
        Aroma("Dried fruit", wedgeColor: self.colorLevels[1]),
        Aroma("Vegetative", wedgeColor: self.colorLevels[0]),	Aroma("Fresh", wedgeColor: self.colorLevels[1]),
        Aroma("Canned", wedgeColor: self.colorLevels[1]),
        Aroma("Dried", wedgeColor: self.colorLevels[1]),
        Aroma("Nutty", wedgeColor: self.colorLevels[0]),
        Aroma("Caramelized", wedgeColor: self.colorLevels[0]),
        Aroma("Woody", wedgeColor: self.colorLevels[0]),
        Aroma("Earthy", wedgeColor: self.colorLevels[0]),
        Aroma("Chemical", wedgeColor: self.colorLevels[2]),
        Aroma("Microbiological", wedgeColor: self.colorLevels[2]),
        Aroma("Floral", wedgeColor: self.colorLevels[0]),	
        Aroma("Spicy", wedgeColor: self.colorLevels[0])]
    
    private var numberOfAromas : Int {
        get {return aromas.count}
    }
    
    private let aromaLabelHeight : CGFloat = 20
    private var aromaLabelWidth : CGFloat {
        return 0.9 * wheelRadius
    }
    
    @IBInspectable
    private var wheelRadius : CGFloat {
        return 0.99 * bounds.size.height / 2 * scale
    }
    
    @IBInspectable
    private var wheelCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var scale : CGFloat = 1.0
    private var lineWidth : CGFloat = 2.0
    
    func getWedge(point: CGPoint) -> Aroma? {
        for aroma in aromas {
            if let hit = aroma.path?.containsPoint(point) where hit {
                return aroma
            }
        }
        return nil
    }
    
    // Create a wedge of the wheel
    private func wedgeInCircleCenteredAtPoint(midPoint: CGPoint, withRadius radius: CGFloat, numberOfSections: Int, thisSectionNumber: Int) -> UIBezierPath {
        
        // Define endpoints and length for this arc
        let arcLength = CGFloat(2 * M_PI) / CGFloat(numberOfSections)
        let startAngle = arcLength * CGFloat(thisSectionNumber - 1)
        let endAngle = startAngle + arcLength
        
        // Create and return wedge path
        let path = UIBezierPath()
        path.addArcWithCenter(midPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
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
            origin: CGPoint(x: wheelCenter.x-aromaLabelWidth/2, y: wheelCenter.y-aromaLabelHeight/2),
            size: CGSize(width: aromaLabelWidth, height: aromaLabelHeight)
        )
        let label = UILabel(frame: labelFrame)
        label.textColor = UIColor.whiteColor()
        label.font = label.font.fontWithSize(20)
        label.text = labelText
        label.textAlignment = .Right
        label.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        label.transform = CGAffineTransformRotate(label.transform, midAngle)
        addSubview(label)
        
    }
    
    override func drawRect(rect: CGRect){
        for (index, aroma) in aromas.enumerate() {
            aroma.path = wedgeInCircleCenteredAtPoint(wheelCenter, withRadius:wheelRadius, numberOfSections: numberOfAromas, thisSectionNumber: index+1)
            (aroma.color ?? colorLevels[2]).setFill()
            UIColor.whiteColor().setStroke()
            aroma.path?.lineWidth = 5.0
            aroma.path?.fill()
            aroma.path?.stroke()
            
            addLabelToWedge(wheelCenter, withRadius: wheelRadius, numberOfSections: numberOfAromas, thisSectionNumber: index+1, labelText : aroma.aromaDescription)
            aroma.color = UIColor.blueColor()
        }
    }
}


