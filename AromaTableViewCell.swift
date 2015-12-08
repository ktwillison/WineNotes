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
    
    @IBOutlet weak var valueLabel: UILabel!
    
    var aromaType : AromaType?
    
    var aromas : [Aroma] = [] {
        didSet {
            valueLabel.text = aromas.map({ $0.aromaDescription }).joinWithSeparator(", ")
        }
    }
}
