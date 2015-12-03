//
//  MouthReview+CoreDataProperties.swift
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

extension MouthReview {

    @NSManaged var body: NSNumber?
    @NSManaged var acidity: NSNumber?
    @NSManaged var alcohol: NSNumber?
    @NSManaged var tannins: NSNumber?
    @NSManaged var length: NSNumber?
    @NSManaged var residualSugar: NSNumber?
    @NSManaged var aromas: NSOrderedSet?
    @NSManaged var review: WineReview?

}
