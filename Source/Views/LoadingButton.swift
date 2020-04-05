//
//  LoadingButton.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/3/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class LoadingButton: UIButton {
    
    struct ButtonState {
        var state: UIControlState
        var title: String?
        var image: UIImage?
    }
    
    private (set) var buttonStates: [ButtonState] = []
    
    private lazy var activityIndicator: LoadingView = {
        let activityIndicator = LoadingView()
        activityIndicator.lineWidth = 2.5
        activityIndicator.color = self.titleColor(for: .normal) ?? .black
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 25)
        let heightConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 25)
        self.addConstraints([xCenterConstraint, yCenterConstraint, widthConstraint, heightConstraint])
        return activityIndicator
    }()
    
    func showLoading() {
        activityIndicator.startAnimating()
        var buttonStates: [ButtonState] = []
        for state in [UIControlState.disabled] {
            let buttonState = ButtonState(state: state, title: title(for: state), image: image(for: state))
            buttonStates.append(buttonState)
            setTitle("", for: state)
            setImage(UIImage(), for: state)
        }
        self.buttonStates = buttonStates
        isEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        for buttonState in buttonStates {
            setTitle(buttonState.title, for: buttonState.state)
            setImage(buttonState.image, for: buttonState.state)
        }
        isEnabled = true
    }
}
