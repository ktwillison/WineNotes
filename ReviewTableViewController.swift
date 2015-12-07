//
//  ReviewTableViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 11/26/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
import CoreLocation

class ReviewTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, InfoTextPresentationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    let review = Review()
    var selectedIndexPath : NSIndexPath?
    var coreLocationManager = CLLocationManager()
    var coreImageContext: CIContext!
    var coreImageFilter: CIFilter!
    
    
    // Keep track of reuse identifiers for each cell type
    private struct CellType {
        static let slider = "SliderCell"
        static let colorPicker = "ColorPickerCell"
        static let aroma = "AromaCell"
        static let selection = "PickerCell"
        static let imagePicker = "ImagePickerCell"
        static let image = "ImageCell"
        static let text = "TextCell"
    }
    
    // Keep track of segue identifiers for each cell type
    struct SegueType {
        static let showAromaWheel = "ShowAromaWheel"
        static let showInfoText = "ShowInfoText"
    }
    
    
    //Create a dictionary to define and retrieve values for each rating cell
    private let cellDictionary : Dictionary<String, RatingCell> = [
        // Eyes
        ReviewKeys.Color : RatingCell(cellTitle: "Color", cellType: CellType.colorPicker),
        ReviewKeys.Opacity : RatingCell(cellTitle: "Opacity", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        ReviewKeys.Rim : RatingCell(cellTitle: "Rim Width", cellType: CellType.slider, sliderStyle: .Numeric),
        ReviewKeys.Spritz : RatingCell(cellTitle: "Spritz", cellType: CellType.slider, sliderStyle: .Numeric),
        
        // Nose
        ReviewKeys.NoseAroma : RatingCell(cellTitle: "Scent Aromas", cellType: CellType.aroma),
        ReviewKeys.Openness : RatingCell(cellTitle: "Openness", cellType: CellType.slider, sliderStyle: .Openness),
        
        // Mouth
        ReviewKeys.MouthAroma : RatingCell(cellTitle: "Taste Aromas", cellType: CellType.aroma),
        ReviewKeys.Body : RatingCell(cellTitle: "Body", cellType: CellType.slider, sliderStyle: .LowMedHigh, infoText: AppData.descriptions["Body"]!),
        ReviewKeys.Acidity : RatingCell(cellTitle: "Acidity", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        ReviewKeys.Alcohol : RatingCell(cellTitle: "Alcohol", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        ReviewKeys.Tannins : RatingCell(cellTitle: "Tannins", cellType: CellType.slider, sliderStyle: .LowMedHigh),
        ReviewKeys.ResidualSugar : RatingCell(cellTitle: "Residual Sugar", cellType: CellType.slider, sliderStyle: .Numeric),
        
        // General
        ReviewKeys.Rating : RatingCell(cellTitle: "Rating", cellType: CellType.slider, sliderStyle: .Numeric),
        ReviewKeys.Varietal : RatingCell(cellTitle: "Varietal", cellType: CellType.selection, pickerValues: AppData.varietals),
        ReviewKeys.Country : RatingCell(cellTitle: "Country", cellType: CellType.selection, pickerValues: AppData.countries()),
        ReviewKeys.Region : RatingCell(cellTitle: "Region", cellType: CellType.selection, pickerValues: []),
        ReviewKeys.Name : RatingCell(cellTitle: "Title", cellType: CellType.text),
        ReviewKeys.ImagePicker : RatingCell(cellTitle: "ImagePicker", cellType: CellType.imagePicker, pickerValues: []),
        ReviewKeys.Image : RatingCell(cellTitle: "Image", cellType: CellType.image, pickerValues: [])
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
//        [self.cellDictionary["Color"]!,
        [self.cellDictionary[ReviewKeys.Opacity]!, self.cellDictionary[ReviewKeys.Rim]!, self.cellDictionary[ReviewKeys.Spritz]!],
        
        // Nose
        [self.cellDictionary[ReviewKeys.NoseAroma]!, self.cellDictionary[ReviewKeys.Openness]!],
        
        // Mouth
        [self.cellDictionary[ReviewKeys.MouthAroma]!, self.cellDictionary[ReviewKeys.Body]!, self.cellDictionary[ReviewKeys.Acidity]!, self.cellDictionary[ReviewKeys.Alcohol]!, self.cellDictionary[ReviewKeys.Tannins]!, self.cellDictionary[ReviewKeys.ResidualSugar]!],
        
        // General
        [self.cellDictionary[ReviewKeys.Rating]!, self.cellDictionary[ReviewKeys.Varietal]!, self.cellDictionary[ReviewKeys.Country]!, self.cellDictionary[ReviewKeys.Region]!, self.cellDictionary[ReviewKeys.ImagePicker]!, self.cellDictionary[ReviewKeys.Image]!,
            self.cellDictionary[ReviewKeys.Name]!
        ]
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
//        setManagedObjectContext()
        if AppData.managedObjectContext == nil {AppData.setManagedObjectContext() }
        
        // Set up core image properties
        coreImageContext = CIContext(options:nil)
        coreImageFilter = CIFilter(name: "CIPhotoEffectChrome")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // Update review object and store it in the database
    @IBAction func submitReview(sender: UIBarButtonItem) {
        review.updateFromCellDictionary(cellDictionary: cellDictionary)
        addReviewToDatabase(review)
        
        // Send the review over with the compressed image
        let reviewToSend = review
        if review.image != nil,
            let imageData = UIImageJPEGRepresentation(review.image!, 0.2) {
                reviewToSend.image = UIImage(data: imageData)
        }
        
        // Send a notification (for e.g. peer connectivity)
        let notification = NSNotification(
            name: "AddReview",
            object: self,
            userInfo: ["addedReview" : reviewToSend]
        )
        NSNotificationCenter.defaultCenter().postNotification(notification)

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
            
        } else if let cell = cell as? TextTableViewCell {
            cell.connectedCell = cellInfo
            cell.controllerDelegate = self
            cell.titleLabel?.text = cellInfo.title
            
        } else if let cell = cell as? ImagePickerTableViewCell {
            cell.controllerDelegate = self
            
        } else if let cell = cell as? ImageTableViewCell {
            cell.imageView?.image = review.image
            imageIndex = indexPath
        }

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
    
    
    // Calculate cell row height based on media size (or by  default for others)
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let ratingCell = cellList[indexPath.section][indexPath.row]
        switch ratingCell.identifier {
        // If cell holds media, the height should be relative to the media object's width
        case CellType.image:
            if let reviewImage = review.image {
                let aspectRatio = CGFloat(reviewImage.size.width / reviewImage.size.height)
                let width = tableView.frame.size.width
                let height = width / aspectRatio
                return height
            }
            return UITableViewAutomaticDimension
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    var imageIndex : NSIndexPath?
    var aromaIndecies = Set<NSIndexPath>()
    @IBAction func updateAromas(segue : UIStoryboardSegue) {
        tableView.reloadRowsAtIndexPaths(Array(aromaIndecies), withRowAnimation: .Automatic)
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
    
    //MARK: - Image picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        review.image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage
        applyFilterToImage()
        if imageIndex != nil {
            tableView.reloadRowsAtIndexPaths([imageIndex!], withRowAnimation: .Bottom)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Applies the chrome filter to the selected image, because EVERYTHING LOOKS BETTER WITH CHROME
    // Core image intro found at http://www.raywenderlich.com/76285/beginning-core-image-swift
    private func applyFilterToImage() {
        if review.image != nil {
            let image = CIImage(image: review.image!)
            coreImageFilter.setValue(image, forKey: kCIInputImageKey)
            if let outputImage : CIImage = coreImageFilter.outputImage {
                let cgimg = coreImageContext.createCGImage(outputImage, fromRect: outputImage.extent)
                review.image = UIImage(CGImage: cgimg)
            }
        }
    }
    
    private func saveImageToReview() {
        if review.image != nil {
            if let imageData = UIImageJPEGRepresentation(review.image!, 1.0),
                let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let unique = NSDate.timeIntervalSinceReferenceDate()
                    let url = documentsDirectory.URLByAppendingPathComponent("\(unique).jpg")
                    if imageData.writeToURL(url, atomically: true){
                        review.imageURL = "\(unique).jpg" //url
                    }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: - Core Data
//    var managedObjectContext: NSManagedObjectContext?
    
    private func addReviewToDatabase(newReview: Review){
        
        // managedObjectContext set in viewDidLoad
        AppData.managedObjectContext!.performBlock {
            
            // Save a persistant copy of the image
            self.saveImageToReview()
            
            // Put review into database
            WineReview.wineReviewFromReview(newReview, inManagedObjectContext: AppData.managedObjectContext!)
            
            //Save document, just to be safe :)
            AppDelegate.currentAppDelegate?.document?.saveToURL(
                (AppDelegate.currentAppDelegate?.document?.fileURL)!,
                forSaveOperation:.ForOverwriting
                ){success in}
//            self.printDatabaseStatistics(self.managedObjectContext!)
        }
    }
    
    // Print DB stats
    private func printDatabaseStatistics(context: NSManagedObjectContext) {
        context.performBlock {
            // the most efficient way to count objects
            let reviewCount = context.countForFetchRequest(NSFetchRequest(entityName: "WineReview"), error: nil)
            print("\(reviewCount) Reviews")
        }
    }
    
//    // Sets (or re-tries setting) managed object context
//    func setManagedObjectContext() {
//        AppDelegate.currentAppDelegate?.getContext { [weak weakSelf = self] (context, success) in
//            if success {
//                weakSelf?.managedObjectContext = context
//            } else {
//                // This may cause an endless loop.. but shouldn't as long as document state isn't whack
//                weakSelf?.setManagedObjectContext()
//            }
//        }
//    }
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
    var colorValue : UIColor?
    var textValue : String?
    var boolValue : Bool?
}

