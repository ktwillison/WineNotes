//
//  AromaTag.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData


class AromaTag: NSManagedObject {

    class func aromaFromDescription(searchText: String, inManagedObjectContext context: NSManagedObjectContext) -> AromaTag? {
        // See if aroma is already in database
        let request = NSFetchRequest(entityName: "AromaTag")
        request.predicate = NSPredicate(format: "aromaDescription = %@", searchText)
        if let aroma = (try? context.executeFetchRequest(request))?.first as? AromaTag {
            return aroma
            
            // If not, create one, and add it to the database
        } else if let aroma = NSEntityDescription.insertNewObjectForEntityForName("AromaTag", inManagedObjectContext: context) as? AromaTag {
            aroma.aromaDescription = searchText
            return aroma
        }
        return nil
    }
}
