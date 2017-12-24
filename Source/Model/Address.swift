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
    var street: String
    var zip: String
    
    init?(dict: JSON) {
        street = dict["street"].stringValue
        zip = dict["zip_code"].stringValue
    }
}
