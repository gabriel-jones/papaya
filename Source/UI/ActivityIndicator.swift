//
//  ActivityIndicator.swift
//  PrePacked
//
//  Created by Gabriel Jones on 13/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

class ActivityIndicator: UIView {
    
    enum Color: String {
        case Green = "Activity Arrows Green"
        case Grey = "Activity Arrows Grey"
        case White = "Activity Arrows White"
    }
    
    var colorType: Color = .Grey
    
    private var isDrawn = false

    func draw() {
        if isDrawn { return }
        self.layer.zPosition = 1000
        let _img = UIImage(named: self.colorType.rawValue)!
        let img = UIImageView(image: _img)
        img.sizeToFit()
        img.frame.size = self.frame.size
        img.frame = self.frame
        img.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.addSubview(img)
        isDrawn = true
    }
    
    func startAnimating() {
        let a = CABasicAnimation(keyPath: "transform.rotation.z")
        let speed = 0.3
        a.toValue = .pi * 2.0 * speed
        a.duration = speed
        a.isCumulative = true
        a.repeatCount = .infinity
        self.layer.add(a, forKey: "transform.rotation.z")
    }
    
    func stopAnimating() {
        self.layer.removeAllAnimations()
    }

}
