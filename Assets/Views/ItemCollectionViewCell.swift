//
//  ItemCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import PINRemoteImage

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        cornerRadius = 10
        itemImage.image = #imageLiteral(resourceName: "Picture Grey")
        flatShadow = true
        flatShadowColor = Color.flatShadow
    }
    
    func load(item: Item) {
        itemPrice.text = item.price.currency_format
        itemName.text = item.name
        if item.hasImage ?? false {
            loadImage(url: URL(string: C.URL.main + "/img/items/\(item.id).png")!)
        }
    }
    
    private func loadImage(url: URL) {
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture Grey"))
        itemImage.pin_updateWithProgress = true
        itemImage.pin_setImage(from: url)
    }
    
    override func prepareForReuse() {
        itemImage.image = #imageLiteral(resourceName: "Picture Grey")
        super.prepareForReuse()
    }
}
