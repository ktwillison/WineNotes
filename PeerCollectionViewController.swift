//
//  PeerCollectionViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 12/4/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//  Basic outline of multipeer connectivity setup adapted from
//  http://radar.oreilly.com/2014/09/multipeer-connectivity-on-ios-8-with-swift.html

import UIKit
import MultipeerConnectivity

let reuseIdentifier = "ReviewCell"

class PeerCollectionViewController: UICollectionViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    let serviceType = "WineNotes"
    
    var browserVC : MCBrowserViewController!
    var advertiserAssistant : MCAdvertiserAssistant!
    var session : MCSession!
    var myPeerID: MCPeerID!
    
    var foundRatings : [String] = [] {
        didSet{
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set managedObjectContext
        if AppData.managedObjectContext == nil {AppData.setManagedObjectContext() }
        
        // Get peerID from device name
        myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: myPeerID)
        session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        browserVC = MCBrowserViewController(serviceType:serviceType, session:session)
        browserVC.delegate = self;
        
        advertiserAssistant = MCAdvertiserAssistant(serviceType:serviceType,
            discoveryInfo:nil, session:session)
        
        // start advertising the service
        advertiserAssistant.start()
    }
    
    // Send the given rating to all connected peers
    func broadcastRating(rating : WineReview) {
        sendRatingToPeers(Review(fromWineReview: rating), peers: session.connectedPeers)
    }
    
    // Send recent ratings to a newly connected peer
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == .Connected {
            for rating in WineReview.getRecentReviews(withinHours: 6, context: AppData.managedObjectContext!) {
                sendRatingToPeers(Review(fromWineReview: rating), peers: [peerID])
            }
        }
    }
    
    // Asynchronously send data to peers
    func sendRatingToPeers(rating : Review, peers : [MCPeerID], updateResults update : Bool = false) {
        
        // Set weak reference for memory cycles
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [ weak weakSelf = self ] in
            //            if let textToSend = rating.name {
            let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(rating)
            //                if let msg = textToSend.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
            do {
                try self.session.sendData(dataToSend, toPeers: peers, withMode: MCSessionSendDataMode.Unreliable)
                if (update) {weakSelf?.updateResults(withData: dataToSend, fromPeer: (weakSelf?.myPeerID)!)}
            } catch (let error) {
                print("Error sending data: \(error)")
            }
            //        }
            //            }
            
            //            dispatch_async(dispatch_get_main_queue()) {
            //                        weakSelf?.tweetImage = UIImage(data: imageData)
            //                    }
        }
    }

    
//    func updateResults(text : String, fromPeer peerID: MCPeerID) {
    func updateResults(withData data : NSData, fromPeer peerID: MCPeerID) {
        
        if let loadedReview = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Review {
            
            // If this peer ID is the local device's peer ID, then show the name
            // as "Me"
            var name : String
            
            switch peerID {
            case peerID:
                name = "Me"
            default:
                name = peerID.displayName
            }
            
            // Add the name to the message and display it
            foundRatings.append(loadedReview.name ?? "Review")
            //        foundRatings.append(text)
        }
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
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
            // Called when a peer sends an NSData to us
            
            // This needs to run on the main queue
            dispatch_async(dispatch_get_main_queue()) {
                
//                let msg = NSString(data: data, encoding: NSUTF8StringEncoding)
        
//                self.updateResults(String(msg), fromPeer: peerID)
                self.updateResults(withData: data, fromPeer: peerID)
            }
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
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
        return foundRatings.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if let cell = cell as? ReviewCollectionViewCell {
            cell.cellLabel.text = foundRatings[indexPath.row]
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

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
