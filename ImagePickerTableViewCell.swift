//
//  ImagePickerTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImagePickerTableViewCell: UITableViewCell {
    
    var controllerDelegate : ReviewTableViewController!
    
    @IBAction func takePhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            picker.delegate = controllerDelegate
            controllerDelegate.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func choosePhotoFromLibrary(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            picker.delegate = controllerDelegate
            controllerDelegate.presentViewController(picker, animated: true, completion: nil)
        }
    }
    

}
