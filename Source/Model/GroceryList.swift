//
//  GroceryList.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

class GroceryList {
    static var current = GroceryList(items: [], shop_id: 0, created: Date())
    
    var created: Date
    var items: Array<(Item,Int)>
    var total: Double {
        get {
            var t = 0.0
            for i in GroceryList.current.items {
                t += i.0.price * Double(i.1)
            }
            return t
        }
    }
    var shop_id: Int
    
    class Delivery {
        var isEnabled = true
        var location: Location?
        var address: String?
        var isExpress = false
    }; var delivery = Delivery()
    
    var shop: Shop {
        get {
            return Shop.from(id: self.shop_id)!
        }
    }
    
    func itemsJSON() -> JSON? {
        var _items = [[String:Any]]()
        for item in self.items {
            var arr: [String: Any] = [:]
            arr["item"] = item.0.id
            arr["quantity"] = item.1
            _items.append(arr)
        }
        return JSON(_items)
    }
    
    init(j: JSON) {
        self.items = j["items"].arrayValue.map({
            (Item(dict: $0), $0["quantity"].intValue)
        })
        self.shop_id = j["shop_id"].intValue
        
        if let k = j["time_init"].string {
            let t = DateFormatter()
            t.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.created = t.date(from: k)!
        } else {
            self.created = Date()
        }
    }
    
    init(items: Array<(Item,Int)>, shop_id: Int, created: Date) {
        self.items = items
        self.shop_id = shop_id
        self.created = created
    }
    
    func json() -> JSON? {
        let t = DateFormatter()
        t.dateFormat = ""
        return [
            "created": t.string(from: self.created),
            "items": self.itemsJSON()!.stringValue,
            "shop_id": self.shop_id
        ]
    }
}
