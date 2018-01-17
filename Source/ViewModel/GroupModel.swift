//
//  GroupModel.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/31/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class GroupModel: NSObject, UICollectionViewDataSource {
    
    var delegate: GroupDelegateAction?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

protocol GroupDelegateAction {
    func open(item: Item, imageId: String)
    func open(list: List, imageIds: [String])
}

extension GroupDelegateAction {
    func open(item: Item, imageId: String) {}
    func open(list: List, imageIds: [String]) {}
}
