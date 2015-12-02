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
            slider.value = 0
            changeValue(slider)
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
    
    @IBOutlet weak var showInfoText: UIButton!
        
    func moveSliderToPoint(recognizer: UITapGestureRecognizer) {
        let tappedAtPoint = recognizer.locationInView(slider)
        let tappedAtPercent = Float(tappedAtPoint.x / slider.frame.width)
        slider.value = slider.maximumValue * tappedAtPercent
        changeValue(slider)
    }
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
