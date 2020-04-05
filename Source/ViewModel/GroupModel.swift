//
//  GroupModel.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/31/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

class GroupModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public var delegate: GroupDelegateAction?
    public var identifier: Int?
    
    public var isEmpty: Bool {
        get {
            return true
        }
    }
    
    public func set(new: [Any]) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: collectionView.frame.height)
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
