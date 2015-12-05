//
//  HistoryTableViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import CoreData
import Social

class HistoryTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let ratingHistoryCell = "RatingHistoryCell"
    
    private var userIsSearching : Bool = false
    var searchController: UISearchController!
    
    private var reviews : [WineReview]?
    private var filteredReviews : [WineReview]?
    private var dataSource : [WineReview]? {
        get {
            if userIsSearching {
                if searchController.searchBar.text == "" {return reviews}
                return filteredReviews
            } else {
                return reviews
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setManagedObjectContext()
        configureSearchController()
        
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
        return dataSource?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ratingHistoryCell, forIndexPath: indexPath)
        
        if let cell = cell as? RatingHistoryTableViewCell {
            cell.associatedReview = dataSource?[indexPath.row]
            cell.controllerDelegate = self
            return cell
        }

        return cell
    }
    
    // MARK: - Search
    
    // Set up the search bar
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        //        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search your past reviews"
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        userIsSearching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        userIsSearching = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !userIsSearching {
            userIsSearching = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        // Filter the array of wine reviews, matching on name, varietal and aroma
        filteredReviews = reviews?.filter({ (thisReview) -> Bool in
            var searchFields : [NSString] = [thisReview.name ?? "", thisReview.varietal ?? ""]
            if let noseAromas = thisReview.nose?.aromas?.array as? [AromaTag] {
                for aroma in noseAromas where aroma.aromaDescription != nil {
                    searchFields.append(aroma.aromaDescription!)
                }
            }
            if let mouthAromas = thisReview.mouth?.aromas?.array as? [AromaTag] {
                for aroma in mouthAromas where aroma.aromaDescription != nil {
                    searchFields.append(aroma.aromaDescription!)
                }
            }
            
            for field in searchFields {
                if (field.rangeOfString(searchText!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
                    return true
                }
            }

            return false
        })
        
        // Reload the tableview.
        tableView.reloadData()
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
    
    // MARK: - Social
    
    // Delegate function to post a review to facebook
    // general tutorial from https://www.hackingwithswift.com/example-code/uikit/how-to-share-content-with-the-social-framework-and-slcomposeviewcontroller
    func postToFacebook(forReview review: WineReview) {
        let fbvc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbvc.setInitialText("I just tasted a fabulous \(review.varietal ?? "wine"), check it out!")
        if let reviewImage = review.getImage(){
            fbvc.addImage(reviewImage)
        }
        presentViewController(fbvc, animated: true, completion: nil)

    }

}
