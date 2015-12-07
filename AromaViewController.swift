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
    var aromaType : AromaType?
    var initializeWithTags : [Aroma] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panWheel = UIPanGestureRecognizer(target: aromaView, action: "rotateWheel:")
        aromaView.addGestureRecognizer(panWheel)
        let tapWheel = UITapGestureRecognizer(target: aromaView, action: "tapWheel:")
        aromaView.addGestureRecognizer(tapWheel)
        aromaView.animating = true
        
        if let tagView = childViewControllers[0] as? TagCollectionViewController {
            tagView.tags = initializeWithTags
            tagView.aromaType = aromaType
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Unwind to Review Table",
            let unwindToTable = segue.destinationViewController as? ReviewTableViewController {
            if let tagVC = childViewControllers[0] as? TagCollectionViewController {
                if tagVC.aromaType == AromaType.Mouth {
                    unwindToTable.review.mouth.aromas = tagVC.tags
                } else if tagVC.aromaType == AromaType.Nose {
                    unwindToTable.review.nose.aromas = tagVC.tags
                }
            }
        }
    }

}
