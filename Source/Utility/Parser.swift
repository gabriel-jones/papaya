//
//  Parse.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ObjectBuilder<T> {
    var validator: JSONValidator<T>
    
    init?() {
        if let validator = Validator.for(type: T.self) {
            self.validator = validator
        } else {
            return nil
        }
    }
    
    func validate(json: JSON) -> Bool {
        return validator.isValid(json: json)
    }
    
    func parse(json: JSON) -> T? {
        switch T.self {
        case is User.Type:
            return UserParser().parseJSON(json: json) as? T
        case is Address.Type:
            return AddressParser().parseJSON(json: json) as? T
        default: return nil
        }
    }
}

struct JSONValidator<T> {
    typealias ValidationClosure = (JSON) -> Bool
    let validator: ValidationClosure
    
    init(validator: @escaping ValidationClosure) {
        self.validator = validator
    }
    
    func isValid(json: JSON) -> Bool {
        return validator(json)
    }
}

struct Validator {
    static func `for`<T>(type: T.Type) -> JSONValidator<T>? {
        switch type {
        case is User.Type:
            return user as? JSONValidator<T>
        case is Address.Type:
            return address as? JSONValidator<T>
        default: return nil
        }
    }
    
    static var user = JSONValidator<User> { (json: JSON) -> (Bool) in
        if let _ = json["email"].string, let _ = json["fname"].string, let _ = json["lname"].string {
            return true
        }
        return false
    }
    
    static var address = JSONValidator<Address> { (json: JSON) -> (Bool) in
        if let _ = json["street"].string, let _ = json["zip"].string {
            return true
        }
        return false
    }
}

protocol JSONParser {
    associatedtype T
    func parseJSON(json: JSON) -> T
}

struct UserParser: JSONParser {
    func parseJSON(json: JSON) -> User {
        return User(email: json["email"].stringValue, fname: json["fname"].stringValue, lname: json["lname"].stringValue, phone: json["phone"].string)
    }
}

struct AddressParser: JSONParser {
    func parseJSON(json: JSON) -> Address {
        return Address(street: json["street"].stringValue, zip: json["zip_code"].stringValue)
    }
}
