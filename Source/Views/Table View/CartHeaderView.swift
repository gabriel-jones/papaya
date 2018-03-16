//
//  CartDetailTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class CartHeaderView: UIView {
    
    private let shopName = UILabel()
    private let deliveryTime = UILabel()
    private let total = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        var i = 0
//        for subview in self.contentView.superview!.subviews {
//            if NSStringFromClass(type(of: subview)) == "_UITableViewCellSeparatorView" {
//                if i == 1 {
//                    subview.removeFromSuperview()
//                    return
//                }
//                i += 1
//            }
//        }
//    }
    
    private func buildViews() {
        backgroundColor = .clear
        
        shopName.font = Font.gotham(size: 16)
        addSubview(shopName)
        
        deliveryTime.font = Font.gotham(size: 14)
        deliveryTime.textColor = UIColor(named: .mediumGrey)
        addSubview(deliveryTime)
        
        total.font = Font.gotham(size: 17)
        addSubview(total)
    }
    
    private func buildConstraints() {
        shopName.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview().offset(-12)
        }
        
        deliveryTime.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview().offset(12)
        }
        
        total.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }
    
    public func load(cart: Cart) {
        shopName.text = "Miles Market"
        deliveryTime.text = "Can deliver in the next hour"
        total.text = cart.total.currencyFormat
    }

}
