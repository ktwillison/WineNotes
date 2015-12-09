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
import CoreLocation

class WineReview: NSManagedObject {
    
    class func wineReviewFromReview(review: Review, inManagedObjectContext context: NSManagedObjectContext) -> WineReview? {
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
            
            if review.location != nil {
                let location : Dictionary<String, Double> = ["latitude" : review.location!.latitude, "longitude" : review.location!.longitude]
                wineReview.location = NSKeyedArchiver.archivedDataWithRootObject(location)
            }
        
            let notification = NSNotification(name: "ReviewAddedToDatabase", object: self, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            return wineReview
        }
        return nil
    }
    
    func removeFromDatabase(inManagedObjectContext context: NSManagedObjectContext) {
        context.deleteObject(self)
    }

    class func getReviews(inManagedObjectContext context: NSManagedObjectContext, limit : Int? = nil) -> [WineReview] {
        
        let request = NSFetchRequest(entityName: "WineReview")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if limit != nil { request.fetchLimit = limit!}
        
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
    
    func getCoordinate() -> CLLocationCoordinate2D? {
        if location != nil {
            if let locationDict = NSKeyedUnarchiver.unarchiveObjectWithData(location!) as? Dictionary<String, Double> {
                return CLLocationCoordinate2D(latitude: locationDict["latitude"]!, longitude: locationDict["longitude"]!)
            }
        }
        return nil
    }
}
