//
//  Address.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Address: BaseObject {
    let id: Int
    let street: String
    let zip: String
    
    init?(dict: JSON) {
        id = dict["id"].intValue
        street = dict["street"].stringValue
        zip = dict["zip_code"].stringValue
    }
}
