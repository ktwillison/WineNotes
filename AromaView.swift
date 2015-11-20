//
//  AromaView.swift
//  WineNotes
//
//  Created by Katie Willison on 11/19/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class AromaView: UIView, UIDynamicAnimatorDelegate {

    private lazy var aromaWheelView : AromaWheelView = {
        let view = AromaWheelView()
        view.frame = self.bounds
        view.center = self.center
        view.opaque = false
        self.addSubview(view)
        return view
    }()
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self)
        lazilyCreatedAnimator.delegate = self
        return lazilyCreatedAnimator
    }()
    
    var animating = false {
        didSet {
            if animating != oldValue {
                if animating {
                    wheelBehavior.addItem(aromaWheelView)
                    animator.addBehavior(wheelBehavior)
                }
                else {
                    wheelBehavior.removeItem(aromaWheelView)
                    animator.removeAllBehaviors()
                }
            }
        }
    }
    
    private lazy var wheelBehavior: UIDynamicItemBehavior = {
        let thisItemBehavior = UIDynamicItemBehavior()
        thisItemBehavior.angularResistance = 0.9
        thisItemBehavior.action = nil
        return thisItemBehavior
    }()

    
//    private var rotationSpeed : CGFloat = 0.0
    
    func rotateWheel(recognizer : UIPanGestureRecognizer) {
        if recognizer.state == .Changed{
            let panRotationSpeed = recognizer.velocityInView(self).y
            let currentRotationSpeed = wheelBehavior.angularVelocityForItem(aromaWheelView)
//            print ("pan = " + String(panRotationSpeed) + ", current = " + String(currentRotationSpeed))
            wheelBehavior.addAngularVelocity((panRotationSpeed-currentRotationSpeed)/1000, forItem: aromaWheelView)
        }
    }
    
    func tapWheel(recognizer : UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            let currentRotationSpeed = wheelBehavior.angularVelocityForItem(aromaWheelView)
            if currentRotationSpeed != 0 {
                wheelBehavior.addAngularVelocity(-currentRotationSpeed, forItem: aromaWheelView)
//            } else if let section = aromaWheelView.hitTest(recognizer.locationInView(aromaWheelView), withEvent: nil) {
            } else if let aroma = aromaWheelView.getWedge(recognizer.locationInView(aromaWheelView)) {
                    print(aroma.aromaDescription)
                
//                if section.superview == aromaWheelView {
//                    print(section)
//                    print("hit!")
//                }
            }
        }
    }
    
//    private var wheelSize : CGFloat {
//        return self.frame.width
//    }
    
    func positionWheel() {
        
        // Unwind current rotation properties
        let currentRotationSpeed = wheelBehavior.angularVelocityForItem(aromaWheelView)
        let rotation = aromaWheelView.transform
        wheelBehavior.removeItem(aromaWheelView)
        aromaWheelView.transform = CGAffineTransformMakeRotation(0)
        
        // Re-center wheel and add roration back
        aromaWheelView.center = self.center
        aromaWheelView.transform = rotation
        wheelBehavior.addItem(aromaWheelView)
        wheelBehavior.addAngularVelocity(currentRotationSpeed, forItem: aromaWheelView)
        
    }
    
    
    private var laidOutToBounds : CGRect?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if laidOutToBounds != self.bounds {
            positionWheel()
            laidOutToBounds = self.bounds
//            layoutSubviews()
        }
    }
}
