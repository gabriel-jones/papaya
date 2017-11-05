//
//  PriceBreakdown.swift
//  PrePacked
//
//  Created by Gabriel Jones on 03/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class PriceBreakdown: StatusCell {
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var packingLabel: UILabel!
    @IBOutlet weak var expressLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
