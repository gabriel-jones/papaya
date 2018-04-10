//
//  List.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct List: BaseObject {
    let id: Int
    let name: String
    let items: [Item]
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _itemsDict = dict["items"].array
        else {
            return nil
        }
            
        id = _id
        name = _name
        var _items = [Item]()
        for itemDict in _itemsDict {
            if let item = Item(dict: itemDict) {
                _items.append(item)
            } else {
                return nil
            }
        }
        items = _items
    }
}
