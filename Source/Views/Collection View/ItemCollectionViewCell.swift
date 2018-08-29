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

class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSAttributedStringKey.font: font],
                                                                    context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}

class ItemCollectionViewCell: UICollectionViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.itemCell.rawValue
    
    private var itemImage = UIImageView()
    private let itemPrice = UILabel()
    private let itemName = TopAlignedLabel()
    private var priceTemplate: UIView!
    private var name1Template: UIView!
    private var name2Template: UIView!
    private var name3Template: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildTemplate() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.alpha = 0.6
        view.isHidden = true
        return view
    }
    
    private func buildViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        masksToBounds = false
        
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        
        self.setImageTemplate(to: true)
        itemImage.image = nil
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        itemImage.tintColor = .gray
        addSubview(itemImage)
        
        itemPrice.font = Font.gotham(size: 16)
        addSubview(itemPrice)
        
        itemName.font = Font.gotham(size: 13)
        itemName.numberOfLines = 0
        itemName.textColor = UIColor(named: .darkGrey)
        itemName.lineBreakMode = .byTruncatingTail
        addSubview(itemName)
        
        priceTemplate = buildTemplate()
        itemPrice.addSubview(priceTemplate)
        
        name1Template = buildTemplate()
        itemName.addSubview(name1Template)
        
        name2Template = buildTemplate()
        itemName.addSubview(name2Template)
        
        name3Template = buildTemplate()
        itemName.addSubview(name3Template)
    }
    
    private func buildConstraints() {
        itemImage.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalToSuperview().dividedBy(2).offset(-16)
        }
        
        itemPrice.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.bottom).offset(8)
            make.left.equalTo(16)
            make.right.equalTo(-8)
        }
        
        itemName.snp.makeConstraints { make in
            make.top.equalTo(itemPrice.snp.bottom).offset(4)
            make.left.equalTo(16)
            make.right.equalTo(-8)
            make.bottom.equalTo(-8)
        }
        
        priceTemplate.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(CGFloat(2.0/5.0))
        }
        
        name1Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(4)
            make.height.equalTo(priceTemplate.snp.height).multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(CGFloat(8.0/10.0))
        }
        
        name2Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(name1Template.snp.bottom).offset(4)
            make.height.equalTo(priceTemplate.snp.height).multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(CGFloat(6.0/10.0))
        }
        
        name3Template.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalTo(name2Template.snp.bottom).offset(4)
            make.height.equalTo(priceTemplate.snp.height).multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(CGFloat(8.0/10.0))
        }
    }
    
    public func load(item: Item) {
        priceTemplate.layer.removeAllAnimations()
        priceTemplate.isHidden = true
        name1Template.isHidden = true
        name2Template.isHidden = true
        name3Template.isHidden = true

        itemPrice.text = item.price.currencyFormat
        itemName.text = item.name
        
        self.itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        self.setImageTemplate(to: true)

        if let url = item.img {
            itemImage.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "Picture").tintable) { result in
                self.setImageTemplate(to: result.error != nil)
            }
            
            itemImage.heroID = self.getImageId()
        }
    }
    
    private func setImageTemplate(to: Bool) {
        itemImage.contentMode = to ? .center : .scaleAspectFit
        itemImage.backgroundColor = to ? UIColor(named: .backgroundGrey) : .clear
        itemImage.layer.cornerRadius = to ? 5 : 0
    }
    
    public func loadTemplate() {
        itemImage.image = nil
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        self.setImageTemplate(to: true)
        itemPrice.text = " "
        priceTemplate.isHidden = false
        itemName.text = " "
        name1Template.isHidden = false
        name2Template.isHidden = false
        name3Template.isHidden = false
        DispatchQueue.main.async {
            self.layoutSubviews()
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.priceTemplate.alpha = 0.3
                self.name1Template.alpha = 0.3
                self.name2Template.alpha = 0.3
                self.name3Template.alpha = 0.3
            }, completion: nil)
        }
    }
    
    override func layoutSubviews() {
        priceTemplate.layer.cornerRadius = priceTemplate.frame.height / 2
        name1Template.layer.cornerRadius = name1Template.frame.height / 2
        name2Template.layer.cornerRadius = name2Template.frame.height / 2
        name3Template.layer.cornerRadius = name3Template.frame.height / 2
    }
    
    public func getImageId() -> String {
        return withUnsafePointer(to: &itemImage) {
            "item_img_" + $0.debugDescription
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
