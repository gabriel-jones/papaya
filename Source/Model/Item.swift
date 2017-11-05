//
//  Item.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

class Item: PPObj {
    var name: String
    var shop_id: Int
    var price: Double
    var stock: Int
    var category: String
    var isLiked: Bool
    var hasImage: Bool?
    
    var shop: Shop {
        get {
            print(Shop.all)
            print(self.shop_id)
            return Shop.from(id: self.shop_id)!
        }
    }
    
    init(dict: JSON) {
        self.name = dict["name"].stringValue
        self.shop_id = dict["shop_id"].intValue
        self.price = dict["price"].doubleValue
        self.stock = dict["stock"].intValue
        self.category = dict["category"].stringValue
        self.isLiked = dict["isLiked"].boolValue
        if let i = dict["hasImage"].string {
            self.hasImage = Int(i)! == 1
        }
        super.init(id:dict["id"].intValue)
    }
    
    func toJSON() -> JSON {
        return JSON([
            "name": self.name,
            "shop_id": self.shop_id,
            "price": self.price,
            "stock": self.stock,
            "category": self.category,
            "id": self.id,
            "isLiked": self.isLiked,
            "hasImage": self.hasImage ?? false
        ])
    }
}
