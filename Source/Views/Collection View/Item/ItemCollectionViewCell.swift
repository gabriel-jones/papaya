//
//  ItemCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import PINRemoteImage
import Hero

class ItemCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "itemCell"
    
    var itemImage = UIImageView(frame: .zero)
    var itemPrice = UILabel(frame: .zero)
    var itemName = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        backgroundColor = .white
        cornerRadius = 10
        flatShadow = true
        flatShadowColor = UIColor(named: .flatShadow)
        clipsToBounds = true
        
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").withRenderingMode(.alwaysTemplate))
        itemImage.contentMode = .scaleAspectFit
        itemImage.tintColor = UIColor(named: .mediumGrey)
        addSubview(itemImage)
        
        itemPrice.font = Font.gotham(size: 16)
        addSubview(itemPrice)
        
        itemName.font = Font.gotham(size: 13)
        itemName.numberOfLines = 0
        itemName.textColor = UIColor(named: .darkGrey)
        addSubview(itemName)
    }
    
    private func buildConstraints() {
        itemImage.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(8)
            make.right.equalTo(8)
            make.height.equalToSuperview().multipliedBy(0.5).offset(-16)
        }
        
        itemPrice.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.bottom).offset(8)
            make.left.equalTo(16)
            make.right.equalTo(-8)
        }
        
        itemName.snp.makeConstraints { make in
            make.top.equalTo(itemPrice.snp.bottom).offset(8)
            make.left.equalTo(16)
            make.right.equalTo(-8)
        }
    }
    
    func load(item: Item, indexPath: IndexPath) {
        itemPrice.text = item.price.currencyFormat
        itemName.text = item.name
        if let url = item.img {
            itemImage.pin_updateWithProgress = true
            itemImage.pin_setImage(from: url)
            
            itemImage.heroID = "item_img_\(item.id)_\(indexPath.section)_\(indexPath.row)"
        }
    }
    
    override func prepareForReuse() {
        itemImage.image = #imageLiteral(resourceName: "Picture").withRenderingMode(.alwaysTemplate)
        super.prepareForReuse()
    }
}
