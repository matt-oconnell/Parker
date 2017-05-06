//
//  Place.swift
//  Parker
//
//  Created by Matt O'Connell on 5/6/17.
//  Copyright © 2017 Matt O'Connell. All rights reserved.
//

import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, latitude: Double, longitude: Double) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
