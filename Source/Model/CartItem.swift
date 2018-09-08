//
//  CartItem.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/12/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CartItem: BaseObject {
    public let id: Int
    public var quantity: Int
    public let item: Item
    public var instructions: String?
    public var replaceOption: ReplaceOption
    
    enum ReplaceOption {
        case replaceAuto, replaceSpecific(item: Item?), skip
        
        var rawValue: String {
            get {
                switch self {
                case .replaceAuto:
                    return "replace_best"
                case .replaceSpecific:
                    return "replace_specific"
                case .skip:
                    return "skip"
                }
            }
        }
        
        var description: (String, UIColor) {
            get {
                switch self {
                case .replaceAuto:
                    return ("Find Best Match", UIColor(named: .green))
                case .replaceSpecific(let item):
                    return ("Replace with \(item?.name ?? "unknown")", UIColor(named: .green))
                case .skip:
                    return ("Don't Replace", UIColor(named: .red))
                }
            }
        }
        
        var image: (UIImage, UIColor) {
            get {
                switch self {
                case .replaceAuto:
                    return (#imageLiteral(resourceName: "Replace").tintable, UIColor(named: .green))
                case .replaceSpecific(_):
                    return (#imageLiteral(resourceName: "Replace").tintable, UIColor(named: .green))
                case .skip:
                    return (#imageLiteral(resourceName: "Skip").tintable, UIColor(named: .red))
                }
            }
        }
    }
    
    var rawdict: [String:Any] {
        get {
            var specificItem: Item?
            if case .replaceSpecific(let item) = replaceOption {
                specificItem = item
            }
            
            return [
                "id": id,
                "item_id": item.id,
                "quantity": quantity,
                "notes": instructions,
                "replace_option": replaceOption.rawValue,
                "replace_specific": specificItem?.id
            ]
        }
    }
    
    init?(dict: JSON) {
        guard
            let _id = dict["cart_item_id"].int,
            let _quantity = dict["quantity"].int,
            let _replaceOptionString = dict["replace_option"].string,
            let _item = Item(dict: dict)
        else {
            return nil
        }
        id = _id
        quantity = _quantity
        item = _item
        instructions = dict["notes"].string
        switch _replaceOptionString {
        case "replace_specific":
            if let replaceSpecificItem = Item(dict: dict["replace_specific"]) {
                replaceOption = .replaceSpecific(item: replaceSpecificItem)
            } else {
                replaceOption = .replaceAuto
            }
        case "skip":
            replaceOption = .skip
        default:
            replaceOption = .replaceAuto
        }
    }
}
