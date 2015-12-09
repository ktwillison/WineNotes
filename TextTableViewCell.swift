//
//  TextTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 12/4/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    
    var connectedCell : RatingCell? {
        didSet {
            nameTextField?.text = connectedCell?.textValue
        }
    }
    var controllerDelegate : ReviewTableViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
            nameTextField.addTarget(self, action: "updateTextValue", forControlEvents: .EditingChanged)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === nameTextField {
            textField.resignFirstResponder() // hide keyboard
            connectedCell?.textValue = textField.text
        }
        return true
    }
    
    func updateTextValue(){
        connectedCell?.textValue = nameTextField.text
    }
    
}
