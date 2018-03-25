//
//  Checkout.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Checkout: BaseObject {
    let id: Int
    let cart: Cart?
    var address: Address?
    var orderDate: Date
    var isDelivery: Bool
    
    init?(dict: JSON) {
        id = dict["id"].intValue
        cart = Cart(dict: dict["cart"])
        address = Address(dict: dict["address"])
        isDelivery = dict["is_delivery"].boolValue
        orderDate = Date() // TODO:
    }
}
