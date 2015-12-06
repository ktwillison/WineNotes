//
//  SliderTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 11/27/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

enum SliderStyle {
    case LowMedHigh
    case RimWidth
    case Openness
    case Numeric
    case None
}

class SliderTableViewCell: UITableViewCell {
    
    var delegate : InfoTextPresentationDelegate!
    
    var connectedCell : RatingCell? {
        didSet {
            
            if let style = connectedCell?.sliderStyle {
                switch style {
                case SliderStyle.LowMedHigh:
                    stopPoints = ["Low", "Medium -", "Medium", "Medium +", "High"]
                case .Openness:
                    stopPoints = ["Very closed", "Closed", "Neither", "Open", "Very open"]
                default :
                    stopPoints = nil
                }
            }
            
            slider.minimumValue = 0
            slider.maximumValue = Float((stopPoints?.count ?? 2) - 1)
            slider.value = 0.0
            valueLabel?.text = " "
            if connectedCell?.value != nil {
                slider.value = Float((connectedCell?.value)!)
                changeValue(slider)
            }
        }
    }

    var stopPoints : [String]?
    
    @IBAction func changeValue(sender: UISlider) {
        
        if stopPoints != nil {
            let stopPoint = lroundf(sender.value)
            slider.setValue(Float(stopPoint), animated: true)
            valueLabel?.text = stopPoints?[stopPoint]
        } else {
            valueLabel?.text =  NSString(format:"%.2f", sender.value) as String
        }
        
        connectedCell?.value = Double(sender.value)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var showInfoTextButton: UIButton!
    
    // Method adapted from  http://stackoverflow.com/questions/26880526/performing-a-segue-from-a-button-within-a-custom-uitableviewcell
    @IBAction func showInfoText(sender: UIButton) {
        if delegate != nil {
            delegate.callSegueFromCell(sender)
        }
    }
    
    func moveSliderToPoint(recognizer: UITapGestureRecognizer) {
        let tappedAtPoint = recognizer.locationInView(slider)
        let tappedAtPercent = Float(tappedAtPoint.x / slider.frame.width)
        slider.value = slider.maximumValue * tappedAtPercent
        changeValue(slider)
    }

}

protocol InfoTextPresentationDelegate {
    func callSegueFromCell(sender: UIButton)
}