//
//  Review.swift
//  WineNotes
//
//  Created by Katie Willison on 11/26/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class Review : NSObject {
    
    var eyes = Eyes()
    var nose = Nose()
    var mouth = Mouth()
    
    var rating : Double?
    var varietal : String? // eventually change these to enums
    var country : String?
    var region : String?
    var name : String?
    var image : UIImage?
    var imageURL : NSURL?
    
    func updateFromCellDictionary(cellDictionary dict : Dictionary<String, RatingCell>) {
        eyes.color = dict[ReviewKeys.Color]?.colorValue
        eyes.opacity = dict[ReviewKeys.Opacity]?.value
        eyes.rim = dict[ReviewKeys.Rim]?.value
        eyes.spritz = dict[ReviewKeys.Spritz]?.boolValue
        
        nose.openness = dict[ReviewKeys.Openness]?.value
        
        mouth.body = dict[ReviewKeys.Body]?.value
        mouth.acidity = dict[ReviewKeys.Acidity]?.value
        mouth.alcohol = dict[ReviewKeys.Alcohol]?.value
        mouth.tannins = dict[ReviewKeys.Tannins]?.value
        mouth.residualSugar = dict[ReviewKeys.ResidualSugar]?.value

        rating = dict[ReviewKeys.Rating]?.value
        name = dict[ReviewKeys.Name]?.textValue
        if let index = dict[ReviewKeys.Varietal]?.value {
            varietal = dict[ReviewKeys.Varietal]?.pickerValues?[Int(index)]
        }
        if let index = dict[ReviewKeys.Country]?.value {
            country = dict[ReviewKeys.Country]?.pickerValues?[Int(index)]
        }
        if let index = dict[ReviewKeys.Region]?.value {
            region = dict[ReviewKeys.Region]?.pickerValues?[Int(index)]
        }
    }
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