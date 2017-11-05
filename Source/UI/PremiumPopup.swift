//
//  PremiumPopup.swift
//  PrePacked
//
//  Created by Gabriel Jones on 07/09/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

class PremiumPopup: UIView {

    @IBOutlet weak var upgrade: LargeButton!
    @IBOutlet weak var close: LargeButton!
    @IBOutlet weak var dontShowAgain: Checkbox!
    
    override func awakeFromNib() {
        dontShowAgain.boxColor = UIColor.gray
        dontShowAgain.tint = Color.green
    }
    
}
