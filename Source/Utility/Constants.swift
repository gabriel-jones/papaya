//
//  Constants.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import KeychainAccess

let keychain = Keychain(server: URL(string: "https://www.papaya.bm/")!, protocolType: .https)

struct C {
    public static let domain = "bm.papaya"
    
    struct URL {
        public static let main = development
        static let staging = "https://papaya-backend.herokuapp.com"
        static let production = "https://www.papaya.bm:5000"
        static let development = "http://localhost:5000"
        static let help = "https://www.papaya.bm/help"
        static let termsOfService = "https://www.papaya.bm/terms"
        static let privacyPolicy = "https://www.papaya.bm/privacy"
    }
    
    struct KeychainStore {
        static let user_email = "user_email"
        static let user_password = "user_password"
        static let user_auth_token = "user_auth_token"
    }
    
    struct ViewModel {
        enum CellIdentifier: String {
            case cartItemCell, emptyCell, cartDetailCell
            case browseCell, browseSpecialCell
            case aisleSectionBarCell
            case instructionsItemCell, instructionsReplaceCell
            case itemGroupCell, itemCell, specialItemCell
            case listGroupCell, listCell, listItemGridCell
            case itemDetailCell, itemActionCell
            case settingsInputCell, settingsLargeInputCell, settingsButtonCell, settingsUserCell
            case addressCell
            case notificationSettingSwitchCell
            case aboutCell, libraryCell
            case searchPopularCell, searchRecommendCell
            case similarItemCell
            case deliveryTimeCell, deliveryLocationCell
            case checkoutCartCell, checkoutTotalCell, checkoutMapCell
            case listHeaderView
            case clubCell
            case statusPending, statusSupport, statusPremiumAdvert, statusPickup, statusDelivery, statusPacking, statusCompleted, statusDeclined
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
