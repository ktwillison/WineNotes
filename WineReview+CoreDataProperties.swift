//
//  WineReview+CoreDataProperties.swift
//  WineNotes
//
//  Created by Katie Willison on 12/8/15.
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
    @NSManaged var imageURL: String?
    @NSManaged var name: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var region: String?
    @NSManaged var varietal: String?
    @NSManaged var id: String?
    @NSManaged var location: NSData?
    @NSManaged var eyes: EyesReview?
    @NSManaged var mouth: MouthReview?
    @NSManaged var nose: NoseReview?

}
