//
//  WineReview.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData


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
            wineReview.varietal = review.varietal
            wineReview.eyes = EyesReview.eyesReviewFromReview(review.eyes, inManagedObjectContext: context)
            wineReview.nose = NoseReview.noseReviewFromReview(review.nose, inManagedObjectContext: context)
            wineReview.mouth = MouthReview.mouthReviewFromReview(review.mouth, inManagedObjectContext: context)
            return wineReview
        }
        return nil
    }
}
