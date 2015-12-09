//
//  MapViewController.swift
//  WineNotes
//
//  Created by Katie Willison on 12/8/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            mapView.mapType = .Standard
            mapView.delegate = self
        }
    }
    
    private var reviews : [WineReview]? {
        didSet {
            if reviews != nil {
                clearReviews()
                addReviews(reviews!)
            }
        }
    }
    
    var contextObserver : AnyObject?
    var databaseObserver : AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contextObserver = NSNotificationCenter.defaultCenter().addObserverForName("ManagedObjectContextSet",
            object: nil,
            queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
                weakSelf?.reviews = WineReview.getReviews(inManagedObjectContext: AppData.managedObjectContext!)
                NSNotificationCenter.defaultCenter().removeObserver(weakSelf!.contextObserver!)
                weakSelf?.contextObserver = nil
        }
        AppData.setManagedObjectContext()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let context = AppData.managedObjectContext {
            reviews = WineReview.getReviews(inManagedObjectContext: context)
        }
        
        databaseObserver = NSNotificationCenter.defaultCenter().addObserverForName("ReviewAddedToDatabase", object: nil, queue: NSOperationQueue.mainQueue())
            { [weak weakSelf = self] notification in
                weakSelf?.reviews = WineReview.getReviews(inManagedObjectContext: AppData.managedObjectContext!)
            }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if databaseObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(databaseObserver!)
        }
        databaseObserver = nil
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MKPinAnnotationView")
        view.canShowCallout = true
        
        if let review = annotation as? MappedWineReview {
            if let image = review.image {
                let imageView = UIImageView(frame: CGRectMake(0, 0, 59, 59))
                imageView.image = image
                view.leftCalloutAccessoryView = imageView
            }
        }
        
        return view
    }
    
    private func clearReviews() {
        mapView?.removeAnnotations(mapView.annotations)
    }
    
    private func addReviews(reviews: [WineReview]) {
        var reviewsAsAnnotations : [MKAnnotation] = []
        for review in reviews {
            if let parsedCoordinate = review.getCoordinate(){
                let annotation = MappedWineReview(coordinate: parsedCoordinate, title: review.name, subtitle: review.varietal)
                annotation.image = review.getImage()
                reviewsAsAnnotations.append(annotation)
            }
        }
        mapView?.addAnnotations(reviewsAsAnnotations)
        mapView?.showAnnotations(reviewsAsAnnotations, animated: true)
    }
}

class MappedWineReview : NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image : UIImage?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle : String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
