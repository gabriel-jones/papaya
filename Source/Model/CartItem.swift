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
    let id: Int
    var quantity: Int
    let item: Item
    var instructions: String?
    var replaceOption: ReplaceOption
    
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
                "item_id": id,
                "quantity": quantity,
                "notes": instructions as Any,
                "replace_option": replaceOption.rawValue,
                "replace_specific": specificItem as Any
            ]
        }
    }
    
    init?(dict: JSON) {
        id = dict["id"].intValue
        quantity = dict["quantity"].intValue
        item = Item(dict: dict)!
        instructions = dict["notes"].string
        switch dict["replace_option"] {
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
