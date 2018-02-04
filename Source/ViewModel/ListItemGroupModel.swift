//
//  ListItemGridModel.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ListItemGroupModel: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var list: List?
    
    override init() {
        list = nil
    }
    
    init(list: List) {
        self.list = list
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let list = list else {
            return 0
        }
        return min(8, list.items.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.listItemGridCell.rawValue, for: indexPath) as! ListItemGridCollectionViewCell
        let item = list!.items[indexPath.row]
        cell.load(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/4, height: collectionView.frame.height/2)
    }
}
