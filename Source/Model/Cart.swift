//
//  GroceryList.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

class Cart {
    static var current = Cart(items: [])
    
    var items: [CartItem]

    var total: Double {
        get {
            var t = 0.0
            for cartItem in items {
                t += cartItem.item.price * Double(cartItem.quantity)
            }
            return t
        }
    }
    
    init(items: [CartItem]) {
        self.items = items
    }
    
    func remove(item: CartItem) {
        items.remove(at: items.index(where: { $0.item.id == item.item.id })!)
    }
    
    func changeQuantity(for item: CartItem, new: Int) {
        items[items.index(where: {$0.item.id == item.item.id})!].quantity = new
    }
    
    func add(item: Item, quantity: Int) {
        if items.contains(where: { $0.item.id == item.id }) {
            items[items.index(where: {$0.item.id == item.id })!].quantity += quantity
        } else {
            items.append(CartItem(item: item, quantity: quantity))
        }
    }
}
