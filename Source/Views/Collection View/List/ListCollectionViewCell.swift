//
//  ListCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.listCell.rawValue
    
    private var items: [Item]?
    private let listItemCount = UILabel()
    private let listName = UILabel()
    private var collectionView: UICollectionView!
    private let gridTemplate = UIImageView()
    private let nameTemplate = UIView()
    private let itemCountTemplate = UIView()

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
        clipsToBounds = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.masksToBounds = true
        collectionView.register(ListItemGridCollectionViewCell.self, forCellWithReuseIdentifier: ListItemGridCollectionViewCell.identifier)
        addSubview(collectionView)
        
        listName.font = Font.gotham(size: 16)
        listName.numberOfLines = 0
        addSubview(listName)
        
        listItemCount.font = Font.gotham(size: 13)
        listItemCount.tintColor = UIColor(named: .mediumGrey)
        addSubview(listItemCount)
        
        gridTemplate.image = #imageLiteral(resourceName: "Picture").tintable
        gridTemplate.tintColor = .gray
        gridTemplate.contentMode = .center
        addSubview(gridTemplate)
        
        itemCountTemplate.backgroundColor = .lightGray
        itemCountTemplate.alpha = 0.6
        itemCountTemplate.isHidden = true
        listItemCount.addSubview(itemCountTemplate)
        
        nameTemplate.backgroundColor = .lightGray
        nameTemplate.alpha = 0.6
        nameTemplate.isHidden = true
        listName.addSubview(nameTemplate)
        
        
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.left.equalTo(4)
            make.right.equalTo(-4)
            make.bottom.equalTo(listName.snp.top).offset(-8)
        }
        
        listName.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-8)
            make.bottom.equalTo(listItemCount.snp.top).offset(-4)
        }
        
        listItemCount.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalTo(16)
            make.right.equalTo(-8)
        }
        
        itemCountTemplate.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(CGFloat(3.0/5.0))
        }
        
        nameTemplate.snp.makeConstraints { make in
            make.left.equalTo(-8)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        gridTemplate.snp.makeConstraints { make in
            make.center.equalTo(collectionView.snp.center)
        }
    }
    
    public func load(list: List) {
        gridTemplate.removeFromSuperview()
        gridTemplate.layer.removeAllAnimations()
        nameTemplate.removeFromSuperview()
        nameTemplate.layer.removeAllAnimations()
        itemCountTemplate.removeFromSuperview()
        itemCountTemplate.layer.removeAllAnimations()
        
        listName.text = list.name
        listItemCount.text = "\(list.itemCount) items"
        items = list.items
    }
    
    public func loadTemplate() {
        collectionView.backgroundColor = UIColor(named: .backgroundGrey)
        collectionView.layer.cornerRadius = 5
        
        listItemCount.text = " "
        itemCountTemplate.isHidden = false
        
        listName.text = " "
        nameTemplate.isHidden = false
        
        DispatchQueue.main.async {
            self.layoutSubviews()
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.itemCountTemplate.alpha = 0.3
                self.nameTemplate.alpha = 0.3
            }, completion: nil)
        }
    }
    
    override func layoutSubviews() {
        nameTemplate.layer.cornerRadius = nameTemplate.frame.height / 2
        itemCountTemplate.layer.cornerRadius = itemCountTemplate.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size: \(collectionView.frame.height), \(collectionView.frame.height / 2)")
        return CGSize(width: collectionView.frame.width / 4, height: floor(collectionView.frame.height / 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(items?.count ?? 0, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListItemGridCollectionViewCell.identifier, for: indexPath) as! ListItemGridCollectionViewCell
        if let item = items?[indexPath.row] {
            cell.load(item: item)
        }
        return cell
    }
}
