//
//  ListModel.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class ListGroupModel: GroupModel {
    public var lists: [List]
    
    override init() {
        lists = []
    }
    
    public init(lists: [List]) {
        self.lists = lists
    }
    
    override public var isEmpty: Bool {
        get {
            return self.lists.isEmpty
        }
    }
    
    override public func set(new: [Any]) {
        if let converted = new as? [List] {
            self.lists = converted
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.isEmpty ? 4 : lists.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.identifier, for: indexPath) as! ListCollectionViewCell
        if lists.isEmpty {
            cell.loadTemplate()
        } else {
            let list = lists[indexPath.row]
            cell.load(list: list)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if lists.isEmpty {
            return
        }
        delegate?.open(list: lists[indexPath.row], imageIds: []) // TODO: imageIds ANIMATE
    }
}
