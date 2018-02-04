//
//  CartItemTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/17/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

extension UIButton {
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: insetAmount, left: insetAmount+spacing, bottom: insetAmount, right: insetAmount+spacing)
    }
}

protocol CartItemTableViewCellDelegate {
    func delete(selectedItem: CartItem)
    func addInstructions(selectedItem: CartItem)
    func changeQuantity(new: Int, selectedItem: CartItem)
}

class CartItemTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.cartItemCell.rawValue
    
    public var delegate: CartItemTableViewCellDelegate?
    
    private var item: CartItem?
    private var itemImage = UIImageView()
    private let itemName = UILabel()
    private let itemPrice = UILabel()
    private let stepper = Stepper()
    private let removeButton = UIButton()
    private let instructionButton = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        addSubview(itemImage)
        
        itemName.font = Font.gotham(size: 15)
        itemName.numberOfLines = 0
        addSubview(itemName)
        
        itemPrice.font = Font.gotham(size: 13)
        itemPrice.textColor = UIColor(named: .mediumGrey)
        addSubview(itemPrice)
        
        stepper.minimum = 1
        stepper.maximum = 100
        stepper.value = 1
        addSubview(stepper)
        
        removeButton.setImage(#imageLiteral(resourceName: "Delete").tintable, for: .normal)
        removeButton.tintColor = UIColor(named: .red)
        removeButton.titleLabel?.font = Font.gotham(size: 13)
        removeButton.setTitle("Delete", for: .normal)
        removeButton.setTitleColor(UIColor(named: .red), for: .normal)
        removeButton.centerTextAndImage(spacing: 8)
        removeButton.imageView?.contentMode = .scaleAspectFit
        removeButton.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
        addSubview(removeButton)
        
        instructionButton.setImage(#imageLiteral(resourceName: "Note").tintable, for: .normal)
        instructionButton.tintColor = UIColor(named: .green)
        instructionButton.titleLabel?.font = Font.gotham(size: 13)
        instructionButton.setTitle("Instructions", for: .normal)
        instructionButton.setTitleColor(UIColor(named: .green), for: .normal)
        instructionButton.centerTextAndImage(spacing: 8)
        instructionButton.imageView?.contentMode = .scaleAspectFit
        instructionButton.addTarget(self, action: #selector(addInstructions(_:)), for: .touchUpInside)
        addSubview(instructionButton)
    }
    
    @objc private func remove(_ sender: UIButton) {
        if let item = self.item {
            delegate?.delete(selectedItem: item)
        }
    }
    
    @objc private func addInstructions(_ sender: UIButton) {
        if let item = self.item {
            print("add instructions")
            delegate?.addInstructions(selectedItem: item)
        }
    }
    
    private func buildConstraints() {
        itemImage.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview()
            make.topMargin.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        itemName.snp.makeConstraints { make in
            make.top.equalTo(self.snp.topMargin)
            make.left.equalTo(itemImage.snp.right).offset(8)
            make.right.equalTo(stepper.snp.left).offset(-8)
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }
        
        itemPrice.snp.makeConstraints { make in
            make.leading.equalTo(itemName.snp.leading)
            make.top.equalTo(itemName.snp.bottom).offset(4)
        }
        
        stepper.snp.makeConstraints { make in
            make.centerY.equalTo(itemImage.snp.centerY)
            make.trailingMargin.equalToSuperview().offset(-8)
            make.height.equalTo(40)
            make.width.equalTo(150)
        }
        
        removeButton.snp.makeConstraints { make in
            make.trailing.equalTo(stepper.snp.trailing)
            make.bottom.equalTo(-4)
        }
        
        instructionButton.snp.makeConstraints { make in
            make.right.equalTo(removeButton.snp.left)
            make.bottom.equalTo(-4)
        }
    }
    
    public func load(cartItem: CartItem) {
        item = cartItem
        itemName.text = cartItem.item.name
        itemPrice.text = cartItem.item.price.currencyFormat
        stepper.value = cartItem.quantity
        itemImage.contentMode = .center
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        itemImage.pin_setImage(from: cartItem.item.img, completion: { result in
            if result.error == nil {
                self.itemImage.contentMode = .scaleAspectFit
            }
        })
    }
    
    public func getImageId() -> String {
        return withUnsafePointer(to: &itemImage) {
            "item_img_" + $0.debugDescription
        }
    }

}
