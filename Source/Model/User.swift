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
    
    public static var current: User?
    
    public let id: Int
    public var email: String
    public var fname: String
    public var lname: String
    public var phone: String
    public var isValidated: Bool
    public var isExpress: Bool
    
    public var name: String {
        get {
            return [fname, lname].joined(separator: " ")
        }
    }
    
    public init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _email = dict["email"].string,
            let _fname = dict["fname"].string,
            let _lname = dict["lname"].string,
            let _phone = dict["phone"].string,
            let _isValidated = dict["is_validated"].bool,
            let _isExpress = dict["is_express"].bool
        else {
            return nil
        }
        
        id = _id
        email = _email
        fname = _fname
        lname = _lname
        phone = _phone
        isValidated = _isValidated
        isExpress = _isExpress
    }
}
