//
//  CartItemTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/17/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

extension UIButton {
    public func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: insetAmount, left: -(insetAmount / 3), bottom: insetAmount, right: insetAmount / 3)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: (insetAmount / 3), bottom: 0, right: -(insetAmount / 3))
        contentEdgeInsets = UIEdgeInsets(top: insetAmount, left: spacing, bottom: insetAmount, right: spacing)
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
    public let stepper = Stepper()
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
        isHeroEnabled = true
        
        itemImage.pin_setPlaceholder(with: #imageLiteral(resourceName: "Picture").tintable)
        itemImage.tintColor = .gray
        self.setImageTemplate(to: true)
        addSubview(itemImage)
        
        itemName.font = Font.gotham(size: 15)
        itemName.numberOfLines = 0
        addSubview(itemName)
        
        itemPrice.font = Font.gotham(size: 13)
        itemPrice.textColor = UIColor(named: .mediumGrey)
        addSubview(itemPrice)
        
        stepper.minimum = 1
        stepper.maximum = 100
        stepper.shouldDelete = true
        stepper.delegate = self
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
        self.stepper.showLoading()
        Request.shared.deleteCartItem(item: self.item!.item) { result in
            self.stepper.hideLoading()
            if case .success(_) = result {
                self.delegate?.delete(selectedItem: self.item!)
            }
        }
    }
    
    @objc private func addInstructions(_ sender: UIButton) {
        if let item = self.item {
            delegate?.addInstructions(selectedItem: item)
        }
    }
    
    private func buildConstraints() {
        itemImage.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview()
            make.top.equalTo(self.snp.topMargin)
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
        if let url = cartItem.item.img {
            itemImage.pin_updateWithProgress = true
            itemImage.pin_setImage(from: url)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func getImageId() -> String {
        return withUnsafePointer(to: &itemImage) {
            "item_img_" + $0.debugDescription
        }
    }
}

extension CartItemTableViewCell: StepperDelegate {
    func changedQuantity(to: Int) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if to == self.stepper.value {
                self.stepper.showLoading()
                Request.shared.updateCartQuantity(item: self.item!.item, quantity: to) { result in
                    self.stepper.hideLoading()
                    if case .success(_) = result {
                        self.delegate?.changeQuantity(new: to, selectedItem: self.item!)
                    }
                }
            }
        }
    }
    
    func delete() {
        self.stepper.showLoading()
        Request.shared.deleteCartItem(item: self.item!.item) { result in
            self.stepper.hideLoading()
            if case .success(_) = result {
                self.delegate?.delete(selectedItem: self.item!)
            }
        }
    }
}
