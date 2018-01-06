//
//  Colors.swift
//  PrePacked
//
//  Created by Gabriel Jones on 28/12/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

class Font {
    enum GothamWeight: String {
        case medium = "Medium", bold = "Bold"
    }
    
    static func name(weight: GothamWeight) -> String {
        return "GothamRounded-\(weight.rawValue)"
    }
    
    static func gotham(weight: GothamWeight = .medium, size: CGFloat) -> UIFont {
        return UIFont(name: name(weight: weight), size: size)!
    }
}
