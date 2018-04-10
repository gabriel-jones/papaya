//
//  Item.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Item: BaseObject {
    let id: Int
    let name: String
    let img: URL?
    let price: Double
    let category: Category?
    let size: String?
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _price = dict["price"].double
        else {
            return nil
        }
        
        id = _id
        name = _name
        price = _price
        if let img_url = dict["img_url"].string {
            img = URL(string: img_url)
        } else {
            img = nil
        }
        category = Category(dict: dict)
        size = dict["size"].string
    }
}
