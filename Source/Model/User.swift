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
    
    static var current: User?
    
    let id: Int
    var email: String
    var fname: String
    var lname: String
    var phone: String?
    
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
