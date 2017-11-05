//
//  LargeButton.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class LargeButton: UIButton {
    
    @IBInspectable var holdRepeatFire = false
    
    @IBInspectable
    var isCircle: Bool = true {
        didSet {
            self.layer.cornerRadius = isCircle ? self.frame.width/2 : 0
        }
    }
    
    var action: () -> () = {}
    
    @IBInspectable var originalOpacity: Float = 1.0 {
        didSet {
            self.layer.opacity = originalOpacity
        }
    }
    
    @IBInspectable var tapOpacity: Float = 0.5
    
    @objc func down() {
        self.layer.opacity = tapOpacity
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if self.isTouchInside && self.holdRepeatFire {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (t: Timer) in
                    if self.isTouchInside {
                        self.action()
                    } else {
                        t.invalidate()
                    }
                }
            }
        }
    }
    
    @objc func up() {
        self.action()
        self.layer.opacity = originalOpacity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.down()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.up()
    }
    
}


