//
//  Tag.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/3/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Tag: BaseObject {
    let id: Int
    let name: String
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string
        else {
            return nil
        }
        
        id = _id
        name = _name
    }
}
