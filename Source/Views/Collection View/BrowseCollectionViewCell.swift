//
//  BrowseCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/23/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

class BrowseCollectionViewCell: UICollectionViewCell {
    public static let identifier: String = C.ViewModel.CellIdentifier.browseCell.rawValue
    
    private let imageView = UIImageViewAligned()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
        masksToBounds = false
        
        imageView.masksToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.alignment = .topRight
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        titleLabel.font = Font.gotham(size: 16)
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
    }
    
    public func load(category: Category) {
        titleLabel.text = category.name
        //imageView.alignment = category.isImageAlignmentLeft ?? false ? .topLeft : .topRight
        imageView.pin_setImage(from: category.imageURL)
    }
    
    private func buildConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-12)
            make.right.equalTo(-8)
        }
    }
}

class BrowseSpecialCollectionViewCell: UICollectionViewCell {
    public static let identifier: String = C.ViewModel.CellIdentifier.browseSpecialCell.rawValue
    
    private let imageView = UIImageViewAligned()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 15
        masksToBounds = false
        
        imageView.masksToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.alignment = .bottomRight
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        titleLabel.font = Font.gotham(weight: .bold, size: 23)
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        subtitleLabel.font = Font.gotham(weight: .bold, size: 10)
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.text = "SPECIAL CATEGORY"
        addSubview(subtitleLabel)
    }
    
    public func load(category: Category) {
        titleLabel.text = category.name
        imageView.pin_setImage(from: category.imageURL)
    }
    
    private func buildConstraints() {
        imageView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
        }
    }
}
