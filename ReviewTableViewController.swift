//
//  ReviewTableViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 11/26/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import CoreData

class ReviewTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, InfoTextPresentationDelegate {
    
    let review = Review()
    var selectedIndexPath : NSIndexPath?
    
    // Keep track of reuse identifiers for each cell type
    private struct CellType {
        static let slider = "SliderCell"
        static let colorPicker = "ColorPickerCell"
        static let aroma = "AromaCell"
        static let selection = "PickerCell"
    }
    
    // Keep track of segue identifiers for each cell type
    struct SegueType {
        static let showAromaWheel = "ShowAromaWheel"
        static let showInfoText = "ShowInfoText"
    }
    
    
    //Create a dictionary to define and retrieve values for each rating cell
    private let cellDictionary : Dictionary<String, RatingCell> = [
        // Eyes
        "Color" : RatingCell(cellTitle: "Color", cellType: CellType.colorPicker),
        "Opacity" : RatingCell(cellTitle: "Opacity", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Rim" : RatingCell(cellTitle: "Rim Width", cellType: CellType.slider, sliderStyle: .Numeric),
        "Spritz" : RatingCell(cellTitle: "Spritz", cellType: CellType.slider, sliderStyle: .Numeric),
        
        // Nose
        "NoseAroma" : RatingCell(cellTitle: "Scent Aromas", cellType: CellType.aroma),
        "Openness" : RatingCell(cellTitle: "Openness", cellType: CellType.slider, sliderStyle: .Openness),
        
        // Mouth
        "MouthAroma" : RatingCell(cellTitle: "Taste Aromas", cellType: CellType.aroma),
        "Body" : RatingCell(cellTitle: "Body", cellType: CellType.slider, sliderStyle: .LowMedHigh, infoText: AppData.descriptions["Body"]!),
        "Acidity" : RatingCell(cellTitle: "Acidity", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Alcohol" : RatingCell(cellTitle: "Alcohol", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Tannins" : RatingCell(cellTitle: "Tannins", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "ResidualSugar" : RatingCell(cellTitle: "Residual Sugar", cellType: CellType.slider, sliderStyle: .Numeric),
        
        // General
        "Rating" : RatingCell(cellTitle: "Rating", cellType: CellType.slider, sliderStyle: .Numeric),
        "Varietal" : RatingCell(cellTitle: "Varietal", cellType: CellType.selection, pickerValues: AppData.varietals),
        "Country" : RatingCell(cellTitle: "Country", cellType: CellType.selection, pickerValues: AppData.countries()),
        "Region" : RatingCell(cellTitle: "Region", cellType: CellType.selection, pickerValues: [])
    ]
    
    func updateRegionList(){
        if let countryIndex = cellDictionary["Country"]?.value {
            if (cellDictionary["Region"]?.pickerValues)! != AppData.regionsForCountry(Int(countryIndex)){
                cellDictionary["Region"]?.pickerValues = AppData.regionsForCountry(Int(countryIndex))
            }
        } else {
            cellDictionary["Region"]?.pickerValues = []
        }
    }
    
    
    // Create a list to determine the order of the cells, retrieving elements from the dictionary
    private let headings = ["Eyes", "Nose", "Mouth", "General"]
    private lazy var cellList : [[RatingCell]] = [
        // Eyes
//        [self.cellDictionary["Color"]!, self.cellDictionary["Opacity"]!, self.cellDictionary["Rim"]!, self.cellDictionary["Spritz"]!],
        [self.cellDictionary["Opacity"]!, self.cellDictionary["Rim"]!, self.cellDictionary["Spritz"]!],
        
        // Nose
        [self.cellDictionary["NoseAroma"]!, self.cellDictionary["Openness"]!],
        
        // Mouth
        [self.cellDictionary["MouthAroma"]!, self.cellDictionary["Body"]!, self.cellDictionary["Acidity"]!, self.cellDictionary["Alcohol"]!, self.cellDictionary["Tannins"]!, self.cellDictionary["ResidualSugar"]!],
        
        // General
        [self.cellDictionary["Rating"]!, self.cellDictionary["Varietal"]!, self.cellDictionary["Country"]!, self.cellDictionary["Region"]!]
    ]
    
    private func getCellTag(indexPath : NSIndexPath) -> Int {
        var tagNumber = 0
        for var s = 0; s<indexPath.section; ++s {
            tagNumber = tagNumber + cellList[s].count
        }
        return tagNumber + indexPath.row
    }
    
    private func getCellForTag(tag : Int) -> RatingCell? {
        var tagNumber = tag
        for s in cellList {
            if tagNumber > s.count {
                tagNumber = tagNumber - s.count
            } else {
                return s[tagNumber]
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        title = "Wine Notes"
        
        // Set managedObjectContext
        setManagedObjectContext()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cellList.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellInfo = cellList[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellInfo.identifier, forIndexPath: indexPath)
        
        if let cell = cell as? SliderTableViewCell {
            cell.delegate = self
            cell.titleLabel?.text = cellInfo.title
            cell.connectedCell = cellInfo
            cell.addGestureRecognizer(UITapGestureRecognizer(target: cell, action: "moveSliderToPoint:"))
            cell.showInfoTextButton.tag = getCellTag(indexPath)
        } else if let cell = cell as? PickerTableViewCell {
//            if cellInfo.pickerValues.count == 0 {
//                cell.hidden = true
//                cell.picker.hidden = true
//            } else {
                cell.connectedCell = cellInfo
                cell.titleLabel?.text = cellInfo.title
                if let index = cellInfo.value {
                    cell.valueLabel?.text = cellInfo.pickerValues?[Int(index)]
                } else {
                    cell.valueLabel?.text = " "
                }
                cell.picker.hidden = (indexPath != selectedIndexPath)
                if !cell.picker.hidden{ cell.picker.reloadAllComponents() }
            updateRegionList()   /// NEED TO FIND A BETTER PLACE FOR THIS
//            }
        } else if let cell = cell as? AromaTableViewCell {
            cell.titleLabel?.text = cellInfo.title
            aromaIndecies.insert(indexPath)
            if headings[indexPath.section] == "Mouth" {
                cell.aromaType = AromaType.Mouth
                cell.aromas = review.mouth.aromas ?? []
            } else {
                cell.aromaType = AromaType.Nose
                cell.aromas = review.nose.aromas ?? []
            }
        } else {
//            cell.textLabel?.text = cellInfo.title
        }
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headings[section]
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let previouslySelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        var reloadIndexPaths : [NSIndexPath] = [indexPath]
        
        // If we select the selected index again, collapse it, otherwise expand it
        if indexPath == previouslySelectedIndexPath {
            selectedIndexPath = nil
            
        } else if previouslySelectedIndexPath != nil {
            reloadIndexPaths.append(previouslySelectedIndexPath!)
        }
        
        // Function call prompted by the following tutorial:
        // https://www.youtube.com/watch?v=VWgr_wNtGPM
        tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .Automatic)
    }

    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath == selectedIndexPath && cellList[indexPath.section][indexPath.row].identifier == CellType.selection {
//            return 300
//        }
//        return self.tableView.rowHeight
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation
    
    func callSegueFromCell(sender: UIButton) {
        performSegueWithIdentifier(SegueType.showInfoText, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueType.showAromaWheel {
            let vc = segue.destinationViewController as! AromaViewController
            if let sender = sender as? AromaTableViewCell {
                vc.aromaType = sender.aromaType
                if sender.aromaType == .Mouth {
                    vc.initializeWithTags = review.mouth.aromas ?? []
                } else {
                    vc.initializeWithTags = review.nose.aromas ?? []
                }
            }
        } else if segue.identifier == SegueType.showInfoText {
            if let infoTextVC = segue.destinationViewController as? InfoTextViewController,
                let senderButton = sender as? UIButton  {
                    if let senderCell = getCellForTag(senderButton.tag) {
                        infoTextVC.connectedCell = senderCell
                    }
                    if let ppc = infoTextVC.popoverPresentationController {
                        ppc.sourceRect = senderButton.frame
                        ppc.delegate = self
                    }
            }
        }
    }
    
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .None
//    }

    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        if style == .FullScreen {
            let navcon = UINavigationController(rootViewController: controller.presentedViewController)
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
            visualEffectView.frame = navcon.view.bounds
            visualEffectView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
            navcon.view.insertSubview(visualEffectView, atIndex: 0)
            return navcon
        }
        return nil
    }
    
    var aromaIndecies = Set<NSIndexPath>()
    @IBAction func updateAromas(segue : UIStoryboardSegue) {
        tableView.reloadRowsAtIndexPaths(Array(aromaIndecies), withRowAnimation: .Automatic)
    }
    
    
    //MARK: - Core Data
    var managedObjectContext: NSManagedObjectContext?
    
    private func updateDatabase(newReview: Review){
        
        // managedObjectContext set in viewDidLoad
        managedObjectContext!.performBlock {
            
            // Put review into database
            WineReview.wineReviewFromReview(newReview, inManagedObjectContext: self.managedObjectContext!)
            
            //Save document, just to be safe :)
            AppDelegate.currentAppDelegate?.document?.saveToURL(
                (AppDelegate.currentAppDelegate?.document?.fileURL)!,
                forSaveOperation:.ForOverwriting
                ){success in}
        }
        
        printDatabaseStatistics(managedObjectContext!)
    }
    
    // Print DB stats
    private func printDatabaseStatistics(context: NSManagedObjectContext) {
        context.performBlock {
            // the most efficient way to count objects
            let reviewCount = context.countForFetchRequest(NSFetchRequest(entityName: "WineReview"), error: nil)
            print("\(reviewCount) Reviews")
        }
    }
    
    // Sets (or re-tries setting) managed object context
    func setManagedObjectContext() {
        AppDelegate.currentAppDelegate?.getContext { [weak weakSelf = self] (context, success) in
            if success {
                weakSelf?.managedObjectContext = context
            } else {
                // This may cause an endless loop.. but shouldn't as long as document state isn't whack
                weakSelf?.setManagedObjectContext()
            }
        }
    }
}

class RatingCell {
    init(cellTitle : String, cellType : String, sliderStyle style : SliderStyle = SliderStyle.None, pickerValues pickerVals : [String] = [], infoText info : String = "") {
        title = cellTitle
        identifier = cellType
        sliderStyle = style
        pickerValues = pickerVals
        infoText = info
    }
    
    let identifier : String!
    let title : String!
    let infoText : String!
    var sliderStyle : SliderStyle!
    var pickerValues : [String]! {
        didSet { value = nil } // New array invalidates current index
    }
    var value : Double?
}

struct AppData {
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
    "Openness" : "",
    "Body" : "You can feel the 'body' of a wine much like you feel the difference between whole and fat-free milk: the former would have a 'full body', while the latter would have a 'light body'."
    ]
    
}
