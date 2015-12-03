//
//  NoseReview.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData


class NoseReview: NSManagedObject {

    class func noseReviewFromReview(review: Nose, inManagedObjectContext context: NSManagedObjectContext) -> NoseReview? {
        if let noseReview = NSEntityDescription.insertNewObjectForEntityForName("NoseReview", inManagedObjectContext: context) as? NoseReview {
            noseReview.openness = review.openness
            
            let aromaList : NSMutableOrderedSet = NSMutableOrderedSet()
            for aroma in review.aromas ?? [] {
                if let aromaDB = Aroma.aromaFromDescription(aroma.aromaDescription, inManagedObjectContext: context) {
                    aromaList.addObject(aromaDB)
                }
            }
            noseReview.aromas = aromaList.copy() as? NSOrderedSet
            
            return noseReview
        }
        return nil
    }
}
