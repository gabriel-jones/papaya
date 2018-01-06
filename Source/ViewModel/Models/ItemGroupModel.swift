//
//  ItemDataSource.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ItemGroupModel: GroupModel {
    var items: [Item]
    
    override init() {
        items = []
    }
    
    init(items: [Item]) {
        self.items = items
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.itemCell.rawValue, for: indexPath) as! ItemCollectionViewCell
        let item = items[indexPath.row]
        cell.load(item: item, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.open(item: items[indexPath.row])
    }
}
