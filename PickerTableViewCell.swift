//
//  PickerTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 11/27/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    var connectedCell : RatingCell?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var picker: UIPickerView! {
        didSet {
            picker.showsSelectionIndicator = true
            picker.delegate = self
        }
    }
    
    func pickerView(pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
        return connectedCell?.pickerValues[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueLabel.text = connectedCell?.pickerValues[row]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
            if component == 0 {
                return connectedCell?.pickerValues.count ?? 0
            }
            return 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
