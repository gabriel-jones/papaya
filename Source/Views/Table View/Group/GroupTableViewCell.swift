//
//  ItemGroupTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/13/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    var collectionView: UICollectionView!
    var titleLabel = UILabel(frame: .zero)
    var viewAllButton = UIButton(frame: .zero)
    
    var delegate: ViewAllDelegate?
    
    public var model: GroupModel? {
        didSet {
            collectionView.dataSource = model
            collectionView.delegate = model
            collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 200)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = model
        collectionView.dataSource = model
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.delaysContentTouches = true
        addSubview(collectionView)
        
        titleLabel.font = Font.gotham(size: 15)
        addSubview(titleLabel)
        
        viewAllButton.setTitle("View All", for: .normal)
        viewAllButton.setImage(#imageLiteral(resourceName: "Right Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        viewAllButton.tintColor = UIColor(named: .green)
        viewAllButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        viewAllButton.setTitleColor(UIColor(named: .green), for: .normal)
        viewAllButton.titleLabel?.font = Font.gotham(size: 15)
        viewAllButton.addTarget(self, action: #selector(viewAll(_:)), for: .touchUpInside)
        viewAllButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewAllButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewAllButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        viewAllButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        addSubview(viewAllButton)
    }
    
    private func buildConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(24)
            make.height.equalTo(viewAllButton.snp.height)
        }
        
        viewAllButton.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.top.equalTo(8)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    public func model(with: GroupModel) {
        
    }
    
    public func set(title: String) {
        titleLabel.text = title
    }
    
    @objc func viewAll(_ sender: Any) {
        delegate?.viewAll(sender: sender)
    }
    
}
