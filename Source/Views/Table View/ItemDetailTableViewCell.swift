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
    
    public let itemImage = UIImageView()
    private let itemName = UILabel()
    private let itemSize = UILabel()
    private let itemPrice = UILabel()
    private let itemPriceUnit = UILabel()
    
    var didLoadImage = false
    
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
        
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        itemImage.tintColor = .gray
        self.setImageTemplate(to: true)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        itemImage.isUserInteractionEnabled = true
        itemImage.addGestureRecognizer(imageTap)
        addSubview(itemImage)
        
        itemName.font = Font.gotham(size: 18.0)
        itemName.numberOfLines = 0
        itemName.textColor = UIColor.black
        addSubview(itemName)
        
        itemSize.font = Font.gotham(size: 16.0)
        itemSize.textColor = UIColor(named: .mediumGrey)
        addSubview(itemSize)
        
        itemPrice.font = Font.gotham(size: 18.0)
        itemPrice.textColor = UIColor.black
        addSubview(itemPrice)
        
        itemPriceUnit.font = Font.gotham(size: 15.0)
        itemPriceUnit.textColor = UIColor(named: .mediumGrey)
        addSubview(itemPriceUnit)
    }
    
    @objc private func tap(_ sender: Any) {
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
        }
        
        itemSize.snp.makeConstraints { make in
            make.top.equalTo(itemName.snp.bottom).offset(4)
            make.left.equalTo(24)
            make.right.equalTo(-16)
            make.height.equalTo(18)
        }
        
        itemPrice.snp.makeConstraints { make in
            make.top.equalTo(itemSize.snp.bottom).offset(8)
            make.left.equalTo(24)
            make.right.equalTo(-16)
            make.height.equalTo(18)
            make.bottom.equalTo(-16)
        }
        
        itemPriceUnit.snp.makeConstraints { make in
            make.right.equalTo(-24)
            make.bottom.equalTo(itemPrice.snp.bottom)
        }
    }
    
    public func set(item: Item, id: String) {
        if let url = item.img {
            itemImage.pin_updateWithProgress = true
            itemImage.pin_setImage(from: url)
            itemImage.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "Picture").tintable) { result in
                self.didLoadImage = result.error == nil
                self.setImageTemplate(to: result.error != nil)
            }
            itemImage.heroID = id
        }
        
        itemName.text = item.name
        itemSize.text = item.size
        itemPrice.text = item.price.currencyFormat + " / \(item.unitPrice ?? "each")"
        if let netWeight = Double(item.size?.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted) ?? ""), let unit = item.size?.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.")) {
            itemPriceUnit.text = (item.price / netWeight).currencyFormat + " / \(unit)"
        }
    }

    private func setImageTemplate(to: Bool) {
        itemImage.contentMode = to ? .center : .scaleAspectFit
        itemImage.backgroundColor = to ? UIColor(named: .backgroundGrey) : .clear
        itemImage.layer.cornerRadius = to ? 5 : 0
    }
}
