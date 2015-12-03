//
//  WineReview+CoreDataProperties.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WineReview {

    @NSManaged var rating: NSNumber?
    @NSManaged var varietal: String?
    @NSManaged var country: String?
    @NSManaged var region: String?
    @NSManaged var date: NSDate?
    @NSManaged var eyes: EyesReview?
    @NSManaged var nose: NoseReview?
    @NSManaged var mouth: MouthReview?

}
