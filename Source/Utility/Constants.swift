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
        public static let main = developmentTunnel
        static let production = "https://www.papaya.bm"
        static let development = "http://localhost:5000"
        static let developmentTunnel = "https://papaya.localtunnel.me"
        static let help = "https://www.papaya.bm/help"
        static let termsOfService = "https://www.papaya.bm/terms"
        static let privacyPolicy = "https://www.papaya.bm/privacy"
        static func categoryImage(with id: Int) -> String {
            return main + "/department/\(id)/image"
        }
    }
    
    public static let GMS_KEY = "AIzaSyCFy56PBJTowmL5q6cTX-d_uT6HFydP0DM"
    
    enum Notification: String {
        static let base = C.domain
        
        case cartBadgeUpdate
        case updateCartItem
        
        var value: String {
            get {
                return Notification.base + "." + rawValue
            }
        }
        
        static func convert(name: String) -> C.Notification? {
            return C.Notification(rawValue: name.components(separatedBy: ".").last ?? "")
        }
        
        static let allNotifications = [cartBadgeUpdate]
        static let allRoutedNotifications = [updateCartItem]
    }
    
    struct KeychainStore {
        static let user_email = "user_email"
        static let user_password = "user_password"
        static let user_auth_token = "user_auth_token"
    }
}
