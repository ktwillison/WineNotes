//
//  Aroma.swift
//  WineNotes
//
//  Created by Katie Willison on 11/20/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Aroma: NSManagedObject {
    init(_ description : String, wedgeColor: UIColor? = nil){
        aromaDescription = description
        color = wedgeColor
    }
    
    var aromaDescription : String = ""
    var path : UIBezierPath?
    var color : UIColor?
    
    
    // Added this method to avoid adding duplicate tags when the Aroma objects themselves
    // had changed, throwing the comparison operator off. 
    // tips from https://www.reddit.com/r/swift/comments/3q401o/how_to_find_custom_object_in_array_using_contains/
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherAroma = object as? Aroma {
            return (otherAroma.aromaDescription == aromaDescription) && (otherAroma.color == color)
        }
        return false
    }
    
    class func aromaFromDescription(searchText: String, inManagedObjectContext context: NSManagedObjectContext) -> Aroma? {
        // See if aroma is already in database
        let request = NSFetchRequest(entityName: "Aroma")
        request.predicate = NSPredicate(format: "aromaDesc = %@", searchText)
        if let aroma = (try? context.executeFetchRequest(request))?.first as? Aroma {
            return aroma
            
        // If not, create one, and add it to the database
        } else if let aroma = NSEntityDescription.insertNewObjectForEntityForName("Aroma", inManagedObjectContext: context) as? Aroma {
            aroma.aromaDesc = searchText
            return aroma
        }
        return nil
    }
    
}

func == (left: Aroma, right: Aroma) -> Bool {
    return (left.aromaDescription == right.aromaDescription) && (left.color == right.color)
}

func != (left: Aroma, right: Aroma) -> Bool {
    return (left.aromaDescription != right.aromaDescription) || (left.color != right.color)
}