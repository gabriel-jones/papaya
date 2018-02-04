//
//  Stepper.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/17/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class Stepper: UIView {
    public var maximum = 100
    public var minimum = 1
    public var value = 1 {
        didSet {
            valueLabel.text = String(value)
        }
    }
    
    private let valueLabel = UILabel()
    private let decreaseButton = UIButton()
    private let increaseButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.load()
    }
    
    private func load() {
        self.build()
        self.buildConstraints()
    }
    
    private func build() {
        layer.cornerRadius = 5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        backgroundColor = UIColor(named: .backgroundGrey)
        
        decreaseButton.setImage(#imageLiteral(resourceName: "Minus").tintable, for: .normal)
        decreaseButton.tintColor = UIColor(named: .green)
        decreaseButton.addTarget(self, action: #selector(decrease(_:)), for: .touchUpInside)
        addSubview(decreaseButton)
        
        increaseButton.setImage(#imageLiteral(resourceName: "Plus").tintable, for: .normal)
        increaseButton.tintColor = UIColor(named: .green)
        increaseButton.addTarget(self, action: #selector(increase(_:)), for: .touchUpInside)
        addSubview(increaseButton)
        
        valueLabel.textAlignment = .center
        valueLabel.font = Font.gotham(size: 15)
        addSubview(valueLabel)
        
        value = minimum
    }
    
    private func buildConstraints() {
        decreaseButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(decreaseButton.snp.height)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(decreaseButton.snp.right)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalTo(increaseButton.snp.left)
        }
        
        increaseButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(increaseButton.snp.height)
        }
    }
    
    @objc func decrease(_ sender: UIButton) {
        value = max(self.minimum, value-1)
    }
    
    @objc func increase(_ sender: UIButton) {
        value = min(self.maximum, value+1)
    }
    
}
