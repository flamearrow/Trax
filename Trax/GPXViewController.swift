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
        
        view.leftCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                // don't pull image until user clicks it, handle the click in the following delegate
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
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
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseId = "wayPoint"
        static let ShowImageSegue = "showImage"
        static let EditUserWayPoint = "Edit waypoint"
    }
}
