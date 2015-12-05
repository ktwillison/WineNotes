//
//  HistoryTableViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var reviews : [WineReview]?
    let ratingHistoryCell = "RatingHistoryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setManagedObjectContext()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reviews = WineReview.getReviews(inManagedObjectContext: managedObjectContext!)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ratingHistoryCell, forIndexPath: indexPath)
        
        if let cell = cell as? RatingHistoryTableViewCell {
            cell.cellTitle.text = reviews?[indexPath.row].varietal
            if let reviewImageURL = reviews?[indexPath.row].imageURL {
                if let imageURL = NSKeyedUnarchiver.unarchiveObjectWithData(reviewImageURL) as? NSURL {
                    if let imageData = NSData(contentsOfURL: imageURL) {
                        cell.cellImageView.image = UIImage(data: imageData)
                    }
                }
            }
            
            return cell
        }

        return cell
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Core Data
    
    var managedObjectContext: NSManagedObjectContext?
    
    // Sets (or re-tries setting) managed object context
    func setManagedObjectContext() {
        AppDelegate.currentAppDelegate?.getContext { [weak weakSelf = self] (context, success) in
            if success {
                weakSelf?.managedObjectContext = context
            } else {
                // This may cause an endless loop.. but shouldn't as long as document state isn't whack
                weakSelf?.setManagedObjectContext()
            }
        }
    }

}
