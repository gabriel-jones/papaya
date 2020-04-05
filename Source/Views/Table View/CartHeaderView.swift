//
//  CartDetailTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class CartHeaderView: UIView {
    
    private let shopName = UILabel()
    private let openTag = UIView()
    private let openTagLabel = UILabel()
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

    private func buildViews() {
        backgroundColor = .clear
        
        shopName.font = Font.gotham(size: 16)
        addSubview(shopName)
        
        addSubview(openTag)
        
        openTagLabel.textColor = .white
        openTagLabel.font = Font.gotham(size: 12)
        openTagLabel.textAlignment = .center
        openTag.addSubview(openTagLabel)
        
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
        
        openTag.snp.makeConstraints { make in
            make.centerY.equalTo(shopName.snp.centerY)
            make.left.equalTo(shopName.snp.right).offset(8)
        }
        
        openTagLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        openTag.layer.cornerRadius = openTag.frame.height / 2
    }
    
    private func setTag(isOpen: Bool) {
        openTagLabel.text = isOpen ? "Open" : "Closed"
        openTag.backgroundColor = isOpen ? UIColor(named: .green) : UIColor(named: .red)
    }
    
    public func load(cart: Cart, schedule: ScheduleDay) {
        shopName.text = "Miles Market"
        if schedule.isOpen { // TODO: timezones!
            if Date() > schedule.closesAt {
                deliveryTime.text = "Closed at \(schedule.closesAt.format("h:mm a"))"
                setTag(isOpen: false)
            } else if Date() < schedule.opensAt {
                deliveryTime.text = "Opens at \(schedule.opensAt.format("h:mm a"))"
                setTag(isOpen: false)
            } else {
                deliveryTime.text = "Open \(schedule.opensAt.format("h:mm a")) to \(schedule.closesAt.format("h:mm a"))"
                setTag(isOpen: true)
            }
        } else {
            deliveryTime.text = "Closed today"
            setTag(isOpen: false)
        }
        total.text = cart.total.currencyFormat
    }

}
