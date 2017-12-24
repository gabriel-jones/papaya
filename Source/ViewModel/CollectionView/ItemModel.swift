//
//  ItemDataSource.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ItemModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var items: [Item]
    var delegate: ItemDelegateAction?
    
    override init() {
        items = []
    }
    
    init(items: [Item]) {
        print("init data srouce with # items: \(items.count)")
        self.items = items
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(items.count)
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.itemCell, for: indexPath) as! ItemCollectionViewCell
        cell.load(item: items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.open(item: items[indexPath.row])
    }
}
