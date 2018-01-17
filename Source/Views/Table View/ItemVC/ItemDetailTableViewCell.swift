//
//  ItemVCCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/28/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ItemDetailTableViewCell: UITableViewCell {
    
    var itemImage = UIImageView(frame: .zero)
    var itemName = UILabel(frame: .zero)
    var itemPrice = UILabel(frame: .zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        masksToBounds = true
        
        itemImage.contentMode = .scaleAspectFit
        addSubview(itemImage)
        
        itemName.font = Font.gotham(size: 17.0)
        itemName.numberOfLines = 0
        itemName.textColor = UIColor.black
        addSubview(itemName)
        
        itemPrice.font = Font.gotham(size: 14.0)
        itemPrice.textColor = UIColor(named: .mediumGrey)
        addSubview(itemPrice)
    }
    
    private func buildConstraints() {
        itemImage.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(150)
        }
        
        itemName.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.bottom).offset(16)
            make.left.equalTo(24)
            make.right.equalTo(16)
            make.height.greaterThanOrEqualTo(17)
        }
        
        itemPrice.snp.makeConstraints { make in
            make.top.equalTo(itemName).offset(8)
            make.left.equalTo(24)
            make.right.equalTo(16)
            make.bottom.equalTo(8)
        }
    }
    
    func set(item: Item, indexPath: IndexPath) {
        itemImage.heroID = "item_img_\(item.id)_\(indexPath.section)_\(indexPath.row)"
        
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture"))
        if let url = item.img {
            itemImage.pin_updateWithProgress = true
            itemImage.pin_setImage(from: url)
        }
        
        itemName.text = item.name
        itemPrice.text = item.price.currencyFormat
    }
}