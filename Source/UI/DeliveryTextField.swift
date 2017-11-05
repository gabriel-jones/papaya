//
//  DeliveryTextField.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class DeliveryAddressTextField: UITextField {
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setNeedsDisplay()
    }
    
    //MARK: - Methods
    
    override func draw(_ rect: CGRect) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
