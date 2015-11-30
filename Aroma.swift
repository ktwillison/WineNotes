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
    
}

func ==(lhs: Aroma, rhs: Aroma) -> Bool {
    return (lhs.aromaDescription == rhs.aromaDescription) && (lhs.color == rhs.color)
}
