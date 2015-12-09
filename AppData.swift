//
//  AppData.swift
//  WineNotes
//
//  Created by Katie Willison on 12/3/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import Foundation
import CoreData

struct AppData {
    
    static var managedObjectContext : NSManagedObjectContext?
    static var recentReviews : [WineReview]?
    
    // Sets (or re-tries setting) managed object context
    static func setManagedObjectContext() {
        AppDelegate.currentAppDelegate?.getContext { (context, success) in
            if success {
                self.managedObjectContext = context
                let notification = NSNotification(name: "ManagedObjectContextSet", object: nil, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            } else {
                // This may cause an endless loop.. but shouldn't as long as document state isn't whack
                self.setManagedObjectContext()
            }
        }
    }
    
    // Print DB stats
    static func printDatabaseStatistics() {
        managedObjectContext?.performBlock {
            // the most efficient way to count objects
            let reviewCount = managedObjectContext?.countForFetchRequest(NSFetchRequest(entityName: "WineReview"), error: nil)
            print("\(reviewCount) Reviews")
        }
    }
    
    static let varietals = ["Barbera",
        "Cabernet Franc",
        "Cabernet Sauvignon and Blends",
        "Carignane",
        "Charbono",
        "Chardonnay",
        "Chenin Blanc",
        "Dolcetto",
        "Gamay",
        "Gewurztraminer",
        "Grenache",
        "Gruner Veltliner",
        "Lagrein",
        "Malbec",
        "Marsanne",
        "Melon de Bourgogne",
        "Merlot",
        "Mourvedre",
        "Nebbiolo",
        "Petite Sirah",
        "Pineau d'Aunis",
        "Pinot Blanc",
        "Pinot Gris",
        "Pinot Noir",
        "Rhone Blends",
        "Riesling",
        "Romorantin",
        "Sangiovese",
        "Sauvignon Blanc",
        "Semillon",
        "Shiraz/Syrah",
        "Tempranillo",
        "Viognier",
        "Zinfandel"]
    
    static let regions : [(country: String, regionList:[String])] = [
        ("Argentina", []),
        ("Australia", ["New South Wales",
            "South Australia",
            "Victoria",
            "Western Australia"]),
        ("Austria", []),
        ("Canada", []),
        ("Chile", []),
        ("Croatia", []),
        ("France", ["Alsace",
            "Beaujolais",
            "Bordeaux",
            "Burgundy",
            "Chablis",
            "Champagne",
            "Languedoc-Roussillon",
            "Loire",
            "Provence",
            "Rhone",
            "Savoie/Jura",
            "Southwest France"]),
        ("Germany", ["Mittlerhein",
            "Mosel-Saar-Ruwer",
            "Nahe",
            "Pfalz",
            "Rheingau",
            "Rheinhessen"]),
        ("Greece", []),
        ("Hungary", []),
        ("Israel", []),
        ("Italy", ["Abruzzo",
            "Campania",
            "Emilia Romagna",
            "Friuli-Venezia-Giulia",
            "Lombardy",
            "Marche",
            "Piedmont",
            "Puglia",
            "Sardinia",
            "Sicily",
            "Trentino-Alto Adige",
            "Tuscany",
            "Umbria",
            "Veneto"]),
        ("Mexico", []),
        ("New Zealand", []),
        ("Slovenia", []),
        ("South Africa", []),
        ("Spain", ["Navarra",
            "Penedes",
            "Priorato",
            "Ribera del Duero",
            "Rioja"]),
        ("Switzerland", []),
        ("United States", ["California",
            "New York",
            "Oregon",
            "Washington"]),
        ("Other", [])
    ]
    
    static func countries() -> [String] {
        var countryList : [String] = []
        for r in regions {
            countryList.append(r.country)
        }
        return countryList
    }
    
    static func regionsForCountry(index: Int) -> [String] {
        return regions[index].regionList
    }
    
    static let descriptions : Dictionary<String, String> = [
        "Body" : "You can feel the 'body' of a wine much like you feel the difference between whole and fat-free milk: the former would have a 'full body', while the latter would have a 'light body'."
    ]
    
}

struct ReviewKeys {
    static let Color = "Color"
    static let Opacity = "Opacity"
    static let Rim = "Rim"
    static let Spritz = "Spritz"
    static let NoseAroma = "NoseAroma"
    static let Openness = "Openness"
    static let MouthAroma = "MouthAroma"
    static let Body = "Body"
    static let Acidity = "Acidity"
    static let Alcohol = "Alcohol"
    static let Tannins = "Tannins"
    static let ResidualSugar = "ResidualSugar"
    static let Rating = "Rating"
    static let Varietal = "Varietal"
    static let Country = "Country"
    static let Region = "Region"
    static let Name = "Name"
    static let ImagePicker = "ImagePicker"
    static let Image = "Image"
}
