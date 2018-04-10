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
    var orderDate: Date?
    var isDelivery: Bool
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _isDelivery = dict["is_delivery"].bool
        else {
            return nil
        }
        id = _id
        cart = Cart(dict: dict["cart"])
        address = Address(dict: dict["address"])
        isDelivery = _isDelivery
        
        if let _orderDateString = dict["order_time"].string, let _orderDate = dateTimeFormatter.date(from: _orderDateString) {
            orderDate = _orderDate
        }
    }
}
