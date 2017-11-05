//
//  User.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: PPObj {
    static var current: User! = nil
    
    var packer_shop_id: Int? = nil
    
    func logout() -> Bool {
        User.current = nil
        GroceryList.current = GroceryList(items: [], shop_id: 0, created: Date())
        Order.current.id = -1
        
        R.get("/scripts/User/logout.php", parameters: ["user_id": self.id])
        
        if self.isPacker {
            R.get("/scripts/Packer/set_status.php", parameters: ["online": false])
        }
        
        do {
            try keychain.remove("user_email")
            try keychain.remove("user_password")
        } catch {
            print("Error: could not remove keychain values. Exiting application...")
            exit(-666)
        }
        return true
    }
    
    func saveLiked<T:  UIViewController>(_ vc: T, liked: Bool, item: Item) {
        let name = liked ? "add_liked.php" : "delete_liked.php"
        R.get("/scripts/User/" + name, parameters: ["item_id": item.id, "user_id": self.id]) { json, error in
            if error {
                //do some error or something
                return
            }
            print(json ?? "null")
        }
    }
    
    var email: String
    var verified: Bool
    var card: String
    var name: (String, String)
    var isPacker: Bool
    var packerType: PackerType?
    
    var defaultLocation: Location!
    var defaultAddress: String!
    
    enum PackerType: String {
        case packer, driver
    }
    
    init(dict: JSON) {
        print("Init user with: \(dict)")
        self.email = dict["email"].stringValue
        self.verified = Bool.binaryValue(dict["verified"].intValue)!
        self.card = dict["card"].stringValue.substring(from: 4)
        self.name = (dict["first_name"].stringValue, dict["last_name"].stringValue)
        self.isPacker = Bool.binaryValue(dict["packer"].intValue)!
        self.packer_shop_id = dict["shop_id"].intValue
        if let pt = dict["packer_type"].string, pt != "null" {
            self.packerType = PackerType(rawValue: pt)
        }
        self.defaultLocation = Location(lat: dict["latitude"].doubleValue, long: dict["longitude"].doubleValue)
        self.defaultAddress = dict["address"].stringValue
        super.init(id: dict["id"].intValue)
    }
}
