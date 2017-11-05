//
//  Location.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import CoreLocation

typealias Location = CLLocationCoordinate2D

extension Location {
    init(lat: Double, long: Double) {
        self.longitude = long
        self.latitude = lat
    }

}
