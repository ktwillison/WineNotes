//
//  Review.swift
//  WineNotes
//
//  Created by Katie Willison on 11/26/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class Review {
    
    var eyes = Eyes()
    var nose = Nose()
    var mouth = Mouth()
    
    var rating : Double?
    var varietal : String? // eventually change these to enums
    var country : String?
    var region : String?
}

struct Eyes {
    var color : UIColor?
    var opacity : Double?
    var rim : Double?
    var spritz : Bool?
}

struct Nose {
    var aromas : [Aroma]?
    var openness : Double?
}

struct Mouth {
    var aromas : [Aroma]?
    var body : Double?
    var acidity : Double?
    var alcohol : Double?
    var tannins : Double?
    var length : Double?
    var residualSugar : Double?
}