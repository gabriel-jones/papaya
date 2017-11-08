//
//  Colors.swift
//  PrePacked
//
//  Created by Gabriel Jones on 28/12/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

class Color {
    static let green = #colorLiteral(red: 0.1607843137, green: 0.8235294118, blue: 0.4235294118, alpha: 1)
    static let blue = #colorLiteral(red: 0.3215686275, green: 0.568627451, blue: 0.768627451, alpha: 1)
    static let yellow = #colorLiteral(red: 1, green: 0.8509803922, blue: 0.3490196078, alpha: 1)
    static let red = #colorLiteral(red: 0.9764705882, green: 0.3568627451, blue: 0.2705882353, alpha: 1)
    static let grey = (#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),#colorLiteral(red: 0.4823529422, green: 0.5450980663, blue: 0.5607843399, alpha: 1),#colorLiteral(red: 0.4078431427, green: 0.470588237, blue: 0.4862745106, alpha: 1),#colorLiteral(red: 0.270588249, green: 0.3137255013, blue: 0.3254902065, alpha: 1))
    static let turquoise = #colorLiteral(red: 0.3450980392, green: 0.8862745098, blue: 0.7137254902, alpha: 1)
    

}

class Font {
    enum GothamWeight: String {
        case medium = "Medium", bold = "Bold"
    }
    
    static func gotham(weight: GothamWeight = .medium, size: CGFloat) -> UIFont {
        return UIFont(name: "GothamRounded-\(weight.rawValue)", size: size)!
    }
}

func UIColorFromRGB(_ hex: UInt32) -> UIColor {
    return UIColor(
        red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(hex & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
