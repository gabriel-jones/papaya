//
//  ListItemGridCollectionViewCell.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/27/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ListItemGridCollectionViewCell: UICollectionViewCell {
    
    public static let identifier: String = C.ViewModel.CellIdentifier.listItemGridCell.rawValue
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buildViews()
        self.buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildViews() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    private func buildConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
    
    public func load(item: Item) {
        imageView.pin_setImage(from: item.img)
    }

}
