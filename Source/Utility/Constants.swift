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
    static let domain = "bm.papaya"
    
    struct URL {
        static let main = development
        static let production = "https://www.papaya.bm"
        static let development = "http://localhost:5000"
    }
    
    static let GMS_KEY = "AIzaSyCFy56PBJTowmL5q6cTX-d_uT6HFydP0DM"
    
    enum Notification: String {
        static let base = C.domain
        
        case cartBadgeUpdate
        
        var value: String {
            get {
                return Notification.base + "." + rawValue
            }
        }
        
        static let allNotifications = [cartBadgeUpdate]
    }
    
    struct KeychainStore {
        static let user_email = "user_email"
        static let user_password = "user_password"
        static let user_auth_token = "user_auth_token"
    }
}
