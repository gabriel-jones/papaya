//
//  LoginTextField.swift
//  PrePacked
//
//  Created by Gabriel Jones on 16/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    
    var img: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var error = false {
        didSet {
            acc.image = error ? #imageLiteral(resourceName: "Warning Triangle Yellow").imageWithInsets(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)) : nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 2
        self.frame.size = CGSize(width: self.frame.width, height: 40)
        self.backgroundColor = UIColor.clear
        self.textColor = UIColor.white
        
        if img != nil {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.height+10, height: self.frame.height))
            let v1 = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
            v1.backgroundColor = UIColorFromRGB(0x1a1c19)
            v1.alpha = 0.3
            v.addSubview(v1)
            let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            img.center = CGPoint(x: v1.center.x, y: v1.center.y)
            img.image = self.img
            img.contentMode = UIViewContentMode.scaleAspectFit
            v.addSubview(img)
            self.leftView = v
            self.leftViewMode = UITextFieldViewMode.always
            self.addSubview(v)
        } else {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
            
            self.leftView = v
            self.leftViewMode = UITextFieldViewMode.always
            self.addSubview(v)
        }
        
        self.tintColor = UIColorFromRGB(0xFFFFFF)
        
        let bgColor = UIView(frame: CGRect(x: self.frame.height, y: 0, width: self.frame.width - (self.frame.height), height: self.frame.height))
        if img == nil {
            bgColor.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
        bgColor.alpha = 0.08
        bgColor.isUserInteractionEnabled = false
        bgColor.backgroundColor = UIColorFromRGB(0x1a1c19)
        self.addSubview(bgColor)
        
        acc = UIImageView(frame: CGRect(x: self.frame.width-self.frame.height, y: 0, width: self.frame.height, height: self.frame.height))
        self.addSubview(acc)
    }
    
    var acc: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
