//
//  MainStatus1.swift
//  PrePacked
//
//  Created by Gabriel Jones on 13/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class MainStatus: UITableViewCell {
    
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var statusMessage: UILabel!
    @IBOutlet weak var statusImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
