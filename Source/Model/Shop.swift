//
//  Shop.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Shop: BaseObject {
    let id: Int
    let name: String
    let address: String
    
    init?(dict: JSON) {
        id = dict["id"].intValue
        name = dict["name"].stringValue
        address = dict["address"].stringValue
    }
}
