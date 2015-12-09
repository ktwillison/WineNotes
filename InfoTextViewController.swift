//
//  InfoTextViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 12/1/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class InfoTextViewController: UIViewController {

    var connectedCell : RatingCell?
    
    @IBOutlet weak var infoText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoText.text = connectedCell?.infoText ?? ""
        
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        navigationItem.rightBarButtonItem = backButton
        
    }
    
    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        view.sizeToFit()    //= CGSize(width: 320, height: 186)
        preferredContentSize = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
}
