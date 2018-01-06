//
//  ListItemGridCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ListItemGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func load(item: Item) {
        imageView.pin_setImage(from: item.img)
    }

}
