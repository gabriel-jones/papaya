//
//  CartItem.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/12/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

struct CartItem {
    var quantity: Int
    var item: Item
    var instructions: String?
    var replaceOption: ReplaceOption = .replaceAuto
    
    enum ReplaceOption {
        case replaceAuto, replaceSpecific(item: Item?), skip
        
        var description: (String, UIColor) {
            get {
                switch self {
                case .replaceAuto:
                    return ("Find Best Match", Color.green)
                case .replaceSpecific(let item):
                    return ("Replace with \(item!.name)", Color.green)
                case .skip:
                    return ("Don't Replace", Color.red)
                }
            }
        }
        
        var image: (UIImage, UIColor) {
            get {
                switch self {
                case .replaceAuto:
                    return (#imageLiteral(resourceName: "Replace").withRenderingMode(.alwaysTemplate), Color.green)
                case .replaceSpecific(_):
                    return (#imageLiteral(resourceName: "Replace").withRenderingMode(.alwaysTemplate), Color.green)
                case .skip:
                    return (#imageLiteral(resourceName: "Skip").withRenderingMode(.alwaysTemplate), Color.red)
                }
            }
        }
    }
    
    init(item: Item, quantity: Int) {
        self.quantity = quantity
        self.item = item
    }
}
