//
//  MouthReview.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData


class MouthReview: NSManagedObject {

    class func mouthReviewFromReview(review: Mouth, inManagedObjectContext context: NSManagedObjectContext) -> MouthReview? {
        
        if let mouthReview = NSEntityDescription.insertNewObjectForEntityForName("MouthReview", inManagedObjectContext: context) as? MouthReview {
            mouthReview.acidity = review.acidity
            mouthReview.body = review.body
            mouthReview.alcohol = review.alcohol
            mouthReview.tannins = review.tannins
            mouthReview.length = review.length
            mouthReview.residualSugar = review.residualSugar
            
            let aromaList : NSMutableOrderedSet = NSMutableOrderedSet()
            for aroma in review.aromas ?? [] {
                if let aromaDB = AromaTag.aromaFromDescription(aroma.aromaDescription, inManagedObjectContext: context) {
                    aromaList.addObject(aromaDB)
                }
            }
            mouthReview.aromas = aromaList.copy() as? NSOrderedSet
            
            return mouthReview
        }
        return nil
    }

}
