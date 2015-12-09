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
    
    // Add observers to update view when a new review is received
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add observer for "received review"
        receivedReviewObserver = center.addObserverForName("ReceivedReview",
            object: nil,
            queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
                weakSelf?.collectionView?.reloadData()
        }
        collectionView?.reloadData()
    }
    
    // Clean up observers
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if receivedReviewObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(receivedReviewObserver!)
            receivedReviewObserver = nil
        }
    }
    
    // Somehow invalidateLayout only works if I implement it here? hmm.
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionViewLayout.invalidateLayout()
    }
    
    // When selected, show the peer browser
    @IBAction func showPeerBrowser(sender: UIBarButtonItem) {
        self.presentViewController(browserVC, animated: true, completion: nil)
    }
    
    // Browser view controller is dismissed (ie the Done button was tapped)
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController)  {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Browser view controller is cancelled
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController)  {
            self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
                let photoOrigin = CGPoint(x: 0 , y: cellHeight - photoHeight)
                cell.cellImage.frame = CGRect(origin: photoOrigin, size: CGSize(width: photoWidth, height: photoHeight))
            }
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    private var cellWidth : CGFloat { get{ return 250 }}
    private var cellHeight : CGFloat { get{ return (collectionView?.frame.height ?? 375) * 0.6 }}
    private var photoWidth : CGFloat { get { return cellWidth }}
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSize(width: cellWidth, height: cellHeight)
    }
}
