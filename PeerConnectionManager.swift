//
//  PeerConnectionManager.swift
//  WineNotes
//
//  Created by Katie Willison on 12/7/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//  Basic outline of multipeer connectivity setup adapted from
//  http://radar.oreilly.com/2014/09/multipeer-connectivity-on-ios-8-with-swift.html
//

import UIKit
import MultipeerConnectivity


//
class PeerConnectionManager: NSObject, MCSessionDelegate {
    
    let serviceType = "WineNotes"
    
    var browserVC : MCBrowserViewController!
    var advertiserAssistant : MCAdvertiserAssistant!
    var session : MCSession!
    var myPeerID: MCPeerID!
    
    let center = NSNotificationCenter.defaultCenter()
    var addReviewObserver : AnyObject?
    
    
    // Data Model
    var receivedReviews : [Review] = [] {
        didSet {
            // Send a notification that the receivedReviews object has changed
            let notification = NSNotification(
                name: "ReceivedReview",
                object: self,
                userInfo: ["receivedReview" : true]
            )
            NSNotificationCenter.defaultCenter().postNotification(notification)

        }
    }
    
    override init() {
        super.init()
        
        // Get peerID from device name
        myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: myPeerID)
        session.delegate = self
        
        // start advertising the service
        advertiserAssistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:session)
        advertiserAssistant.start()
        
        // Add observer for "add review"
        addReviewObserver = center.addObserverForName("AddReview",
            object: nil, //UIApplication.sharedApplication(),
            queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
                if let addedReview = notification.userInfo?["addedReview"] as? Review {
                    weakSelf?.broadcastRating(addedReview)
                }
        }
    }
    
    
    // Send the given rating to all connected peers
    func broadcastRating(rating : Review) {
        if session.connectedPeers.count > 0 {
            sendRatingToPeers(rating, peers: session.connectedPeers)
        }
    }
    
    // Send recent ratings to a newly connected peer
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == .Connected {
            //Set managedObjectContext
            if AppData.managedObjectContext == nil {AppData.setManagedObjectContext() }
            
            for rating in WineReview.getRecentReviews(withinHours: 6, context: AppData.managedObjectContext!) {
                
                // Send the review over with the compressed image
                let reviewToSend = Review(fromWineReview: rating)
                if reviewToSend.image != nil,
                    let imageData = UIImageJPEGRepresentation(reviewToSend.image!, 0.2) {
                        reviewToSend.image = UIImage(data: imageData)
                }

                sendRatingToPeers(reviewToSend, peers: [peerID])
            }
        } else {
            print ("Peer changed to state \(state.rawValue)")
        }
    }
    
    // Asynchronously send data to peers
    func sendRatingToPeers(rating : Review, peers : [MCPeerID], updateResults update : Bool = false) {
        
        // Set weak reference for memory cycles
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [ weak weakSelf = self ] in
            
            // Archive and send data
            let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(rating)
            do {
                try self.session.sendData(dataToSend, toPeers: peers, withMode: MCSessionSendDataMode.Unreliable)
                
                // Update UI on main queue if set (currently is not ever)
                if (update) {
                    dispatch_async(dispatch_get_main_queue()) {
                        weakSelf?.updateResults(withData: dataToSend, fromPeer: (weakSelf?.myPeerID)!)
                    }
                }
            } catch (let error) {
                print("Error sending data: \(error)")
            }
        }
    }
    
    // Update results with received data
    func updateResults(withData data : NSData, fromPeer peerID: MCPeerID) {
        
        if let loadedReview = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Review {
            
            // Add the review to the found ratings, replacing it if it alrady existed
            if let foundMatchingRatings = receivedReviews.indexOf({ $0.id == loadedReview.id }) {
                receivedReviews.removeAtIndex(foundMatchingRatings)
            }
            receivedReviews.append(loadedReview)
            
        }
    }
    
    // Handle a peer sending NSData to us
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        // This needs to run on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            self.updateResults(withData: data, fromPeer: peerID)
        }
    }
    
    // MCSessionDelegate protocol's required methods:

    // Called when a peer starts sending a file to us
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {}
    
    // Called when a file has finished transferring from another peer
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?)  {}
    
    // Called when a peer establishes a stream with us
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)  {}
}
