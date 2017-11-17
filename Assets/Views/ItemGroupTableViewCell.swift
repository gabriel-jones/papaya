//
//  ItemGroupTableViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/13/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ItemGroupTableViewCell: UITableViewCell {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var viewAllButton: UIButton!
    
    @IBAction private func viewAll(_ sender: Any) {
        viewAllItems?(0) //TODO: section_id
    }
    
    public var viewAllItems: ((Int) -> ())? = nil
    
    public var itemDataSource: ItemDataSource?
    public var itemDelegate: ItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: C.ViewModel.Nib.itemCell, bundle: nil), forCellWithReuseIdentifier: C.ViewModel.CellIdentifier.itemCell)

        collectionView.dataSource = itemDataSource
        collectionView.delegate = itemDelegate
    }
    
    public func setTitle(to: String) {
        titleLabel.text = to
    }
    
}
