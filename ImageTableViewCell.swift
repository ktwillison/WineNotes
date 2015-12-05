//
//  ImageTableViewCell.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import CoreImage

// Core image walkthrough found at http://www.raywenderlich.com/76285/beginning-core-image-swift
class ImageTableViewCell: UITableViewCell {
    
    var originalImage : UIImage? {didSet { updateImage() }}
    @IBOutlet weak var pictureView: UIImageView!
    
    var controllerDelegate : ReviewTableViewController!
    
    private func updateImage() {
        if originalImage != nil {
            let image = CIImage(image: originalImage!)
            controllerDelegate.coreImageFilter.setValue(image, forKey: kCIInputImageKey)
            if let outputImage : CIImage = controllerDelegate.coreImageFilter.outputImage {
                let cgimg = controllerDelegate.coreImageContext.createCGImage(outputImage, fromRect: outputImage.extent)
                pictureView.image = UIImage(CGImage: cgimg)
            } else {
                pictureView.image = originalImage
            }
        }
    }
}
