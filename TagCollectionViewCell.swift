//
//  TagCollectionViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 11/21/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    var aroma : Aroma? {
        didSet {
            label.text = aroma?.aromaDescription ?? ""
        }
    }
    
    @IBAction func removeTag(sender: UIButton) {
        // Notify 'RemoveAroma' with the current aroma
        if aroma != nil {
            let notification = NSNotification(
                name: "RemoveAroma",
                object: self,
                userInfo: ["removedAroma" : aroma!]
            )
            
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
}
