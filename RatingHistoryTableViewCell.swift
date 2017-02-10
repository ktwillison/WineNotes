//
//  RatingHistoryTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class RatingHistoryTableViewCell: UITableViewCell {

    var controllerDelegate : HistoryTableViewController!
    var associatedReview : WineReview? {
        didSet {
            if associatedReview != nil {
                cellTitle.text = associatedReview!.name ?? "Untitled Wine"
                cellSubtitle.text = associatedReview!.varietal
                cellImageView.image = associatedReview!.getImage()
            }
        }
    }
    
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellImageView: UIImageView!

    @IBOutlet weak var cellSubtitle: UILabel!
    
    @IBAction func postToFacebook(sender: UIButton) {
        if associatedReview != nil {
            controllerDelegate.postToFacebook(forReview: associatedReview!)
        }
    }
    
   
}
