//
//  ListHeaderView.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/13/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

func centerButtonImageAndTitle(button: UIButton) {
    let spacing: CGFloat = 5
    let titleSize = button.titleLabel!.frame.size
    let imageSize = button.imageView!.frame.size
    
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
    button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: -imageSize.width/2, bottom: 0, right: -titleSize.width)
}

protocol ListHeaderViewDelegate: class {
    func loadToCart()
}

class ListHeaderView: UICollectionReusableView {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.listHeaderView.rawValue
    
    public var delegate: ListHeaderViewDelegate?
    
    private let listNameLabel = UILabel()
    private let itemCountLabel = UILabel()
    private let cartLoadButton = UIButton()
    
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
        backgroundColor = .white
        
        listNameLabel.font = Font.gotham(size: 16)
        addSubview(listNameLabel)
        
        itemCountLabel.font = Font.gotham(size: 14)
        itemCountLabel.textColor = .gray
        addSubview(itemCountLabel)
        
        cartLoadButton.titleLabel?.font = Font.gotham(size: 17)
        cartLoadButton.setTitle("Load", for: .normal)
        cartLoadButton.setTitleColor(UIColor(named: .green), for: .normal)
        cartLoadButton.setImage(#imageLiteral(resourceName: "Cart Load").tintable, for: .normal)
        cartLoadButton.tintColor = UIColor(named: .green)
        centerButtonImageAndTitle(button: cartLoadButton)
        cartLoadButton.addTarget(self, action: #selector(load(_:)), for: .touchUpInside)
        addSubview(cartLoadButton)
    }
    
    @objc private func load(_ sender: UIButton) {
        delegate?.loadToCart()
    }
    
    private func buildConstraints() {
        listNameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview().offset(-12)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview().offset(12)
        }
        
        cartLoadButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }
    
    public func load(list: List) {
        listNameLabel.text = list.name
        itemCountLabel.text = "\(list.itemCount) items"
    }
    
}
