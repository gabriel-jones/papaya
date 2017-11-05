//
//  Switch.swift
//  PrePacked
//
//  Created by Gabriel Jones on 02/10/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

protocol SwitchDelegate {
    func switchView(valueChanged value: SwitchAlt.SwitchState)
}

class SwitchAlt: UIView {
    enum ColorType: UInt32 {
        case Green = 0x2ACC59
        case White = 0xFFFFFF
        case Grey = 0xFAFAFA
        case Yellow = 0xFFD248
    }
    
    enum SwitchState: String {
        case On = "ON"
        case Off = "OFF"
    }
    
    var delegate: SwitchDelegate!
    
    var color: ColorType! = .Green
    var offTint: UIColor! = .clear
    var toggleColor: UIColor! = UIColorFromRGB(0xFAFAFA)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.draw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.draw()
    }
    
    //Circle
    var toggleSwitch: UIView!
    
    func draw() {
        isUserInteractionEnabled = true
        let h = self.frame.height
        self.backgroundColor = offTint
        self.layer.cornerRadius = h/2
        
        toggleSwitch = UIView(frame: CGRect(x: h/10, y: h/10, width: h-(h/5), height: h-(h/5)))
        toggleSwitch.layer.cornerRadius = toggleSwitch.frame.height/2
        toggleSwitch.backgroundColor = toggleColor
        
        self.addSubview(toggleSwitch)
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        gesture.direction = .left
        self.addGestureRecognizer(gesture)
        let gesture2 = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        gesture2.direction = .right
        self.addGestureRecognizer(gesture2)
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(toggle))
        self.addGestureRecognizer(gesture3)
    }
    
    func swipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left && self.state == .On {
            self.toggle()
        } else if gesture.direction == .right && self.state == .Off {
            self.toggle()
        } else {
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if self.point(inside: t.location(in: self), with: event) {
                self.toggle()
            }
        }
    }
    
    private var state: SwitchState! = .Off
    
    func getState() -> SwitchState {
        return self.state
    }
    
    func changeTo(_ state: SwitchState, animted: Bool = true) {
        self.layer.removeAllAnimations()
        let h = self.frame.height
        let xPos = state == .On ? self.frame.width - (h/10) - (h-(h/5)) : h/10
        self.state = state
        let color = state == .On ? UIColorFromRGB(self.color.rawValue) : self.offTint
        if animted {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
                self.toggleSwitch.backgroundColor = state == .On ? self.toggleColor : UIColorFromRGB(self.color.rawValue)
                self.toggleSwitch.frame.origin.x = xPos
                self.backgroundColor = color
            }, completion: { _ in
                if self.delegate != nil {
                    self.delegate.switchView(valueChanged: self.state)
                }
            })
        } else {
            self.toggleSwitch.backgroundColor = state == .On ? self.toggleColor : UIColorFromRGB(self.color.rawValue)
            self.toggleSwitch.frame.origin.x = xPos
            self.backgroundColor = state == .On ? color : self.offTint

            if self.delegate != nil {
                self.delegate.switchView(valueChanged: self.state)
            }
        }
    }
    
    func toggle() {
        if self.state == .On {
            self.changeTo(.Off)
        } else {
            self.changeTo(.On)
        }
    }
    
}
