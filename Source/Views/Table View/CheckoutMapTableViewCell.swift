//
//  CheckoutMapTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/17/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import RxSwift

protocol CheckoutMapDelegate {
    func changeAddress()
}

class CheckoutMapTableViewCell: UITableViewCell {
    public static let identifier: String = C.ViewModel.CellIdentifier.checkoutMapCell.rawValue
    public var delegate: CheckoutMapDelegate?
    
    public let addressLabel = UILabel()
    public let zipLabel = UILabel()
    public let changeButton = UIButton()
    private let addressImage = UIImageView()
    private let addressMap = UIImageView()
    private let addressFadeGradient = CAGradientLayer()
    private let mapLoading = UIActivityIndicatorView()
    
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
        
        addressImage.image = #imageLiteral(resourceName: "Address").tintable
        addressImage.contentMode = .scaleAspectFit
        addressImage.tintColor = UIColor.gray
        addSubview(addressImage)
        
        addressLabel.font = Font.gotham(size: 15)
        addressLabel.numberOfLines = 0
        addSubview(addressLabel)
        
        zipLabel.textColor = UIColor.gray
        zipLabel.font = Font.gotham(size: 13)
        addSubview(zipLabel)
        
        changeButton.setTitleColor(UIColor(named: .green), for: .normal)
        changeButton.setTitle("Change", for: .normal)
        changeButton.setImage(#imageLiteral(resourceName: "Right Arrow").tintable, for: .normal)
        changeButton.tintColor = UIColor(named: .green)
        changeButton.titleLabel?.font = Font.gotham(size: 16)
        changeButton.semanticContentAttribute = .forceRightToLeft
        changeButton.addTarget(self, action: #selector(change(_:)), for: .touchUpInside)
        addSubview(changeButton)
        
        addressMap.contentMode = .scaleAspectFill
        addressMap.masksToBounds = true
        addressMap.backgroundColor = .clear
        addSubview(addressMap)
        
        mapLoading.hidesWhenStopped = true
        addSubview(mapLoading)
    }
    
    @objc private func change(_ sender: UIButton) {
        delegate?.changeAddress()
    }
    
    private func buildConstraints() {
        addressImage.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(12)
            make.height.width.equalTo(25)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(addressImage.snp.right).offset(15)
            make.centerY.equalTo(addressImage.snp.centerY)
            make.right.equalTo(addressMap.snp.left).offset(-8)
        }
        
        zipLabel.snp.makeConstraints { make in
            make.leading.equalTo(addressLabel.snp.leading)
            make.trailing.equalTo(addressLabel.snp.trailing)
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
        }
        
        changeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalTo(addressLabel.snp.leading)
        }
        
        addressMap.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        mapLoading.snp.makeConstraints { make in
            make.center.equalTo(addressMap.snp.center)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addressFadeGradient.frame = addressMap.bounds
        addressFadeGradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        addressFadeGradient.startPoint = CGPoint(x: 0, y: 1)
        addressFadeGradient.endPoint = CGPoint(x: 0.3, y: 1)
        addressMap.layer.mask = addressFadeGradient
    }
    
    public func load(address: Address) {
        addressLabel.text = address.street
        zipLabel.text = address.zip
        addressMap.image = nil
        mapLoading.startAnimating()
        Request.shared.getAddressImage(address: address) { image in
            DispatchQueue.main.async {
                self.mapLoading.stopAnimating()
                self.addressMap.image = image
            }
        }
    }
}
