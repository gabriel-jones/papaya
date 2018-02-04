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
            case cartItemCell, cartEmptyCell, cartDetailCell
            case browseCell
            case aisleSectionBarCell
            case instructionsItemCell, instructionsReplaceCell
            case itemGroupCell, itemCell
            case listGroupCell, listCell, listItemGridCell
            case itemDetailCell, itemActionCell
            case settingsInputCell, settingsLargeInputCell, settingsButtonCell
            case addressCell
            case notificationSettingSwitchCell
            case aboutCell, libraryCell
            case searchPopularCell, searchRecommendCell
            case similarItemCell
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