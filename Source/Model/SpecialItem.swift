//
//  SpecialItem.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/3/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SpecialItem: BaseObject {
    let id: Int
    let name: String
    let description: String
    let countryOfOrigin: Country?
    let img: URL?
    let price: Double
    let category: Category?
    let tags: [Tag]
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _description = dict["description"].string,
            let _price = dict["price"].double,
            let _tags = dict["tags"].array
        else {
            return nil
        }
        
        var _createdTags = [Tag]()
        for _tag in _tags {
            if let tag = Tag(dict: _tag) {
                _createdTags.append(tag)
            } else {
                return nil
            }
        }
        
        if let img_url = dict["img_url"].string {
            img = URL(string: img_url)
        } else {
            img = nil
        }
        
        id = _id
        name = _name
        description = _description
        price = _price
        category = Category(dict: dict)
        countryOfOrigin = Country(dict: dict)
        tags = _createdTags
    }
}
