//
//  Shop.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

class Shop: PPObj {
    static var all: [Shop] = []
    static func from(id: Int) -> Shop? {
        for shop in all {
            if shop.id == id {
                return shop
            }
        }
        return nil
    }
    
    var location: Location
    var name: String
    var address: String
    var categories: Array<String>
    
    init(dict: JSON) {
        self.name = dict["name"].stringValue
        self.location = Location(lat: dict["latitude"].doubleValue, long: dict["longitude"].doubleValue)
        self.categories = []
        for c in dict["categories"].stringValue.components(separatedBy: ";") {
            self.categories.append(c)
        }
        self.address = dict["address"].stringValue
        super.init(id: dict["id"].intValue)
    }
}
