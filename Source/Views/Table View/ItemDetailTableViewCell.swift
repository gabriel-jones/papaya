//
//  ItemVCCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/28/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
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
    
    private let packView = UIView()
    private let packImage = UIImageView()
    private let packName = UILabel()
    private let packLabel = UILabel()
    private let packArrow = UIImageView()
    
    public var didLoadImage = false
    private var packItem: Item?
    
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
        
        //packView.backgroundColor = UIColorFromRGB(0xF0F0F0)
        //packView.layer.cornerRadius = 5
        let packTap = UITapGestureRecognizer(target: self, action: #selector(tapPack(_:)))
        packView.isUserInteractionEnabled = true
        packView.addGestureRecognizer(packTap)
        packView.layer.borderColor = UIColorFromRGB(0xDDDDDD).cgColor
        packView.layer.borderWidth = 1
        packView.layer.cornerRadius = 5
        addSubview(packView)
        
        packImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        packImage.tintColor = .gray
        packImage.contentMode = .center
        packImage.backgroundColor = UIColor(named: .backgroundGrey)
        packImage.layer.cornerRadius = 5
        packView.addSubview(packImage)
        
        packLabel.font = Font.gotham(weight: .bold, size: 14)
        packLabel.textColor = .gray
        packView.addSubview(packLabel)
    
        packName.font = Font.gotham(size: 16)
        packName.textColor = .black
        packName.numberOfLines = 0
        packView.addSubview(packName)
        
        packArrow.image = #imageLiteral(resourceName: "Right Arrow").tintable
        packArrow.tintColor = UIColorFromRGB(0xCCCCCC)
        packView.addSubview(packArrow)
    }
    
    @objc private func tap(_ sender: Any) {
        delegate?.openImage(sender)
    }
    
    @objc private func tapPack(_ sender: Any) {
        guard let packItem = self.packItem else {
            return
        }
        delegate?.openItem(item: packItem)
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
        }
        
        itemPriceUnit.snp.makeConstraints { make in
            make.right.equalTo(-24)
            make.bottom.equalTo(itemPrice.snp.bottom)
        }
        
        packView.snp.makeConstraints { make in
            make.top.equalTo(itemPrice.snp.bottom).offset(16)
            make.left.equalToSuperview().inset(24)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        packImage.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8).priority(800)
            make.width.height.equalTo(60)
        }
        
        packLabel.snp.makeConstraints { make in
            make.left.equalTo(packImage.snp.right).offset(16)
            make.top.equalToSuperview().inset(8)
        }
        
        packName.snp.makeConstraints { make in
            make.left.equalTo(packImage.snp.right).offset(16)
            make.top.equalTo(packLabel.snp.bottom).offset(4)
            make.right.bottom.equalToSuperview().inset(16)
        }
        
        packArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
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
        
        if let url = item.pack?.img {
            packImage.pin_updateWithProgress = true
            packImage.pin_setImage(from: url)
            packImage.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "Picture").tintable) { result in
                self.packImage.contentMode = .scaleAspectFit
                self.packImage.backgroundColor = .clear
                self.packImage.layer.cornerRadius = 0
            }
        }
        
        packLabel.text = item.packLabel
        packName.text = item.pack?.name
        packItem = item.pack
        
        itemName.text = item.name
        itemSize.text = item.size
        itemPrice.text = item.price.currencyFormat + " / \(item.unitPrice ?? "each")"
        if let netWeight = Double(item.size?.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted) ?? ""), let unit = item.size?.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.")) {
            itemPriceUnit.text = (item.price / netWeight).currencyFormat + " / \(unit.trimmingCharacters(in: .whitespacesAndNewlines))"
        }
        
        if item.pack == nil {
            packView.snp.remakeConstraints { make in
                make.top.equalTo(itemPrice.snp.bottom).offset(16)
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            }
        } else {
            packView.snp.remakeConstraints { make in
                make.top.equalTo(itemPrice.snp.bottom).offset(16)
                make.left.equalToSuperview().inset(24)
                make.right.equalToSuperview().inset(16)
                make.bottom.equalToSuperview().inset(16)
            }
        }
        packView.isHidden = item.pack == nil

    }

    private func setImageTemplate(to: Bool) {
        itemImage.contentMode = to ? .center : .scaleAspectFit
        itemImage.backgroundColor = to ? UIColor(named: .backgroundGrey) : .clear
        itemImage.layer.cornerRadius = to ? 5 : 0
    }
}
