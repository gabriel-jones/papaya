//
//  ListModel.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ListGroupModel: GroupModel {
    var lists: [List]
    
    override init() {
        lists = []
    }
    
    init(lists: [List]) {
        self.lists = lists
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.listCell.rawValue, for: indexPath) as! ListCollectionViewCell
        let list = lists[indexPath.row]
        cell.load(list: list)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.open(list: lists[indexPath.row])
    }
}
