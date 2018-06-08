//
//  Extensions.swift
//  PrePacked
//
//  Created by Gabriel Jones on 19/12/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

func UIColorFromRGB(_ hex: UInt32) -> UIColor {
    return UIColor(
        red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(hex & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIColor {
    enum Name: String {
        case green = "Green"
        case yellow = "Yellow"
        case red = "Red"
        case darkGrey = "Dark Grey"
        case mediumGrey = "Medium Grey"
        case blue = "Blue"
        case turquoise = "Turquoise"
        case flatShadow = "Flat Shadow"
        case backgroundGrey = "Background Grey"
    }
    
    convenience init(named: Name) {
        self.init(named: named.rawValue)!
    }
}

extension UIView {
    
    enum GradientPosition {
        case bottomLeft, topRight, left, right, topLeft, bottomRight, top, bottom
        
        var cgPoint: CGPoint {
            get {
                let x = self == .bottomLeft || self == .left || self == .topLeft ? 0 : (self == .top || self == .bottom ? 0.5 : 1)
                let y = self == .topLeft || self == .top || self == .topRight ? 0 : (self == .left || self == .right ? 0.5 : 1)
                return CGPoint(x: x, y: y)
            }
        }
    }
    
    func gradientBackground(colors: [UIColor] = [UIColorFromRGB(0x00d44d)/*UIColor(named: .green)*/, UIColor(named: .turquoise)], position: (GradientPosition, GradientPosition) = (.bottomLeft, .topRight)) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = position.0.cgPoint
        gradient.endPoint = position.1.cgPoint
        print(gradient)
        layer.insertSublayer(gradient, at: 0)
    }
    
    func getImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    public class func fromNib(_ nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil, type: self)
    }
    
    public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil, type: T.self)
        return v!
    }
    
    public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = nibName
        }
        let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        for v in nibViews! {
            if let tog = v as? T {
                view = tog
            }
        }
        return view
    }
    
    public class var nibName: String {
        let name = "\(self)".components(separatedBy: ".").first ?? ""
        return name
    }
    
    public class var nib: UINib? {
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
    
    func bulge() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, animations: {
                self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.2, options: [], animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            })
        })
    }
}

extension Int {
    var comma_format: String {
        get {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            return f.string(from: NSNumber(value: self))!
        }
    }
    
    func padZeroes() -> String {
        return String(format: "%02d", self)
    }
}

extension Double {
    var currencyFormat: String {
        get {
            let f = NumberFormatter()
            f.numberStyle = .currency
            return f.string(from: NSNumber(value: self))!
        }
    }
}

@IBDesignable extension UIView {
    @IBInspectable var flatShadow: Bool {
        get {
            return self.layer.shadowOpacity == 1.0
        } set {
            self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.layer.shadowRadius = 0.0
            self.layer.masksToBounds = false
            self.layer.shadowOpacity = newValue ? 1.0 : 0.0
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get {
            return self.layer.masksToBounds
        } set {
            self.layer.masksToBounds = newValue
        }
    }
}

extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return CGFloat(Double.pi/180.0)*self
    }
    
    func radiansToDegrees() -> CGFloat {
        return self * CGFloat(180.0/Double.pi)
    }
}

extension Data {
    func arrayOfBytes() -> [UInt8] {
        return self.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: self.count))
        }
    }
}

extension UIImage {
    func imageWithInsets(_ insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
}

extension Bool {
    static func binaryValue(_ i: Int) -> Bool? {
        if i == 0 { return false }
        else if i == 1 { return true }
        else { return nil }
    }
}

extension NSMutableData {
    func appendString(_ str: String) {
        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: true)
        self.append(data!)
    }
}

extension String {
    init(data: Data) {
        self = String(data: data, encoding: String.Encoding.utf8)!
    }
    
    init(data: Data?) {
        if let d = data {
            self = String(data: d)
        } else {
            self = ""
        }
    }
    
    /**
     Encode a String to Base64
     
     - returns: Base64 String
     */
    func toBase64()->String{
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
    }
    
    var bytes: Array<UInt8> {
        get {
            return Array<UInt8>(self.utf8)
        }
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, count) ..< count)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    mutating func insert(_ string: String, index: Int) {
        self = String(self.characters.prefix(index)) + string + String(self.characters.suffix(self.characters.count-index))
    }
}

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

extension Date {
    var default_format: String {
        get {
            let f = DateFormatter()
            f.dateFormat = "MMMM d"
            var x = f.string(from: self) + self.daySuffix()
            f.dateFormat = ", y 'at' h:mm a"
            x += f.string(from: self)
            return x
        }
    }
    
    func daySuffix() -> String {
        let dayOfMonth = Calendar.current.component(.day, from: self)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
