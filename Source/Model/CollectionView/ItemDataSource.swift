//
//  ItemDataSource.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ItemDataSource: NSObject, UICollectionViewDataSource {
    var items: [Item]
    
    override init() {
        items = []
    }
    
    init(items: [Item]) {
        self.items = items
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.itemCell, for: indexPath) as! ItemCollectionViewCell
        cell.load(item: items[indexPath.row])
        return cell
    }
}
