//
//  BrowseCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/23/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class BrowseCollectionViewCell: UICollectionViewCell {
    public static let identifier: String = C.ViewModel.CellIdentifier.browseCell.rawValue
    
    private let imageView = UIImageView()
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
        flatShadow = true
        layer.shadowColor = UIColor(named: .flatShadow).cgColor
        masksToBounds = false
        
        addSubview(imageView)
        
        titleLabel.font = Font.gotham(size: 16)
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
    }
    
    public func load(category: Category) {
        titleLabel.text = category.name
        imageView.pin_setImage(from: category.imageURL)
    }
    
    private func buildConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-12)
            make.right.equalTo(-8)
        }
    }
}
