//
//  PeerCollectionViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 12/4/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let reuseIdentifier = "ReviewCell"

class PeerCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MCBrowserViewControllerDelegate {
    
    var browserVC : MCBrowserViewController!
    
    let center = NSNotificationCenter.defaultCenter()
    var receivedReviewObserver : AnyObject?
    
    var receivedReviews : [Review] {
        get {
            return AppDelegate.currentAppDelegate?.peerConnectionManager?.receivedReviews ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set managedObjectContext
        if AppData.managedObjectContext == nil {AppData.setManagedObjectContext() }
        
        // create the browser viewcontroller with a unique service name
        if let session = AppDelegate.currentAppDelegate?.peerConnectionManager?.session,
            serviceType = AppDelegate.currentAppDelegate?.peerConnectionManager?.serviceType {
            browserVC = MCBrowserViewController(serviceType:serviceType, session:session)
            browserVC.delegate = self;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add observer for "received review"
        receivedReviewObserver = center.addObserverForName("ReceivedReview",
            object: nil, //UIApplication.sharedApplication(),
            queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
                weakSelf?.collectionView?.reloadData()
        }
        collectionView?.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if receivedReviewObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(receivedReviewObserver!)
            receivedReviewObserver = nil
        }
    }
    
    // Somehow invalidateLayout only works if I implement it here?
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionViewLayout.invalidateLayout()
    }

    
    // When selected, show the peer browser
    @IBAction func showPeerBrowser(sender: UIBarButtonItem) {
        self.presentViewController(browserVC, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return receivedReviews.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if let cell = cell as? ReviewCollectionViewCell {
            cell.cellLabel.text = receivedReviews[indexPath.row].name ?? "Untitled Wine"
            cell.cellVarietal.text = receivedReviews[indexPath.row].varietal ?? " "
            if let rating = receivedReviews[indexPath.row].rating {
                cell.cellRating.text = String(round(rating + 1))
            } else {
                cell.cellRating.text = " "
            }
            
            cell.cellImage.image = receivedReviews[indexPath.row].image
            if cell.cellImage.image != nil {
                let aspectRatio = cell.cellImage.image!.size.height / cell.cellImage.image!.size.width
                let photoHeight = aspectRatio * photoWidth
//                let photoOrigin = CGPoint(x: cell.layoutMarginsGuide.leftAnchor. , y: cellHeight - photoHeight)
                let photoOrigin = CGPoint(x: 0 , y: cellHeight - photoHeight)
                cell.cellImage.frame = CGRect(origin: photoOrigin, size: CGSize(width: photoWidth, height: photoHeight))
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

//    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private var cellWidth : CGFloat {
        get{ return 250 } //(collectionView?.frame.width ?? 230) * 0.7 }
    }
    
    private var cellHeight : CGFloat {
        get{ return (collectionView?.frame.height ?? 375) * 0.6 }
    }
    
    private var photoWidth : CGFloat {
        get { return cellWidth }
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSize(width: cellWidth, height: cellHeight)
    }
    
   
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//            return sectionInsets
//    }

    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
