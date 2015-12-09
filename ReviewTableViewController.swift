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
    
    // Data Model
    var review = Review()
    
    // Keep track of various cells/ text fields etc
    private var selectedIndexPath : NSIndexPath?
    private var textField : UITextField?
    private var textCellIndexPath : NSIndexPath?
    
    // Managers
    private var coreLocationManager = CLLocationManager()
    private var coreImageContext: CIContext!
    private var coreImageFilter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = 100
        tableView.estimatedRowHeight = 160.0
        title = "Wine Notes"
        
        // Set up core image properties
        coreImageContext = CIContext(options:nil)
        coreImageFilter = CIFilter(name: "CIPhotoEffectChrome")
        
        // Set up core location manager
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        
        // Create a SliderTableViewCell
        if let cell = cell as? SliderTableViewCell {
            cell.delegate = self
            cell.titleLabel?.text = cellInfo.title
            cell.connectedCell = cellInfo
            cell.addGestureRecognizer(UITapGestureRecognizer(target: cell, action: "moveSliderToPoint:"))
            cell.showInfoTextButton.tag = getCellTag(indexPath)
        
        // Create a PickerTableViewCell
        } else if let cell = cell as? PickerTableViewCell {
            cell.connectedCell = cellInfo
            cell.parentTableView = self
            cell.titleLabel?.text = cellInfo.title
            if let index = cellInfo.value {
                cell.valueLabel?.text = cellInfo.pickerValues?[Int(index)]
            } else {
                cell.valueLabel?.text = " "
            }
            cell.picker.hidden = (indexPath != selectedIndexPath)
            if !cell.picker.hidden{ cell.picker.reloadAllComponents() }
        
        // Create an AromaTableViewCell
        } else if let cell = cell as? AromaTableViewCell {
            cell.titleLabel?.text = cellInfo.title
            aromaIndecies.insert(indexPath)
            if headings[indexPath.section].title == "Mouth" {
                cell.aromaType = AromaType.Mouth
                cell.aromas = review.mouth.aromas ?? []
            } else {
                cell.aromaType = AromaType.Nose
                cell.aromas = review.nose.aromas ?? []
            }
            
        // Create a TextTableViewCell
        } else if let cell = cell as? TextTableViewCell {
            cell.connectedCell = cellInfo
            cell.controllerDelegate = self
            textCellIndexPath = indexPath
            cell.titleLabel?.text = cellInfo.title
            cell.nameTextField.text = cellInfo.textValue ?? ""
            textField = cell.nameTextField
        
        // Create an ImagePickerTableViewCell
        } else if let cell = cell as? ImagePickerTableViewCell {
            cell.controllerDelegate = self
        
        // Create an ImageTableViewCell
        } else if let cell = cell as? ImageTableViewCell {
            cell.imageView?.image = review.image
            imageIndex = indexPath
        }

        return cell
    }
    
    // Create custom header views
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let  headerCell = tableView.dequeueReusableCellWithIdentifier(CellType.header) as? ReviewHeaderTableViewCell {
            headerCell.cellImage.image = headings[section].image
            headerCell.cellText.text = headings[section].title
            headerCell.contentView.backgroundColor = UIColor.whiteColor()
            return headerCell.contentView // Otherwise we get "No cell for indexPath" errors
        }
        return nil
    }
    
    // Return size for the custom header view.
    // Custom header still produces 'Unable to simultaneously satisfy constraints' errors,
    // but it seems like this is a known issue (with no tidy workaround):
    // https://github.com/daveanderson/TableViewHeader
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // Handle selecting a row, reloading cells where necessary:
    // expanding/ collapsing picker views, resigning text field delegates, etc.
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
        
        if indexPath != textCellIndexPath {
            textField?.resignFirstResponder()
        }
        
        // Function call inspired by the following tutorial:
        // https://www.youtube.com/watch?v=VWgr_wNtGPM
        tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .Automatic)
    }
    
    
    // Calculate cell row height based on image size (or by  default for others)
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let ratingCell = cellList[indexPath.section][indexPath.row]
        switch ratingCell.identifier {
            
        // If cell holds media, the height should be relative to the media object's width
        case CellType.image:
            if let reviewImage = review.image {
                let aspectRatio = CGFloat(reviewImage.size.width / reviewImage.size.height)
                let width = tableView.contentSize.width
                let height = width / aspectRatio
                return height
            }
            return UITableViewAutomaticDimension
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    // Update aromas on segue return & reload appropriate cells
    private var imageIndex : NSIndexPath?
    private var aromaIndecies = Set<NSIndexPath>()
    @IBAction func updateAromas(segue : UIStoryboardSegue) {
        tableView.reloadRowsAtIndexPaths(Array(aromaIndecies), withRowAnimation: .Automatic)
    }
    
    
    // MARK: - Navigation
    
    // Delegate method to call a segue from the VC, initiated by a cell
    func callSegueFromCell(sender: UIButton) {
        performSegueWithIdentifier(SegueType.showInfoText, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueType.showAromaWheel {
            
            // Prepare aroma view segue
            let vc = segue.destinationViewController as! AromaViewController
            if let sender = sender as? AromaTableViewCell {
                vc.aromaType = sender.aromaType
                if sender.aromaType == .Mouth {
                    vc.initializeWithTags = review.mouth.aromas ?? []
                } else {
                    vc.initializeWithTags = review.nose.aromas ?? []
                }
            }
        
        // Prepare infotext popover segue
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

    //MARK: - Info popovers
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
        
        // Pick an image
        review.image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage
       
        // Always apply the chrome filter (because why not)
        applyFilterToImage()
        if imageIndex != nil {
            tableView.reloadRowsAtIndexPaths([imageIndex!], withRowAnimation: .Bottom)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Dismiss image picker on cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Applies the chrome filter to the selected image, because EVERYTHING LOOKS BETTER WITH CHROME
    // Core image intro found at http://www.raywenderlich.com/76285/beginning-core-image-swift
    private func applyFilterToImage() {
        if review.image != nil {
            let image = CIImage(image: review.image!)
            coreImageFilter.setValue(image, forKey: kCIInputImageKey)
            if let outputImage : CIImage = coreImageFilter.outputImage {
                var cgimg = coreImageContext.createCGImage(outputImage, fromRect: outputImage.extent)
                
                // ensure that image is square
                if review.image!.size.width != review.image!.size.height {
                    let newSize = min(review.image!.size.width, review.image!.size.height)
                    let imgCenter = CGPoint(x: review.image!.size.width/2, y: review.image!.size.height/2)
                    let newImageOrigin = CGPoint(x: imgCenter.x - newSize/2 , y: imgCenter.y - newSize/2)
                    let cropRect = CGRect(origin: newImageOrigin, size: CGSize(width: newSize, height: newSize))
                    cgimg = CGImageCreateWithImageInRect(cgimg, cropRect) ?? cgimg
                }
                
                review.image = UIImage(CGImage: cgimg)
            }
        }
    }
    
    // Store an image in the document directory, and set the corresponding review's URL
    private func setURLForReviewImage(review : Review) {
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
    
    
    //MARK: - Core Data
    
    // Update review object and store it in the database
    @IBAction func submitReview(sender: UIBarButtonItem) {
        
        // Add a copy of this review object so that we avoid race conditions
        review.updateFromCellDictionary(cellDictionary: cellDictionary)
        let reviewCopyData = NSKeyedArchiver.archivedDataWithRootObject(review)
        if let reviewCopy = NSKeyedUnarchiver.unarchiveObjectWithData(reviewCopyData) as? Review {
            addReviewToDatabase(reviewCopy)
        }
        
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
        
        // Reset review and cell dictionary objects
        review = Review()
        cellDictionaryAndList = CellDictionary()
        cellDictionary = cellDictionaryAndList.cellDictionary
        cellList = cellDictionaryAndList.cellList
        selectedIndexPath = nil
        
        // Move to history tab on submit
        if let tabBar = self.tabBarController {
            tabBar.selectedIndex = 0
        }
    }
    
    private func addReviewToDatabase(newReview: Review){
        
        // managedObjectContext set in viewDidLoad
        AppData.managedObjectContext!.performBlock {
            
            // Save a persistant copy of the image
            self.setURLForReviewImage(newReview)
            
            // Put review into database
            WineReview.wineReviewFromReview(newReview, inManagedObjectContext: AppData.managedObjectContext!)
            
            //Save document, just to be safe :)
            AppDelegate.currentAppDelegate?.document?.saveToURL(
                (AppDelegate.currentAppDelegate?.document?.fileURL)!,
                forSaveOperation:.ForOverwriting
                ){success in}
//            AppData.printDatabaseStatistics(self.managedObjectContext!)
        }
    }
    
    
    //MARK: - Cell Data Model
    
    // Keep track of segue identifiers for each cell type
    private struct SegueType {
        static let showAromaWheel = "ShowAromaWheel"
        static let showInfoText = "ShowInfoText"
        static let showHistory = "ShowHistory"
    }

    // Called when a pickerviewcell is set -- update the region ist to reflect the selected coutry
    func updateRegionList() {
        if let countryIndex = cellDictionary["Country"]?.value {
            if (cellDictionary["Region"]?.pickerValues)! != AppData.regionsForCountry(Int(countryIndex)){
                cellDictionary["Region"]?.pickerValues = AppData.regionsForCountry(Int(countryIndex))
            }
        } else {
            cellDictionary["Region"]?.pickerValues = []
        }
    }
    
    // Create a list to determine the order of the cells, retrieving elements from the dictionary
    private let headings : [(title: String, image: UIImage?)] = [("General", UIImage(named: "text.png")), ("Eyes", UIImage(named: "eye2.png")), ("Nose", UIImage(named: "nose.png")), ("Mouth", UIImage(named: "mouth.png"))]
    
    // Create a dictionary and corresponding mapping to define and retrieve values and 
    // implementation-specific parameters for each rating cell
    private var cellDictionaryAndList = CellDictionary()
    private lazy var cellDictionary : Dictionary<String, RatingCell> = self.cellDictionaryAndList.cellDictionary
    private lazy var cellList : [[RatingCell]] = self.cellDictionaryAndList.cellList
    
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
            if tagNumber >= s.count {
                tagNumber = tagNumber - s.count
            } else {
                return s[tagNumber]
            }
        }
        return nil
    }
}

// Keep track of reuse identifiers for each cell type
struct CellType {
    static let slider = "SliderCell"
    static let colorPicker = "ColorPickerCell"
    static let aroma = "AromaCell"
    static let selection = "PickerCell"
    static let imagePicker = "ImagePickerCell"
    static let image = "ImageCell"
    static let text = "TextCell"
    static let header = "HeaderCell"
}

class RatingCell {
    init(cellTitle : String, cellType : String, sliderStyle style : SliderStyle = SliderStyle.None, pickerValues pickerVals : [String] = [], infoText info : String? = nil) {
        title = cellTitle
        identifier = cellType
        sliderStyle = style
        pickerValues = pickerVals
        infoText = info ?? "A good dscription of \(cellTitle) is coming in version 2!"
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

// We wrap this dictionary in an object so it's easy to reset when needed
class CellDictionary {
    
    // Hold info on what parameters each cell should contain
    let cellDictionary : Dictionary<String, RatingCell> = [
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
        ReviewKeys.Rating : RatingCell(cellTitle: "Rating", cellType: CellType.slider, sliderStyle: .Rating),
        ReviewKeys.Varietal : RatingCell(cellTitle: "Varietal", cellType: CellType.selection, pickerValues: AppData.varietals),
        ReviewKeys.Country : RatingCell(cellTitle: "Country", cellType: CellType.selection, pickerValues: AppData.countries()),
        ReviewKeys.Region : RatingCell(cellTitle: "Region", cellType: CellType.selection, pickerValues: []),
        ReviewKeys.Name : RatingCell(cellTitle: "Title", cellType: CellType.text),
        ReviewKeys.ImagePicker : RatingCell(cellTitle: "ImagePicker", cellType: CellType.imagePicker, pickerValues: []),
        ReviewKeys.Image : RatingCell(cellTitle: "Image", cellType: CellType.image, pickerValues: [])
    ]
    
    // Determine the order of each cell in the table view by retrieving the parameters within an explicit 2D array
    lazy var cellList : [[RatingCell]] = [
        // General
        [self.cellDictionary[ReviewKeys.Name]!, self.cellDictionary[ReviewKeys.Varietal]!, self.cellDictionary[ReviewKeys.Country]!, self.cellDictionary[ReviewKeys.Region]!, self.cellDictionary[ReviewKeys.Rating]!,
            self.cellDictionary[ReviewKeys.ImagePicker]!, self.cellDictionary[ReviewKeys.Image]!
        ],
        // Eyes
        //        [self.cellDictionary["Color"]!,
        [self.cellDictionary[ReviewKeys.Opacity]!, self.cellDictionary[ReviewKeys.Rim]!, self.cellDictionary[ReviewKeys.Spritz]!],
        
        // Nose
        [self.cellDictionary[ReviewKeys.NoseAroma]!, self.cellDictionary[ReviewKeys.Openness]!],
        
        // Mouth
        [self.cellDictionary[ReviewKeys.MouthAroma]!, self.cellDictionary[ReviewKeys.Body]!, self.cellDictionary[ReviewKeys.Acidity]!, self.cellDictionary[ReviewKeys.Alcohol]!, self.cellDictionary[ReviewKeys.Tannins]!, self.cellDictionary[ReviewKeys.ResidualSugar]!]
    ]
}

