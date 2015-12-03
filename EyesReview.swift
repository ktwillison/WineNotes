//
//  EyesReview.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData


class EyesReview: NSManagedObject {

    class func eyesReviewFromReview(review: Eyes, inManagedObjectContext context: NSManagedObjectContext) -> EyesReview? {
        if let eyesReview = NSEntityDescription.insertNewObjectForEntityForName("EyesReview", inManagedObjectContext: context) as? EyesReview {
            eyesReview.opacity = review.opacity
            eyesReview.rim = review.rim
            eyesReview.spritz = review.spritz
            if review.color != nil {
                eyesReview.color =  NSKeyedArchiver.archivedDataWithRootObject(review.color!)
            }
            
            return eyesReview
        }
        return nil
    }
}
