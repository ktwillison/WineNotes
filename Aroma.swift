//
//  Aroma.swift
//  WineNotes
//
//  Created by Katie Willison on 11/20/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class Aroma: NSObject {
    init(_ description : String){
        aromaDescription = description
    }
    
    var aromaDescription : String
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
    
}

func == (left: Aroma, right: Aroma) -> Bool {
    return (left.aromaDescription == right.aromaDescription) && (left.color == right.color)
}

func != (left: Aroma, right: Aroma) -> Bool {
    return (left.aromaDescription != right.aromaDescription) || (left.color != right.color)
}