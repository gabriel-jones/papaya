//
//  GroceryList.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Cart: BaseObject {    
    let id: Int
    var items: [CartItem]
    
    init?(dict: JSON) {
        guard let id = dict["id"].int else {
            return nil
        }
        
        self.id = id
        
        var itemsBuffer = [CartItem]()
        if let items = dict["items"].array {
            for item in items {
                if let item = CartItem(dict: item) {
                    itemsBuffer.append(item)
                }
            }
        }
        self.items = itemsBuffer
    }

    var total: Double {
        get {
            var t = 0.0
            for cartItem in items {
                t += cartItem.item.price * Double(cartItem.quantity)
            }
            return t
        }
    }
}

