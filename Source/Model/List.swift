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
        id = dict["id"].intValue
        name = dict["name"].stringValue
        var _items = [Item]()
        for itemDict in dict["items"].arrayValue {
            if let item = Item(dict: itemDict) {
                _items.append(item)
            }
        }
        items = _items
    }
}
