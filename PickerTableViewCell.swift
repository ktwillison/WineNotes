//
//  PickerTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 11/27/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var connectedCell : RatingCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
