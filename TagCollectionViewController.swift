//
//  TagCollectionViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 11/21/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class TagCollectionViewController: UICollectionViewController {

    private let reuseIdentifier = "Tag"
    
    var aromaType : AromaType?
    var tags : [Aroma] = [] {
        didSet {
            print(tags.description)
            collectionView?.reloadData()
        }
    }

    
    let center = NSNotificationCenter.defaultCenter()
    
    private var addObserver : AnyObject?
    private var removeObserver : AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        addObserver = center.addObserverForName("AddAroma",
            object: nil, //UIApplication.sharedApplication(),
            queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
            if let aroma = notification.userInfo?["addedAroma"] as? Aroma {
                if let hasAroma = weakSelf?.tags.contains(aroma) where !hasAroma {
//                if find(self.tags, aroma) == nil {

                    weakSelf?.tags.append(aroma)
                }
            }
        }
        
        removeObserver = center.addObserverForName("RemoveAroma",
            object: nil, //UIApplication.sharedApplication(),
            queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
            if let aroma = notification.userInfo?["removedAroma"] as? Aroma {
                if let i = weakSelf?.tags.indexOf(aroma) {
                    weakSelf?.tags.removeAtIndex(i)
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if addObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(addObserver!)
            addObserver = nil
        }
        if removeObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(removeObserver!)
            removeObserver = nil
        }
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
        return tags.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? TagCollectionViewCell {
            cell.aroma = tags[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let cell = TagCollectionViewCell()
//        cell.aroma = tags[indexPath.row]
////        cell.label.sizeToFit()
//        cell.systemLayoutSizeFittingSize(CGSize(width: 50, height: 30))
//        return cell.frame.size
//    }

    // MARK: UICollectionViewDelegate

    /*
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
