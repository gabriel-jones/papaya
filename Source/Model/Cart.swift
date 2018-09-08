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
    public let id: Int
    public var items: [CartItem]
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _itemsArray = dict["items"].array
        else {
            return nil
        }
        
        self.id = _id
        
        var itemsBuffer = [CartItem]()
        for item in _itemsArray {
            if let item = CartItem(dict: item) {
                itemsBuffer.append(item)
            } else {
                return nil
            }
        }
        self.items = itemsBuffer
    }

    public var total: Double {
        get {
            var t = 0.0
            for cartItem in items {
                t += cartItem.item.price * Double(cartItem.quantity)
            }
            return t
        }
    }
}

