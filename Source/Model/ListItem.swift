//
//  ListItem.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ListItem: BaseObject {
    let id: Int
    let item: Item
    let quantity: Int
    
    var rawdict: [String:Any] {
        get {
            return [
                "item_id": item.id,
                "quantity": quantity
            ]
        }
    }
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _quantity = dict["quantity"].int,
            let _item = Item(dict: dict)
        else {
            return nil
        }
        id = _id
        quantity = _quantity
        item = _item
    }
}
