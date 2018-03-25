//
//  CheckoutCartTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/22/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class CheckoutCartTableViewCell: UITableViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.checkoutCartCell.rawValue
    
    private let cartImage = UIImageView()
    private let cartLabel = UILabel()
    private let cartItemCountLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        selectionStyle = .none

        cartImage.image = #imageLiteral(resourceName: "Cart").tintable
        cartImage.tintColor = .gray
        addSubview(cartImage)
        
        cartLabel.text = "Cart"
        cartLabel.font = Font.gotham(size: 15)
        addSubview(cartLabel)
        
        cartItemCountLabel.text = "11 items"
        cartItemCountLabel.textColor = .gray
        cartItemCountLabel.font = Font.gotham(size: 13)
        addSubview(cartItemCountLabel)
    }
    
    private func buildConstraints() {
        cartImage.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(12)
            make.height.width.equalTo(25)
        }
        
        cartLabel.snp.makeConstraints { make in
            make.left.equalTo(cartImage.snp.right).offset(15)
            make.centerY.equalTo(cartImage.snp.centerY)
        }
        
        cartItemCountLabel.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.centerY.equalTo(cartLabel.snp.centerY)
        }
    }
    
    public func load(cart: Cart) {
        cartItemCountLabel.text = "\(cart.items.count) items"
    }

}
