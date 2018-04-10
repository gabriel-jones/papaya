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
    public let id: Int
    public var street: String
    public var zip: String
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _street = dict["street"].string,
            let _zip = dict["zip_code"].string
        else {
            return nil
        }
        
        id = _id
        street = _street
        zip = _zip
    }
}
