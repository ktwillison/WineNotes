//
//  AromaViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 11/19/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class AromaViewController: UIViewController {

    @IBOutlet var aromaView: AromaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panWheel = UIPanGestureRecognizer(target: aromaView, action: "rotateWheel:")
        aromaView.addGestureRecognizer(panWheel)
        let tapWheel = UITapGestureRecognizer(target: aromaView, action: "tapWheel:")
        aromaView.addGestureRecognizer(tapWheel)

        aromaView.animating = true
        
//        aromaView.backgroundColor = UIColor.redColor()
//        aromaView.aromaWheelView.backgroundColor = UIColor.redColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
