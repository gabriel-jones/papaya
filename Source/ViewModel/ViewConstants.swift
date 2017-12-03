//
//  Constants.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

extension C {
    struct ViewModel {
        struct CellIdentifier {
            static let itemCell = "itemCell"
            static let cartItemCell = "cartItemCell"
            static let cartEmptyCell = "cartEmptyCell"
            static let aisleSectionBarCell = "aisleSectionBarCell"
            static let itemGroupCell = "itemGroupCell"
            static let instructionsItemCell = "instructionsItemCell"
            static let instructionsReplaceCell = "instructionsReplaceCell"
        }
        
        struct Nib {
            static let itemGroupCell = "ItemGroupTableViewCell"
            static let itemCell = "ItemCollectionViewCell"
        }
    }
}
