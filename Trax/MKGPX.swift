//
//  MKGPX.swift
//  Trax
//
//  Created by Chen Cen on 12/17/16.
//  Copyright © 2016 Chen Cen. All rights reserved.
//

import MapKit

// turn the Waypoint into MKAnnotation by using an extension
extension GPX.Waypoint : MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return info
    }
    
    var thumbnailURL: NSURL? {
        return getImageURLofType(type: "thumbnail")
    }
    
    var imageURL: NSURL? {
        return getImageURLofType(type: "large")
    }
    
    private func getImageURLofType(type: String?) -> NSURL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }
}
