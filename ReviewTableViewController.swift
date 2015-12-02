//
//  ReviewTableViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 11/26/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit

class ReviewTableViewController: UITableViewController {
    
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
    private struct SegueType {
        static let showAromaWheel = "ShowAromaWheel"
    }
    
    
    //Create a dictionary to define and retrieve values for each rating cell
    private let cellDictionary : Dictionary<String, RatingCell> = [
        // Eyes
        "Color" : RatingCell(cellTitle: "Color", cellType: CellType.colorPicker),
        "Opacity" : RatingCell(cellTitle: "Opacity", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Rim" : RatingCell(cellTitle: "Rim", cellType: CellType.slider, sliderStyle: .Numeric),
        "Spritz" : RatingCell(cellTitle: "Spritz", cellType: CellType.slider, sliderStyle: .Numeric),
        
        // Nose
        "NoseAroma" : RatingCell(cellTitle: "NoseAroma", cellType: CellType.aroma),
        "Openness" : RatingCell(cellTitle: "Openness", cellType: CellType.slider, sliderStyle: .Openness),
        
        // Mouth
        "MouthAroma" : RatingCell(cellTitle: "MouthAroma", cellType: CellType.aroma),
        "Body" : RatingCell(cellTitle: "Body", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Acidity" : RatingCell(cellTitle: "Acidity", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Alcohol" : RatingCell(cellTitle: "Alcohol", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "Tannins" : RatingCell(cellTitle: "Tannins", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        "ResidualSugar" : RatingCell(cellTitle: "ResidualSugar", cellType: CellType.slider, sliderStyle: .Numeric),
        
        // General
        "Rating" : RatingCell(cellTitle: "Rating", cellType: CellType.slider, sliderStyle: .Numeric),
        "Varietal" : RatingCell(cellTitle: "Varietal", cellType: CellType.selection, pickerValues: AppData.varietals),
        "Country" : RatingCell(cellTitle: "Country", cellType: CellType.selection),
        "Region" : RatingCell(cellTitle: "Region", cellType: CellType.selection)
    ]
    
    
    // Create a list to determine the order of the cells, retrieving elements from the dictionary
    private let headings = ["Eyes", "Nose", "Mouth", "General"]
    private lazy var cellList : [[RatingCell]] = [
        // Eyes
        [self.cellDictionary["Color"]!, self.cellDictionary["Opacity"]!, self.cellDictionary["Rim"]!, self.cellDictionary["Spritz"]!],
        
        // Nose
        [self.cellDictionary["NoseAroma"]!, self.cellDictionary["Openness"]!],
        
        // Mouth
        [self.cellDictionary["MouthAroma"]!, self.cellDictionary["Body"]!, self.cellDictionary["Acidity"]!, self.cellDictionary["Alcohol"]!, self.cellDictionary["Tannins"]!, self.cellDictionary["ResidualSugar"]!],
        
        // General
        [self.cellDictionary["Rating"]!, self.cellDictionary["Varietal"]!, self.cellDictionary["Country"]!, self.cellDictionary["Region"]!]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.titleLabel?.text = cellInfo.title
            cell.connectedCell = cellInfo
            cell.addGestureRecognizer(UITapGestureRecognizer(target: cell, action: "moveSliderToPoint:"))
        } else if let cell = cell as? PickerTableViewCell {
            cell.connectedCell = cellInfo
            cell.titleLabel?.text = cellInfo.title
            cell.picker.hidden = (indexPath != selectedIndexPath)
        } else if let cell = cell as? AromaTableViewCell {
            cell.titleLabel?.text = cellInfo.title
            if headings[indexPath.section] == "Mouth" {
                cell.aromaType = AromaType.Mouth
            } else {
                cell.aromaType = AromaType.Nose
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
            
            
//            if let tagCollectionVC = vc.childViewControllers[0] as? TagCollectionViewController {
//                if let sender = sender as? AromaTableViewCell {
//                    tagCollectionVC.aromaType = sender.aromaType
//                    if sender.aromaType == .Mouth {
//                        tagCollectionVC.tags = review.mouth.aromas ?? []
//                    } else {
//                        tagCollectionVC.tags = review.nose.aromas ?? []
//                    }
//                }
//            }
        }
    }
    
    @IBAction func updateAromas(segue : UIStoryboardSegue) {
        print("done!")
    }

}

class RatingCell {
    init(cellTitle : String, cellType : String, sliderStyle style : SliderStyle = SliderStyle.None, pickerValues pickerVals : [String] = []) {
        title = cellTitle
        identifier = cellType
        sliderStyle = style
        pickerValues = pickerVals
    }
    
    let identifier : String!
    let title : String!
    var sliderStyle : SliderStyle!
    var pickerValues : [String]!
    var value : Double?
}

struct AppData {
    static let varietals = ["a", "b"]
}
