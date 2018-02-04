//
//  ItemDataSource.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ItemGroupModel: GroupModel {
    public var items: [Item]
    
    override init() {
        items = []
    }
    
    init(items: [Item]) {
        self.items = items
    }
    
    override public var isEmpty: Bool {
        get {
            return self.items.isEmpty
        }
    }
    
    override public func set(new: [Any]) {
        if let converted = new as? [Item] {
            self.items = converted
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.isEmpty ? 4 : items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        if items.isEmpty {
            cell.loadTemplate()
        } else {
            let item = items[indexPath.row]
            cell.load(item: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if items.isEmpty {
            return
        }
        delegate?.open(item: items[indexPath.row], imageId: (collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell)?.getImageId() ?? "")
    }
}
