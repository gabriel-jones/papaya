//
//  AlertHelper.swift
//  PrePacked
//
//  Created by Gabriel Jones on 15/08/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
/*
struct AlertButton {
    var title: String
    var backgroundColor: UIColor
    var textColor: UIColor
    var action: () -> ()
    
    init(_ title: String, backgroundColor: UIColor = Color.grey.0, textColor: UIColor = .white, action: @escaping (() -> ()) = {}) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.action = action
    }
}

func alert(actions: [AlertButton] = [], alertFont: UIFont = Font.gotham(size: 12)) -> SCLAlertView {
    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    let a = SCLAlertView(appearance: appearance)
    for action in actions {
        a.addButton(action.title, backgroundColor: action.backgroundColor, textColor: action.textColor, action: action.action)
    }
    return a
}*/

protocol ActiveLargeButtonDelegate: class {
    func didToggleActive(to active: Bool, sender: ActiveLargeButton)
}

class ActiveLargeButton: LargeButton {
    
    //MARK: - Properties
    var isActive = false
    var isActiveEnabled = true
    weak var delegate: ActiveLargeButtonDelegate?
    
    //MARK: - Methods
    func toggleActive(to active: Bool? = nil, callDelegate: Bool = true, animated: Bool = true) {
        if !isActiveEnabled { return }
        
        var t = isActive
        if active != nil {
            t = !active!
        }
        
        if callDelegate {
            self.delegate?.didToggleActive(to: !t, sender: self)
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.backgroundColor = t ? UIColor.clear : Color.green
            for v in self.subviews {
                if v is UILabel {
                    (v as! UILabel).textColor = t ? Color.green : UIColor.white
                }
            }
        }) { _ in
            self.isActive = !t
        }
    }
    
    override func up() {
        super.up()
        self.toggleActive()
    }
}
