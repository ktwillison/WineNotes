//
//  WineReview.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class WineReview: NSManagedObject {
    
    class func wineReviewFromReview(review: Review, inManagedObjectContext context: NSManagedObjectContext) -> WineReview? {
//        // See if tweet is already in database
//        let request = NSFetchRequest(entityName: "Tweet")
//        request.predicate = NSPredicate(format: "id = %@ AND search.text = %@", tweetInfo.id, searchText)
//        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
//            return tweet
//            
//            // If not, create one, and add it to the database
//        } else
        if let wineReview = NSEntityDescription.insertNewObjectForEntityForName("WineReview", inManagedObjectContext: context) as? WineReview {
            wineReview.date = NSDate()
            wineReview.rating = review.rating
            wineReview.region = review.region
            wineReview.country = review.country
            wineReview.name = review.name
            wineReview.varietal = review.varietal
            wineReview.eyes = EyesReview.eyesReviewFromReview(review.eyes, inManagedObjectContext: context)
            wineReview.nose = NoseReview.noseReviewFromReview(review.nose, inManagedObjectContext: context)
            wineReview.mouth = MouthReview.mouthReviewFromReview(review.mouth, inManagedObjectContext: context)
            wineReview.imageURL =  review.imageURL
            let unique = String(NSDate.timeIntervalSinceReferenceDate()) + "_" + UIDevice.currentDevice().identifierForVendor!.UUIDString
            wineReview.id = unique

            return wineReview
        }
        return nil
    }
    
    class func getReviews(inManagedObjectContext context: NSManagedObjectContext, limit : Int? = nil) -> [WineReview] {
        
        let request = NSFetchRequest(entityName: "WineReview")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if limit != nil {
            request.fetchLimit = limit!
        }
        
        if let results = (try? context.executeFetchRequest(request)) as? [WineReview] {
            return results
        }
        return []
    }
    
    class func getRecentReviews(withinHours hours : Int, context: NSManagedObjectContext) -> [WineReview] {
        
        let dateCutoff = NSDate().dateByAddingTimeInterval(Double(-60*60*hours))
        
        let request = NSFetchRequest(entityName: "WineReview")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "(date >= %@)", argumentArray: [dateCutoff])
        
        if let results = (try? context.executeFetchRequest(request)) as? [WineReview] {
            return results
        }
        return []
    }
    
    func getImage() -> UIImage? {
        // Get relative path
        if let reviewImageURL = imageURL {
            
            // Resolve to full path
            if let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let imageURL = documentsDirectory.URLByAppendingPathComponent(reviewImageURL)
        
                if let imageData = NSData(contentsOfURL: imageURL) {
                    return UIImage(data: imageData)
                }
            }
        }
        return nil        
    }
}
