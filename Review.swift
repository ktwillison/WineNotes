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
import CoreLocation


// Main intermediate data model for interfacing between the ReviewTableViewController and Core Data,
// as well as peer-to-peer connectivity through NSCoding encoding
class Review : NSObject, NSCoding {
    
    // Fields for each review dimension:
    var eyes = Eyes()
    var nose = Nose()
    var mouth = Mouth()
    
    var id : String?
    var date : NSDate?
    var rating : Double?
    var varietal : String? // will eventually change these to enums
    var country : String?
    var region : String?
    var name : String?
    var image : UIImage?
    var imageURL : String?
    var location : CLLocationCoordinate2D?
    
    // Translat the ReviewTableViewController's object into a Review object
    func updateFromCellDictionary(cellDictionary dict : Dictionary<String, RatingCell>) {
        eyes.color = dict[ReviewKeys.Color]?.colorValue
        eyes.opacity = dict[ReviewKeys.Opacity]?.value
        eyes.rim = dict[ReviewKeys.Rim]?.value
        eyes.spritz = dict[ReviewKeys.Spritz]?.value
        
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
    
    override init() {super.init()}
    
    // Translate a WineReview database object into a Review object
    init(fromWineReview review : WineReview){
        
        date = review.date
        region = review.region
        country = review.country
        name = review.name
        varietal = review.varietal
        imageURL = review.imageURL
        image = review.getImage()
        id = review.id
        if review.rating != nil {rating = Double(review.rating!)}
        location = review.getCoordinate()
        
        if review.eyes?.color != nil { eyes.color = NSKeyedUnarchiver.unarchiveObjectWithData((review.eyes?.color)!) as? UIColor}
        if review.eyes?.opacity != nil {eyes.opacity = Double(review.eyes!.opacity!)}
        if review.eyes?.rim != nil {eyes.rim = Double(review.eyes!.rim!)}
        if review.eyes?.spritz != nil {eyes.spritz = Double(review.eyes!.spritz!)}
 
        if review.nose?.openness != nil {nose.openness = Double(review.nose!.openness!)}
    
        if review.mouth?.body != nil {mouth.body = Double(review.mouth!.body!)}
        if review.mouth?.acidity != nil {mouth.acidity = Double(review.mouth!.acidity!)}
        if review.mouth?.alcohol != nil {mouth.alcohol = Double(review.mouth!.alcohol!)}
        if review.mouth?.tannins != nil {mouth.tannins = Double(review.mouth!.tannins!)}
        if review.mouth?.length != nil {mouth.length = Double(review.mouth!.length!)}
        if review.mouth?.residualSugar != nil {mouth.residualSugar = Double(review.mouth!.residualSugar!)}
        
        for aroma in review.mouth?.aromas?.array as? [AromaTag] ?? [] where aroma.aromaDescription != nil {
            mouth.aromas?.append(Aroma(aroma.aromaDescription!))
        }
        
        for aroma in review.nose?.aromas?.array as? [AromaTag] ?? [] where aroma.aromaDescription != nil {
            nose.aromas?.append(Aroma(aroma.aromaDescription!))
        }

    }
    
    // Initialize a Review from NSCoded data
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        id = decoder.decodeObjectForKey("id") as? String
        name = decoder.decodeObjectForKey("name") as? String
        rating = decoder.decodeObjectForKey("rating") as? Double
        region = decoder.decodeObjectForKey("region") as? String
        date = decoder.decodeObjectForKey("date") as? NSDate
        country = decoder.decodeObjectForKey("country") as? String
        varietal = decoder.decodeObjectForKey("varietal") as? String
        imageURL = decoder.decodeObjectForKey("imageURL") as? String
        image = decoder.decodeObjectForKey("image") as? UIImage
        if let locationDict = decoder.decodeObjectForKey("location") as? Dictionary<String, Double> {
            location = CLLocationCoordinate2D(latitude: locationDict["latitude"]!, longitude: locationDict["longitude"]!)
        }
        
        eyes.opacity = decoder.decodeObjectForKey("eyes_opacity") as? Double
        eyes.rim = decoder.decodeObjectForKey("eyes_rim") as? Double
        eyes.spritz = decoder.decodeObjectForKey("eyes_spritz") as? Double
        eyes.color = decoder.decodeObjectForKey("eyes_color") as? UIColor
        
        nose.openness = decoder.decodeObjectForKey("nose_openness") as? Double
        let noseAromas = decoder.decodeObjectForKey("nose_aromas") as? [String]
        
        mouth.acidity = decoder.decodeObjectForKey("mouth_acidity") as? Double
        mouth.body = decoder.decodeObjectForKey("mouth_body") as? Double
        mouth.alcohol = decoder.decodeObjectForKey("mouth_alcohol") as? Double
        mouth.tannins = decoder.decodeObjectForKey("mouth_tannins") as? Double
        mouth.length = decoder.decodeObjectForKey("mouth_length") as? Double
        mouth.residualSugar = decoder.decodeObjectForKey("mouth_residualSugar") as? Double
        let mouthAromas = decoder.decodeObjectForKey("mouth_aromas") as? [String]
        
        nose.aromas = []
        for aroma in noseAromas ?? [] {
            nose.aromas?.append(Aroma(aroma))
        }
        
        mouth.aromas = []
        for aroma in mouthAromas ?? [] {
            mouth.aromas?.append(Aroma(aroma))
        }
    }
    
    // Encode the object via NSCoder
    func encodeWithCoder(coder: NSCoder) {
        if let id = id { coder.encodeObject(id, forKey: "id") }
        if let name = name { coder.encodeObject(name, forKey: "name") }
        if let rating = rating { coder.encodeObject(rating, forKey: "rating") }
        if let region = region { coder.encodeObject(region, forKey: "region") }
        if let date = date { coder.encodeObject(date, forKey: "date") }
        if let country = country { coder.encodeObject(country, forKey: "country") }
        if let varietal = varietal { coder.encodeObject(varietal, forKey: "varietal") }
        if let imageURL = imageURL { coder.encodeObject(imageURL, forKey: "imageURL") }
        if let image = image { coder.encodeObject(image, forKey: "image") }
        if location != nil {
            let locationDict : Dictionary<String, Double> = ["latitude" : location!.latitude, "longitude" : location!.longitude]
            coder.encodeObject(locationDict, forKey: "location")
        }

        if let eyes_opacity = eyes.opacity { coder.encodeObject(eyes_opacity, forKey: "eyes_opacity") }
        if let eyes_rim = eyes.rim { coder.encodeObject(eyes_rim, forKey: "eyes_rim") }
        if let eyes_spritz = eyes.spritz { coder.encodeObject(eyes_spritz, forKey: "eyes_spritz") }
        if let eyes_color = eyes.color { coder.encodeObject(eyes_color, forKey: "eyes_color") }
        
        if let nose_openness = nose.openness { coder.encodeObject(nose_openness, forKey: "nose_openness") }
        
        var noseAromas = [String]()
        if let noseAromaTags = nose.aromas {
            for aroma in noseAromaTags where aroma.aromaDescription != nil {
                noseAromas.append(aroma.aromaDescription!)
            }
            coder.encodeObject(noseAromas, forKey: "nose_aromas")
        }
        
        if let mouth_acidity = mouth.acidity { coder.encodeObject(mouth_acidity, forKey: "mouth_acidity") }
        if let mouth_body = mouth.body { coder.encodeObject(mouth_body, forKey: "mouth_body") }
        if let mouth_alcohol = mouth.alcohol { coder.encodeObject(mouth_alcohol, forKey: "mouth_alcohol") }
        if let mouth_tannins = mouth.tannins { coder.encodeObject(mouth_tannins, forKey: "mouth_tannins") }
        if let mouth_length = mouth.length { coder.encodeObject(mouth_length, forKey: "mouth_length") }
        if let mouth_residualSugar = mouth.residualSugar { coder.encodeObject(mouth_residualSugar, forKey: "mouth_residualSugar") }
        
        var mouthAromas = [String]()
        if let mouthAromaTags = nose.aromas {
            for aroma in mouthAromaTags where aroma.aromaDescription != nil {
                mouthAromas.append(aroma.aromaDescription!)
            }
            coder.encodeObject(mouthAromas, forKey: "mouth_aromas")
        }
    }
}

// Structure for review dimensions
struct Eyes {
    var color : UIColor?
    var opacity : Double?
    var rim : Double?
    var spritz : Double?
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