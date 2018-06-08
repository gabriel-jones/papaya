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
        enum CellIdentifier: String {
            case cartItemCell, emptyCell, cartDetailCell
            case browseCell, browseSpecialCell
            case aisleSectionBarCell
            case instructionsItemCell, instructionsReplaceCell
            case itemGroupCell, itemCell, specialItemCell
            case listGroupCell, listCell, listItemGridCell
            case itemDetailCell, itemActionCell
            case settingsInputCell, settingsLargeInputCell, settingsButtonCell
            case addressCell
            case notificationSettingSwitchCell
            case aboutCell, libraryCell
            case searchPopularCell, searchRecommendCell
            case similarItemCell
            case deliveryTimeCell, deliveryLocationCell
            case checkoutCartCell, checkoutTotalCell, checkoutMapCell
            case listHeaderView
            case clubCell
        }
        
        enum Nib: String {
            case itemGroupCell = "ItemGroupTableViewCell"
            case itemCell = "ItemCollectionViewCell"
            case listGroupCell = "ListGroupTableViewCell"
            case listCell = "ListCollectionViewCell"
        }
        
        enum StoryboardIdentifier: String {
            case homeTabBar = "HomeTabBarVC"
            case getStartedNav = "GetStartedNavVC"
            case itemNav = "ItemNavVC"
        }
    }
}
