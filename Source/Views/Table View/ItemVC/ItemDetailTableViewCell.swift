//
//  ItemVCCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/28/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ItemDetailTableViewCell: UITableViewCell {
    
    static let identifier: String = C.ViewModel.CellIdentifier.itemDetailCell.rawValue
    
    public var delegate: ItemImageDelegate?
    
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
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        itemImage.isUserInteractionEnabled = true
        itemImage.addGestureRecognizer(imageTap)
        addSubview(itemImage)
        
        itemName.font = Font.gotham(size: 18.0)
        itemName.numberOfLines = 0
        itemName.textColor = UIColor.black
        addSubview(itemName)
        
        itemPrice.font = Font.gotham(size: 16.0)
        itemPrice.textColor = UIColor(named: .mediumGrey)
        addSubview(itemPrice)
    }
    
    @objc private func tap(_ sender: Any) {
        print("tap")
        delegate?.openImage(sender)
    }
    
    private func buildConstraints() {
        itemImage.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(150)
        }
        
        itemName.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.bottom).offset(24)
            make.left.equalTo(24)
            make.right.equalTo(-16)
            make.height.greaterThanOrEqualTo(20)
        }
        
        itemPrice.snp.makeConstraints { make in
            make.top.equalTo(itemName.snp.bottom).offset(4)
            make.left.equalTo(24)
            make.right.equalTo(-16)
            make.height.equalTo(18)
            make.bottom.equalTo(-16)
        }
    }
    
    func set(item: Item, id: String) {
        itemImage.heroID = id
        
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture"))
        if let url = item.img {
            itemImage.pin_updateWithProgress = true
            itemImage.pin_setImage(from: url)
        }
        
        itemName.text = item.name
        itemPrice.text = item.price.currencyFormat
    }
}
