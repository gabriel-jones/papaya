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
    static var current: Cart!
    
    let id: Int
    var items = [CartItem]()
    
    init?(dict: JSON) {
        guard let items = dict["items"].array, let id = dict["id"].int else {
            return nil
        }
        
        self.id = id
        for item in items {
            if let item = CartItem(dict: item) {
                self.items.append(item)
            }
        }
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
    
    mutating func remove(item: CartItem) {
        items.remove(at: items.index(where: { $0.item.id == item.item.id })!)
    }
    
    mutating func changeQuantity(for item: CartItem, new: Int) {
        items[items.index(where: {$0.item.id == item.item.id})!].quantity = new
    }
    
    mutating func add(item: Item, quantity: Int) {
        if items.contains(where: { $0.item.id == item.id }) {
            items[items.index(where: {$0.item.id == item.id })!].quantity += quantity
        } else {
            //items.append(CartItem(item: item, quantity: quantity))
        }
    }
}

