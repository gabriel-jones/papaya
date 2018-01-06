//
//  GroceryList.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct Cart: BaseObject {
    static var current: Cart!
    
    let id: Int
    var items: Variable<[CartItem]> = Variable([])
    
    init?(dict: JSON) {
        guard let items = dict["items"].array, let id = dict["id"].int else {
            return nil
        }
        
        self.id = id
        for item in items {
            if let item = CartItem(dict: item) {
                self.items.value.append(item)
            }
        }
    }

    var total: Double {
        get {
            var t = 0.0
            for cartItem in items.value {
                t += cartItem.item.price * Double(cartItem.quantity)
            }
            return t
        }
    }
}

