//
//  Item.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017  Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Item: BaseObject {
    public let id: Int
    public let name: String
    public let img: URL?
    public let category: Category?
    public let size: String?
    public let isLiked: Bool?
    
    public let price: Double
    public let unitPrice: String?
    
    public var packLabel: String?
    private var _pack: Any?
    public var pack: Item? {
        get {
            return _pack as? Item
        }
        set {
            _pack = newValue
        }
    }
    
    init() {
        self.id = 0
        self.name = ""
        self.price = 0
        self.img = nil
        self.category = nil
        self.size = nil
        self.unitPrice = nil
        self.isLiked = false
        self._pack = nil
        self.packLabel = nil
    }
    
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
        category = Category(dict: dict["category"])
        size = dict["size"].string
        unitPrice = dict["unit_str"].string
        isLiked = dict["is_liked"].bool
        
        packLabel = dict["pack_item"]["label"].string
        if dict["pack_item"].dictionary != nil {
            _pack = Item(dict: dict["pack_item"])
        } else {
            _pack = nil
        }
    }
}
