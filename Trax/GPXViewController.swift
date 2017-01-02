//
//  GPXViewController.swift
//  Trax
//
//  Created by Chen Cen on 12/17/16.
//  Copyright © 2016 Chen Cen. All rights reserved.
//

import UIKit
import MapKit


class GPXViewController: UIViewController, MKMapViewDelegate {
    var gpxURL: NSURL? {
        didSet {
            if let url = gpxURL {
                GPX.parse(url:url) { gpx in
                    if gpx != nil {
                        self.addWayPoints((gpx?.waypoints)!)
                    }
                    
                }
            }
        }
    }
    
    private func clearWayPoints() {
        mapView?.removeAnnotations(mapView.annotations)
    }
    
    private func addWayPoints(_ waypoints: [GPX.Waypoint]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpxURL = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx")
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .satellite
            mapView.delegate = self
        }
    }
    
    // override the annotation views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view:MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseId);
        // create view mapped with an id
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseId)
            view.canShowCallout = true
        } else {
            // binds annotation to the current view
            view.annotation = annotation
        }
        
        // make it draggable if it's editable - editable is created by long press
        view.isDraggable = annotation is EditableWaypoint
        
        view.leftCalloutAccessoryView = nil
        
        view.rightCalloutAccessoryView = nil
        
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                // don't pull image until user clicks it, handle the click in the following delegate
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            if waypoint is EditableWaypoint {
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }
        
        return view
    }
    
    // only pull the image from network after user clicks the pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let thumbnailImageBtn = view.leftCalloutAccessoryView as? UIButton,
            let url = (view.annotation as? GPX.Waypoint)?.thumbnailURL,
            let imageData = NSData(contentsOf: url as URL), // blocks main queue
            let image = UIImage(data: imageData as Data) {
            thumbnailImageBtn.setImage(image, for: .normal)
        }
    }
    
    // when the left image is clicked, start a segue to show the full screen image
    // called when user tapped on annotation view's accessory buttons
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
        } else if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: Constants.EditUserWayPoint, sender: view)
        }
    }
    
    // default impl fhr prepare for seque does nothing, we need to set required data by destination controller (ImageViewController in this case)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contentViewCotroller
        let annotationView = sender as? MKAnnotationView
        let waypoint = annotationView?.annotation as? GPX.Waypoint
        
        if segue.identifier == Constants.ShowImageSegue {
            if let ivc = destination as? ImageViewController {
                ivc.imageUrl = waypoint?.imageURL
                ivc.title = waypoint?.name
            }
        } else if segue.identifier == Constants.EditUserWayPoint {
            // when we want to edit, pass the current waypoint to EditableWaypointViewController
            if let editableWaypoit = waypoint as? EditableWaypoint,
                let ewvc = destination as? EditWaypointViewController {
                if let ppc = ewvc.popoverPresentationController {
                    ppc.sourceRect = annotationView!.frame
                }
                ewvc.waypointToEdit = editableWaypoit
            }
        }
    }
    
    // hook up long press to add a temporary waypoint
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // convert what user has clicked on the mapView to an actual coordinate
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            // create a new waypoint and add to the mapView
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
    }
    // constants
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseId = "wayPoint"
        static let ShowImageSegue = "showImage"
        static let EditUserWayPoint = "editWaypoint"
    }
    
    // Unwind
    // *) must have the annotation and th method signature
    // *) called when a segue returns to current viewController
    // *) ctrl drag a button to viewController's exit to pull all availalbe unwind function
    //  *) all unwind methods that're available would become selectable because you don't know which viewController it's returnining back to
    @IBAction func updateUserWaypoint(segue: UIStoryboardSegue) {
        selectWaypoint((segue.source.contentViewCotroller as? EditWaypointViewController)?.waypointToEdit)
    }
    
    private func selectWaypoint(_ waypoint: GPX.Waypoint?) {
        if waypoint != nil {
            mapView.selectAnnotation(waypoint!, animated: true)
        }
    }
}

extension UIViewController {
    // if it's navication controoler, reteurn visibleviewController
    var contentViewCotroller: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
