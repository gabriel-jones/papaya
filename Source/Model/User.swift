//
//  User.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User: BaseObject {
    
    let id: Int
    let email: String
    let fname: String
    let lname: String
    let phone: String?
    
    var name: String {
        get {
            return [fname, lname].joined(separator: " ")
        }
    }
    
    init?(dict: JSON) {
        id = dict["id"].intValue
        email = dict["email"].stringValue
        fname = dict["fname"].stringValue
        lname = dict["lname"].stringValue
        phone = dict["phone"].string
    }
}
