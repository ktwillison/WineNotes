//
//  WineReview+CoreDataProperties.swift
//  WineNotes
//
//  Created by Katie Willison on 12/4/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WineReview {

    @NSManaged var country: String?
    @NSManaged var date: NSDate?
    @NSManaged var imageURL: NSData?
    @NSManaged var rating: NSNumber?
    @NSManaged var region: String?
    @NSManaged var varietal: String?
    @NSManaged var name: String?
    @NSManaged var eyes: EyesReview?
    @NSManaged var mouth: MouthReview?
    @NSManaged var nose: NoseReview?

}
