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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
