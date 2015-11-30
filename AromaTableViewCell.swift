//
//  AromaTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 11/29/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

enum AromaType {
    case Mouth
    case Nose
}

class AromaTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var aromaType : AromaType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
