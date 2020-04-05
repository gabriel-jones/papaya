//
//  List.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

final class List: BaseObject {
    let id: Int
    var name: String
    let itemCount: Int
    let items: [Item]?
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _itemCount = dict["item_count"].int
        else {
            return nil
        }
            
        id = _id
        name = _name
        itemCount = _itemCount
        if let _itemsDict = dict["items"].array {
            var _items = [Item]()
            for itemDict in _itemsDict {
                if let item = Item(dict: itemDict) {
                    _items.append(item)
                } else {
                    return nil
                }
            }
            items = _items
        } else {
            items = nil
        }
    }
}
