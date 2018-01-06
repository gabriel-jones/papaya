//
//  ListCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "listCell"
    
    private var listItemCount = UILabel()
    private var listName = UILabel()
    private var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        backgroundColor = .white
        cornerRadius = 10
        flatShadow = true
        flatShadowColor = UIColor(named: .flatShadow)
        clipsToBounds = true
        
        let layout = UICollectionViewFlowLayout()
        // Setup layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        addSubview(collectionView)
        
        listName.font = Font.gotham(size: 16)
        addSubview(listName)
        
        listItemCount.font = Font.gotham(size: 13)
        listItemCount.tintColor = UIColor(named: .mediumGrey)
        addSubview(listItemCount)
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(listName.snp.top).offset(8)
        }
        
        listName.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(16)
            make.right.equalTo(8)
            make.bottom.equalTo(listItemCount.snp.top).offset(8)
        }
        
        listItemCount.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(8)
            make.left.equalTo(16)
            make.right.equalTo(8)
            make.height.equalTo(20)
        }
    }
    
    func load(list: List) {
        listName.text = list.name
        listItemCount.text = "\(list.items.count) items"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
